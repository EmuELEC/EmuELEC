/*
	ees - EmuELEC setter
* 
Usage:
  RetroArch config:
    ees -s <key> -v <value> [-o file]  Set a setting
    ees -r <key> [-o file]             Read a setting
    ees -i <changes.cfg> [-o out]      Merge changes

  EmuELEC emuelec.conf config (enable with -e):
    ees -e -s <key> -v <value> -p <platform> [-m <rom>]
                                   Set setting (uses $EE_CONF)
    ees -e -r <key> -p <platform> [-m <rom>]
                                   Read setting with priority:
                                   ROM -> Platform -> Global -> Standalone

Environment variables:
  RA_CONF - path to retroarch.cfg (default: /storage/.config/retroarch/retroarch.cfg)
  EE_CONF - path to emuelec.conf (default: /storage/.config/emuelec/configs/emuelec.conf)

Note: -o specifies output file (for -s/-r, uses $RA_CONF if not specified)
 Compile: gcc -O2 -o ras ras.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>

#define MAX_LINE 2048
#define MAX_KEY 256
#define MAX_VALUE 1024
#define HASH_SIZE 1024

typedef struct Entry {
    char *key;
    char *value;
    struct Entry *next;
} Entry;

typedef struct {
    Entry *buckets[HASH_SIZE];
} HashMap;

/* Simple hash function */
unsigned int hash(const char *str) {
    unsigned int h = 5381;
    int c;
    while ((c = *str++))
        h = ((h << 5) + h) + c;
    return h % HASH_SIZE;
}

/* Create new hashmap */
HashMap* hashmap_create() {
    HashMap *map = calloc(1, sizeof(HashMap));
    return map;
}

/* Trim whitespace from both ends */
char* trim(char *str) {
    char *end;
    while (isspace((unsigned char)*str)) str++;
    if (*str == 0) return str;
    end = str + strlen(str) - 1;
    while (end > str && isspace((unsigned char)*end)) end--;
    end[1] = '\0';
    return str;
}

/* Insert or update key-value pair */
void hashmap_put(HashMap *map, const char *key, const char *value) {
    unsigned int h = hash(key);
    Entry *e = map->buckets[h];
    
    /* Check if key exists, update if found */
    while (e) {
        if (strcmp(e->key, key) == 0) {
            free(e->value);
            e->value = strdup(value);
            return;
        }
        e = e->next;
    }
    
    /* New entry */
    e = malloc(sizeof(Entry));
    e->key = strdup(key);
    e->value = strdup(value);
    e->next = map->buckets[h];
    map->buckets[h] = e;
}

/* Get value for key */
const char* hashmap_get(HashMap *map, const char *key) {
    unsigned int h = hash(key);
    Entry *e = map->buckets[h];
    
    while (e) {
        if (strcmp(e->key, key) == 0)
            return e->value;
        e = e->next;
    }
    return NULL;
}

/* Parse a config line: key = "value" or key = value */
int parse_line(char *line, char *key, char *value) {
    char *eq, *val_start, *val_end;
    
    /* Skip comments and empty lines */
    char *trimmed = trim(line);
    if (trimmed[0] == '#' || trimmed[0] == '\0')
        return 0;
    
    /* Find the = sign */
    eq = strchr(trimmed, '=');
    if (!eq) return 0;
    
    /* Extract key */
    *eq = '\0';
    strncpy(key, trim(trimmed), MAX_KEY - 1);
    key[MAX_KEY - 1] = '\0';
    
    /* Extract value */
    val_start = trim(eq + 1);
    
    /* Remove quotes if present */
    if (val_start[0] == '"') {
        val_start++;
        val_end = strrchr(val_start, '"');
        if (val_end) *val_end = '\0';
    }
    
    strncpy(value, val_start, MAX_VALUE - 1);
    value[MAX_VALUE - 1] = '\0';
    
    return 1;
}

/* Load config file into hashmap */
int load_config(const char *filename, HashMap *map) {
    FILE *f = fopen(filename, "r");
    if (!f) {
        return 0;
    }
    
    char line[MAX_LINE];
    char key[MAX_KEY], value[MAX_VALUE];
    
    while (fgets(line, sizeof(line), f)) {
        if (parse_line(line, key, value)) {
            hashmap_put(map, key, value);
        }
    }
    
    fclose(f);
    return 1;
}

/* Write hashmap to config file */
int write_config(const char *filename, HashMap *map) {
    char temp_file[1024];
    snprintf(temp_file, sizeof(temp_file), "%s.tmp", filename);
    
    FILE *f = fopen(temp_file, "w");
    if (!f) {
        fprintf(stderr, "Error: Cannot write to %s\n", temp_file);
        return 0;
    }
    
    /* Iterate through all buckets */
    for (int i = 0; i < HASH_SIZE; i++) {
        Entry *e = map->buckets[i];
        while (e) {
            fprintf(f, "%s = \"%s\"\n", e->key, e->value);
            e = e->next;
        }
    }
    
    fclose(f);
    
    /* Atomic rename */
    if (rename(temp_file, filename) != 0) {
        fprintf(stderr, "Error: Cannot rename %s to %s\n", temp_file, filename);
        unlink(temp_file);
        return 0;
    }
    
    return 1;
}

/* Free hashmap */
void hashmap_free(HashMap *map) {
    for (int i = 0; i < HASH_SIZE; i++) {
        Entry *e = map->buckets[i];
        while (e) {
            Entry *next = e->next;
            free(e->key);
            free(e->value);
            free(e);
            e = next;
        }
    }
    free(map);
}

/* Get RA_CONF from environment */
const char* get_ra_conf() {
    const char *conf = getenv("RA_CONF");
    if (!conf) {
        return "/storage/.config/retroarch/retroarch.cfg";
    }
    return conf;
}

/* Get EE_CONF from environment */
const char* get_ee_conf() {
    const char *conf = getenv("EE_CONF");
    if (!conf) {
        return "/storage/.config/emuelec/configs/emuelec.conf";
    }
    return conf;
}

/* Parse hierarchical config line: platform["rom"].key=value or platform.key=value or global.key=value or standalone key=value */
int parse_ee_line(char *line, char *platform, char *rom, char *key, char *value) {
    char *trimmed = trim(line);
    
    /* Skip comments and empty lines */
    if (trimmed[0] == '#' || trimmed[0] == '\0')
        return 0;
    
    /* Find the = sign */
    char *eq = strchr(trimmed, '=');
    if (!eq) return 0;
    
    *eq = '\0';
    char *left = trim(trimmed);
    char *val = trim(eq + 1);
    
    /* Copy value */
    strncpy(value, val, MAX_VALUE - 1);
    value[MAX_VALUE - 1] = '\0';
    
    /* Parse left side */
    platform[0] = '\0';
    rom[0] = '\0';
    
    /* Check for ROM-specific: platform["rom"].key */
    char *bracket = strchr(left, '[');
    if (bracket) {
        *bracket = '\0';
        strncpy(platform, trim(left), MAX_KEY - 1);
        platform[MAX_KEY - 1] = '\0';
        
        char *quote1 = strchr(bracket + 1, '"');
        if (quote1) {
            char *quote2 = strchr(quote1 + 1, '"');
            if (quote2) {
                *quote2 = '\0';
                strncpy(rom, quote1 + 1, MAX_KEY - 1);
                rom[MAX_KEY - 1] = '\0';
                
                /* Look for dot or hyphen after the closing bracket */
                char *sep = quote2 + 1;
                while (*sep && (*sep == ']' || isspace(*sep))) sep++;
                if (*sep == '.' || *sep == '-') {
                    strncpy(key, trim(sep + 1), MAX_KEY - 1);
                    key[MAX_KEY - 1] = '\0';
                    return 1;
                }
            }
        }
        return 0;
    }
    
    /* Check for platform.key or global.key */
    char *dot = strchr(left, '.');
    if (!dot) dot = strchr(left, '-');  /* Support both . and - as separators */
    
    if (dot) {
        *dot = '\0';
        strncpy(platform, trim(left), MAX_KEY - 1);
        platform[MAX_KEY - 1] = '\0';
        strncpy(key, trim(dot + 1), MAX_KEY - 1);
        key[MAX_KEY - 1] = '\0';
        return 1;
    }
    
    /* Standalone key with no platform (e.g., ee_randomsplashpath=value) */
    strncpy(key, left, MAX_KEY - 1);
    key[MAX_KEY - 1] = '\0';
    platform[0] = '\0';  /* Empty platform means standalone */
    
    return 1;
}

/* Read hierarchical setting: ROM -> Platform -> Global -> Standalone */
int cmd_ee_read(const char *setting_key, const char *platform_name, const char *rom_name) {
    const char *conf_file = get_ee_conf();
    if (!conf_file) return 1;
    
    FILE *f = fopen(conf_file, "r");
    if (!f) {
        fprintf(stderr, "Error: Cannot read %s\n", conf_file);
        return 1;
    }
    
    char line[MAX_LINE];
    char platform[MAX_KEY], rom[MAX_KEY], key[MAX_KEY], value[MAX_VALUE];
    
    char *rom_value = NULL;
    char *platform_value = NULL;
    char *global_value = NULL;
    char *standalone_value = NULL;
    
    /* Read file and find matching entries */
    while (fgets(line, sizeof(line), f)) {
        if (parse_ee_line(line, platform, rom, key, value)) {
            if (strcmp(key, setting_key) == 0) {
                /* ROM-specific match (highest priority) */
                if (rom_name && rom[0] != '\0' && 
                    strcmp(platform, platform_name) == 0 && 
                    strcmp(rom, rom_name) == 0) {
                    if (rom_value) free(rom_value);
                    rom_value = strdup(value);
                }
                /* Platform-specific match */
                else if (rom[0] == '\0' && platform[0] != '\0' && strcmp(platform, platform_name) == 0) {
                    if (platform_value) free(platform_value);
                    platform_value = strdup(value);
                }
                /* Global match */
                else if (rom[0] == '\0' && platform[0] != '\0' && strcmp(platform, "global") == 0) {
                    if (global_value) free(global_value);
                    global_value = strdup(value);
                }
                /* Standalone match (no platform prefix) */
                else if (rom[0] == '\0' && platform[0] == '\0') {
                    if (standalone_value) free(standalone_value);
                    standalone_value = strdup(value);
                }
            }
        }
    }
    
    fclose(f);
    
    /* Return in priority order: ROM -> Platform -> Global -> Standalone */
    char *result = rom_value ? rom_value : 
                   (platform_value ? platform_value : 
                   (global_value ? global_value : standalone_value));
    
    if (result) {
        printf("%s\n", result);
        if (rom_value) free(rom_value);
        if (platform_value) free(platform_value);
        if (global_value) free(global_value);
        if (standalone_value) free(standalone_value);
        return 0;
    }
    
    /* Cleanup */
    if (rom_value) free(rom_value);
    if (platform_value) free(platform_value);
    if (global_value) free(global_value);
    if (standalone_value) free(standalone_value);
    
    /* Not found - return nothing (empty output) */
    return 1;
}

/* Set hierarchical setting - preserves file structure, comments, and order */
int cmd_ee_set(const char *setting_key, const char *setting_value, 
               const char *platform_name, const char *rom_name) {
    const char *conf_file = get_ee_conf();
    if (!conf_file) return 1;
    
    /* Read entire file into memory, preserving everything */
    FILE *f = fopen(conf_file, "r");
    if (!f) {
        fprintf(stderr, "Error: Cannot read %s\n", conf_file);
        return 1;
    }
    
    char **lines = NULL;
    int line_count = 0;
    int line_capacity = 100;
    lines = malloc(sizeof(char*) * line_capacity);
    
    char buffer[MAX_LINE];
    int found = 0;
    
    while (fgets(buffer, sizeof(buffer), f)) {
        if (line_count >= line_capacity) {
            line_capacity *= 2;
            lines = realloc(lines, sizeof(char*) * line_capacity);
        }
        
        char platform[MAX_KEY], rom[MAX_KEY], key[MAX_KEY], value[MAX_VALUE];
        int is_target = 0;
        
        /* Try to parse, but keep original line regardless */
        char *line_copy = strdup(buffer);
        if (parse_ee_line(line_copy, platform, rom, key, value)) {
            /* Check if this is the line we want to update */
            if (strcmp(key, setting_key) == 0 && strcmp(platform, platform_name) == 0) {
                if (rom_name && rom_name[0] != '\0') {
                    /* Looking for ROM-specific: must match ROM exactly */
                    if (rom[0] != '\0' && strcmp(rom, rom_name) == 0) {
                        is_target = 1;
                    }
                } else {
                    /* Looking for platform-specific: must NOT have a ROM */
                    if (rom[0] == '\0') {
                        is_target = 1;
                    }
                }
            }
        }
        free(line_copy);
        
        if (is_target) {
            /* Update this line, preserving format as much as possible */
            found = 1;
            char new_line[MAX_LINE];
            if (rom_name && rom_name[0] != '\0') {
                /* ROM-specific: platform["rom"].key=value */
                snprintf(new_line, sizeof(new_line), "%s[\"%s\"].%s=%s\n", 
                         platform_name, rom_name, setting_key, setting_value);
            } else if (platform_name && platform_name[0] != '\0') {
                /* Platform-specific: platform.key=value */
                snprintf(new_line, sizeof(new_line), "%s.%s=%s\n", 
                         platform_name, setting_key, setting_value);
            } else {
                /* Standalone: key=value (no platform prefix) */
                snprintf(new_line, sizeof(new_line), "%s=%s\n", 
                         setting_key, setting_value);
            }
            lines[line_count++] = strdup(new_line);
        } else {
            /* Keep original line exactly as-is (comments, blank lines, etc) */
            lines[line_count++] = strdup(buffer);
        }
    }
    
    fclose(f);
    
    /* If not found, append new line at the end */
    if (!found) {
        if (line_count >= line_capacity) {
            line_capacity++;
            lines = realloc(lines, sizeof(char*) * line_capacity);
        }
        
        char new_line[MAX_LINE];
        if (rom_name && rom_name[0] != '\0') {
            /* ROM-specific: platform["rom"].key=value */
            snprintf(new_line, sizeof(new_line), "%s[\"%s\"].%s=%s\n", 
                     platform_name, rom_name, setting_key, setting_value);
        } else if (platform_name && platform_name[0] != '\0') {
            /* Platform-specific: platform.key=value */
            snprintf(new_line, sizeof(new_line), "%s.%s=%s\n", 
                     platform_name, setting_key, setting_value);
        } else {
            /* Standalone: key=value (no platform prefix) */
            snprintf(new_line, sizeof(new_line), "%s=%s\n", 
                     setting_key, setting_value);
        }
        lines[line_count++] = strdup(new_line);
    }
    
    /* Write back atomically */
    char temp_file[1024];
    snprintf(temp_file, sizeof(temp_file), "%s.tmp", conf_file);
    
    f = fopen(temp_file, "w");
    if (!f) {
        fprintf(stderr, "Error: Cannot write to %s\n", temp_file);
        for (int i = 0; i < line_count; i++) free(lines[i]);
        free(lines);
        return 1;
    }
    
    for (int i = 0; i < line_count; i++) {
        fputs(lines[i], f);
        free(lines[i]);
    }
    free(lines);
    
    fclose(f);
    
    /* Atomic rename */
    if (rename(temp_file, conf_file) != 0) {
        fprintf(stderr, "Error: Cannot update %s\n", conf_file);
        unlink(temp_file);
        return 1;
    }
    
    return 0;
}

/* Set a setting */
int cmd_set(const char *key, const char *value, const char *output_file) {
    const char *conf_file = output_file ? output_file : get_ra_conf();
    if (!conf_file) return 1;
    
    HashMap *config = hashmap_create();
    
    /* Load existing config (create new if doesn't exist) */
    load_config(conf_file, config);
    
    /* Set the value */
    hashmap_put(config, key, value);
    
    /* Write back */
    if (!write_config(conf_file, config)) {
        hashmap_free(config);
        return 1;
    }
    
    hashmap_free(config);
    return 0;
}

/* Read a setting */
int cmd_read(const char *key, const char *input_file) {
    const char *conf_file = input_file ? input_file : get_ra_conf();
    if (!conf_file) return 1;
    
    HashMap *config = hashmap_create();
    
    if (!load_config(conf_file, config)) {
        fprintf(stderr, "Error: Cannot read %s\n", conf_file);
        hashmap_free(config);
        return 1;
    }
    
    const char *value = hashmap_get(config, key);
    if (value) {
        printf("%s\n", value);
        hashmap_free(config);
        return 0;
    }
    
    hashmap_free(config);
    /* Key not found - return nothing (empty output) */
    return 1;
}

/* Merge changes */
int cmd_merge(const char *changes_file, const char *output_file) {
    const char *base_file = output_file;
    
    /* If no output specified, use RA_CONF */
    if (!base_file) {
        base_file = get_ra_conf();
        if (!base_file) return 1;
    }
    
    HashMap *config = hashmap_create();
    
    /* Load base config */
    if (!load_config(base_file, config)) {
        fprintf(stderr, "Error: Cannot read %s\n", base_file);
        hashmap_free(config);
        return 1;
    }
    
    /* Apply changes */
    if (!load_config(changes_file, config)) {
        fprintf(stderr, "Error: Cannot read %s\n", changes_file);
        hashmap_free(config);
        return 1;
    }
    
    /* Write merged config */
    if (!write_config(base_file, config)) {
        hashmap_free(config);
        return 1;
    }
    
    hashmap_free(config);
    return 0;
}

void print_usage(const char *prog) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "  RetroArch config:\n");
    fprintf(stderr, "    %s -s <key> -v <value> [-o file]  Set a setting\n", prog);
    fprintf(stderr, "    %s -r <key> [-o file]             Read a setting\n", prog);
    fprintf(stderr, "    %s -i <changes.cfg> [-o out]      Merge changes\n", prog);
    fprintf(stderr, "\n");
    fprintf(stderr, "  EmuELEC emuelec.conf config:\n");
    fprintf(stderr, "    %s -e -s <key> -v <value> -p <platform> [-m <rom>]\n", prog);
    fprintf(stderr, "                                   Set setting (uses $EE_CONF)\n");
    fprintf(stderr, "    %s -e -r <key> -p <platform> [-m <rom>]\n", prog);
    fprintf(stderr, "                                   Read setting with priority:\n");
    fprintf(stderr, "                                   ROM -> Platform -> Global -> Standalone\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Environment variables:\n");
    fprintf(stderr, "  RA_CONF - path to retroarch.cfg (default: /storage/.config/retroarch/retroarch.cfg)\n");
    fprintf(stderr, "  EE_CONF - path to emuelec.conf (default: /storage/.config/emuelec/configs/emuelec.conf)\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "Note: -o specifies output file (for -s/-r, uses $RA_CONF if not specified)\n");
}

int main(int argc, char *argv[]) {
    int opt;
    char *set_key = NULL, *set_value = NULL;
    char *read_key = NULL;
    char *input_file = NULL, *output_file = NULL;
    char *platform = NULL, *rom = NULL;
    int use_ee_conf = 0;
    
    if (argc < 2) {
        print_usage(argv[0]);
        return 1;
    }
    
    /* Parse arguments */
    while ((opt = getopt(argc, argv, "s:v:r:i:o:p:m:eh")) != -1) {
        switch (opt) {
            case 's':
                set_key = optarg;
                break;
            case 'v':
                set_value = optarg;
                break;
            case 'r':
                read_key = optarg;
                break;
            case 'i':
                input_file = optarg;
                break;
            case 'o':
                output_file = optarg;
                break;
            case 'p':
                platform = optarg;
                break;
            case 'm':
                rom = optarg;
                break;
            case 'e':
                use_ee_conf = 1;
                break;
            case 'h':
                print_usage(argv[0]);
                return 0;
            default:
                print_usage(argv[0]);
                return 1;
        }
    }
    
    /* Execute command */
    if (use_ee_conf) {
        /* EmuELEC hierarchical config operations */
        
        /* Treat empty strings as NULL */
        if (platform && platform[0] == '\0') platform = NULL;
        if (rom && rom[0] == '\0') rom = NULL;
        
        /* For simple keys like "global.timezone", auto-extract platform if no -p specified */
        if (!platform) {
            /* Check if key contains a dot - if so, extract platform and key parts */
            char *key_to_use = set_key ? set_key : read_key;
            if (key_to_use && strchr(key_to_use, '.')) {
                char *dot = strchr(key_to_use, '.');
                int len = dot - key_to_use;
                char auto_platform[MAX_KEY];
                char auto_key[MAX_KEY];
                
                strncpy(auto_platform, key_to_use, len);
                auto_platform[len] = '\0';
                strncpy(auto_key, dot + 1, MAX_KEY - 1);
                auto_key[MAX_KEY - 1] = '\0';
                
                /* Use extracted platform and key */
                if (set_value) {
                    return cmd_ee_set(auto_key, set_value, auto_platform, rom);
                } else {
                    return cmd_ee_read(auto_key, auto_platform, rom);
                }
            }
            
            /* No dot found - treat as standalone key (search all entries) */
            if (read_key) {
                return cmd_ee_read(read_key, "", rom);
            } else if (set_key && set_value) {
                return cmd_ee_set(set_key, set_value, "", rom);
            }
            
            fprintf(stderr, "Error: -p <platform> required for platform-specific operations\n");
            fprintf(stderr, "       (or use 'platform.setting' format for auto-detection)\n");
            return 1;
        }
        
        if (set_key && set_value) {
            return cmd_ee_set(set_key, set_value, platform, rom);
        } else if (read_key) {
            return cmd_ee_read(read_key, platform, rom);
        } else {
            fprintf(stderr, "Error: -s or -r required with -e\n");
            print_usage(argv[0]);
            return 1;
        }
    } else {
        /* RetroArch config operations */
        if (set_key && set_value) {
            return cmd_set(set_key, set_value, output_file);
        } else if (read_key) {
            return cmd_read(read_key, output_file);
        } else if (input_file) {
            return cmd_merge(input_file, output_file);
        } else {
            print_usage(argv[0]);
            return 1;
        }
    }
}
