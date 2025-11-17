// autoshutdown.c
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <stdarg.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/poll.h>
#include <sys/resource.h>
#include <sched.h>
#include <linux/input.h>
#include <dirent.h>

#define LOG_FILE "/emuelec/logs/shutdowntimer.log"
#define PID_FILE "/tmp/autoshutdown.pid"
#define MAX_DEVICES 32
#define POLL_TIMEOUT_MS 5000  // Check every 5 seconds instead of 1

static FILE *log_fp = NULL;
static time_t last_activity;
static volatile int running = 1;
static int debug_mode = 0;

static int check_debug_mode() {
    // get_es_setting is defined in /etc/profile, so we need to source it first
    FILE *fp = popen(". /etc/profile && get_es_setting string LogLevel", "r");
    if (!fp) return 0;
    
    char result[64] = {0};
    if (fgets(result, sizeof(result), fp) != NULL) {
        result[strcspn(result, "\n")] = 0;
        pclose(fp);
        return (strcmp(result, "debug") == 0);
    }
    pclose(fp);
    return 0;
}

static void log_msg(const char *level, const char *fmt, ...) {
	
	if (strcmp(level, "SUCCESS") != 0) {
		if (!debug_mode) return;
	}
    
    if (!log_fp) return;
    
    va_list args;
    va_start(args, fmt);
    time_t t = time(NULL);
    struct tm tm;
    localtime_r(&t, &tm);
    char buf[64];
    strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", &tm);
    fprintf(log_fp, "[%s] [%s] ", buf, level);
    vfprintf(log_fp, fmt, args);
    fprintf(log_fp, "\n");
    fflush(log_fp);
    va_end(args);
}

static void cleanup(int signum) {
    log_msg("INFO", "Received signal %d, exiting...", signum);
    running = 0;
}

static void perform_action(const char *action) {
    if (!action) return;
    if (strcmp(action, "shutdown") == 0) {
        log_msg("SUCCESS", "No activity detected: calling shutdown, bye :-)");
        system(". /etc/profile && shutdown");
    } else {
        log_msg("INFO", "No activity detected: killing process %s", action);
        char cmd[256];
        snprintf(cmd, sizeof(cmd), "pkill -TERM %s", action);
        system(cmd);
    }
}

static int is_relevant_device(const char *path) {
    int fd = open(path, O_RDONLY);
    if (fd < 0) return 0;
    
    // Check if device supports the event types we care about
    unsigned long evbit[EV_MAX/sizeof(long)/8 + 1] = {0};
    if (ioctl(fd, EVIOCGBIT(0, sizeof(evbit)), evbit) < 0) {
        close(fd);
        return 0;
    }
    
    // Only monitor devices with keys, relative movement, or absolute positioning
    int relevant = (evbit[0] & (1 << EV_KEY)) || 
                   (evbit[0] & (1 << EV_REL)) || 
                   (evbit[0] & (1 << EV_ABS));
    close(fd);
    return relevant;
}

static int is_motion_sensor_event(struct input_event *ev) {
    // Filter out motion sensor axes commonly used by PS3/PS4/PS5 controllers
    // These axes constantly send data even when controller is sitting still
    if (ev->type == EV_ABS) {
        switch (ev->code) {
            // Accelerometer axes
            case ABS_RX:  // Often used for accelerometer X
            case ABS_RY:  // Often used for accelerometer Y  
            case ABS_RZ:  // Often used for accelerometer Z
            // Gyroscope axes (some controllers)
            case ABS_TILT_X:
            case ABS_TILT_Y:
            // Other motion/orientation sensors
            case ABS_DISTANCE:
            case ABS_MISC:
                return 1;  // This is likely motion sensor data
            default:
                return 0;  // Legitimate analog stick/trigger input
        }
    }
    return 0;
}

static int open_input_devices(struct pollfd *pfds, int max_devices) {
    DIR *dir = opendir("/dev/input");
    if (!dir) {
        log_msg("ERROR", "Cannot open /dev/input: %s", strerror(errno));
        return 0;
    }

    struct dirent *entry;
    int count = 0;
    while ((entry = readdir(dir)) != NULL && count < max_devices) {
        if (strncmp(entry->d_name, "event", 5) == 0) {
            char path[256];
            snprintf(path, sizeof(path), "/dev/input/%s", entry->d_name);
            
            // Skip irrelevant devices
            if (!is_relevant_device(path)) {
                continue;
            }
            
            int fd = open(path, O_RDONLY | O_NONBLOCK);
            if (fd >= 0) {
                pfds[count].fd = fd;
                pfds[count].events = POLLIN;
                log_msg("INFO", "Monitoring device: %s", path);
                count++;
            } else {
                log_msg("WARN", "Failed to open %s: %s", path, strerror(errno));
            }
        }
    }
    closedir(dir);
    return count;
}

static int read_timer_from_ees() {
    FILE *fp = popen("ees -e -r ee_auto_shutdown_timeout", "r");
    if (!fp) return 0;
    int t = 0;
    if (fscanf(fp, "%d", &t) != 1) t = 0;
    pclose(fp);
    return t;
}

static void set_low_priority() {
    // Set to lowest priority nice value
    if (setpriority(PRIO_PROCESS, 0, 19) < 0) {
        log_msg("WARN", "Failed to set nice priority: %s", strerror(errno));
    }
    
    // Set idle I/O scheduling class (best effort, class 3, lowest priority)
    // This requires ioprio_set syscall which isn't in libc
    // We'll skip this for simplicity, but it could be added via syscall()
}

int main(int argc, char *argv[]) {
    int timeout_minutes = 0;
    const char *action = "shutdown";

    // Check if debug mode is enabled BEFORE forking
    debug_mode = check_debug_mode();

    // Open log only if debug mode is enabled
    if (debug_mode) {
        log_fp = fopen(LOG_FILE, "w+");
        if (!log_fp) {
            perror("Failed to open log file");
            return 1;
        }
    }

    // Parse arguments
    int opt;
    while ((opt = getopt(argc, argv, "t:p:")) != -1) {
        switch (opt) {
            case 't': timeout_minutes = atoi(optarg); break;
            case 'p': action = optarg; break;
            default: break;
        }
    }

    // Auto-mode if no timer specified
    if (timeout_minutes <= 0) {
        timeout_minutes = read_timer_from_ees();
        if (timeout_minutes <= 0) {
            log_msg("INFO", "Auto-mode timer is 0 or undefined. Exiting.");
            if (log_fp) fclose(log_fp);
            return 2;  // Exit code 2: no timer configured
        }
        log_msg("INFO", "Auto-mode timer: %d minutes", timeout_minutes);
    }

    int limit_seconds = timeout_minutes * 60;
    last_activity = time(NULL);

    // Setup signal handlers
    signal(SIGTERM, cleanup);
    signal(SIGINT, cleanup);

    // Daemonize
    pid_t pid = fork();
    if (pid < 0) exit(1);
    if (pid > 0) exit(0); // parent exits
    umask(0);
    setsid();
    chdir("/");
    
    // Close standard file descriptors after forking to avoid interference
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);

    // Set low priority to minimize impact
    set_low_priority();

    // Write PID file
    FILE *pid_fp = fopen(PID_FILE, "w");
    if (pid_fp) {
        fprintf(pid_fp, "%d\n", getpid());
        fclose(pid_fp);
        log_msg("INFO", "PID file created at %s", PID_FILE);
    } else {
        log_msg("WARN", "Cannot write PID file: %s", strerror(errno));
    }

    // Open input devices
    struct pollfd pfds[MAX_DEVICES];
    int num_fds = open_input_devices(pfds, MAX_DEVICES);
    if (num_fds == 0) {
        log_msg("ERROR", "No input devices found, exiting");
        if (log_fp) fclose(log_fp);
        remove(PID_FILE);
        return 1;
    }

    log_msg("SUCCESS", "Autoshutdown started: timeout=%d minutes, action=%s, poll_interval=%dms", 
            timeout_minutes, action, POLL_TIMEOUT_MS);

    struct input_event ev;
    char device_name[256];
    time_t last_check = time(NULL);

    while (running) {
        int activity_detected = 0;

        // Poll with longer timeout to reduce CPU wake-ups
        int ret = poll(pfds, num_fds, POLL_TIMEOUT_MS);
        
        if (ret > 0) {
            // Drain all pending events efficiently
            for (int i = 0; i < num_fds; i++) {
                if (pfds[i].revents & POLLIN) {
                    // Read and discard events - we only care that SOMETHING happened
                    while (read(pfds[i].fd, &ev, sizeof(ev)) > 0) {
                        // Check if this is legitimate input (not motion sensor noise)
                        if (ev.type == EV_KEY || ev.type == EV_REL) {
                            activity_detected = 1;
                        } else if (ev.type == EV_ABS && !is_motion_sensor_event(&ev)) {
                            activity_detected = 1;
							// Uncomment for detailed activity logging in debug mode 
                            if (ioctl(pfds[i].fd, EVIOCGNAME(sizeof(device_name)), device_name) >= 0) { 
                                log_msg("INFO", "Activity detected on %s", device_name); 
                            } else { 
                                log_msg("INFO", "Activity detected on fd %d", pfds[i].fd); 
                            }   
                        }
                    }
                }
                // Handle errors/hangups by reopening device
                if (pfds[i].revents & (POLLERR | POLLHUP | POLLNVAL)) {
                    close(pfds[i].fd);
                    pfds[i].fd = -1;
                    log_msg("WARN", "Device fd %d disconnected", i);
                }
            }
        }

        if (activity_detected) {
            last_activity = time(NULL);
        }

        // Only check time periodically to reduce syscalls
        time_t now = time(NULL);
        if (now - last_check >= 1) {
            last_check = now;
            if (difftime(now, last_activity) > limit_seconds) {
                perform_action(action);
                break;
            }
        }
    }

    // Cleanup
    for (int i = 0; i < num_fds; i++) {
        if (pfds[i].fd >= 0) close(pfds[i].fd);
    }
    if (log_fp) fclose(log_fp);
    remove(PID_FILE);

    return 0;
}
