Name

tmpfiles.d — Configuration for creation, deletion and cleaning of volatile and temporary files

Synopsis

/etc/tmpfiles.d/*.conf

/run/tmpfiles.d/*.conf

/usr/lib/tmpfiles.d/*.conf

Description

systemd-tmpfiles uses the configuration files from the above directories to describe the creation, cleaning and removal of volatile and temporary files and directories which usually reside in directories such as /run or /tmp.
Configuration Format

Each configuration file shall be named in the style of <program>.conf. Files in /etc/ override files with the same name in /usr/lib/ and /run/. Files in /run/ override files with the same name in /usr/lib/. Packages should install their configuration files in /usr/lib/. Files in /etc/ are reserved for the local administrator, who may use this logic to override the configuration files installed by vendor packages. All configuration files are sorted by their filename in alphabetical order, regardless in which of the directories they reside, to guarantee that a specific configuration file takes precedence over another file with an alphabetically later name.

If the administrator wants to disable a configuration file supplied by the vendor the recommended way is to place a symlink to /dev/null in /etc/tmpfiles.d/ bearing the same filename.

The configuration format is one line per path containing action, path, mode, ownership, age and argument fields:

Type Path        Mode UID  GID  Age Argument
d    /run/user   0755 root root 10d -
L    /tmp/foobar -    -    -    -   /dev/null

Type

f
    Create a file if it doesn't exist yet (optionally writing a short string into it, if the argument parameter is passed)

F
    Create or truncate a file (optionally writing a short string into it, if the argument parameter is passed)

w
    Write the argument parameter to a file, if the file exists. Lines of this type accept shell-style globs in place of normal path names. The argument parameter will be written without a trailing newline. C-style backslash escapes are interpreted.

d
    Create a directory if it doesn't exist yet

D
    Create or empty a directory

p
    Create a named pipe (FIFO) if it doesn't exist yet

L
    Create a symlink if it doesn't exist yet

c
    Create a character device node if it doesn't exist yet

b
    Create a block device node if it doesn't exist yet

x
    Ignore a path during cleaning. Use this type to exclude paths from clean-up as controlled with the Age parameter. Note that lines of this type do not influence the effect of r or R lines. Lines of this type accept shell-style globs in place of normal path names.

X
    Ignore a path during cleanup. Use this type to prevent path removal as controlled with the Age parameter. Note that if path is a directory, content of a directory is not excluded from clean-up, only directory itself. Lines of this type accept shell-style globs in place of normal path names.

r
    Remove a file or directory if it exists. This may not be used to remove non-empty directories, use R for that. Lines of this type accept shell-style globs in place of normal path names.

R
    Recursively remove a path and all its subdirectories (if it is a directory). Lines of this type accept shell-style globs in place of normal path names.

z
    Restore SELinux security context label and set ownership and access mode of a file or directory if it exists. Lines of this type accept shell-style globs in place of normal path names. 

Z
    Recursively restore SELinux security context label and set ownership and access mode of a path and all its subdirectories (if it is a directory). Lines of this type accept shell-style globs in place of normal path names.

Mode

The file access mode to use when creating this file or directory. If omitted or when set to - the default is used: 0755 for directories, 0644 for all other file objects. For z, Z lines if omitted or when set to - the file access mode will not be modified. This parameter is ignored for x, r, R, L lines.
UID, GID

The user and group to use for this file or directory. This may either be a numeric user/group ID or a user or group name. If omitted or when set to - the default 0 (root) is used. For z, Z lines when omitted or when set to - the file ownership will not be modified. These parameters are ignored for x, r, R, L lines.
Age

The date field, when set, is used to decide what files to delete when cleaning. If a file or directory is older than the current time minus the age field it is deleted. The field format is a series of integers each followed by one of the following postfixes for the respective time units:

s, min, h, d, w, ms, m, us

If multiple integers and units are specified the time values are summed up. If an integer is given without a unit, s is assumed.

When the age is set to zero, the files are cleaned unconditionally.

The age field only applies to lines starting with d, D and x. If omitted or set to - no automatic clean-up is done.

If the age field starts with a tilde character (~) the clean-up is only applied to files and directories one level inside the directory specified, but not the files and directories immediately inside it.
Argument

For L lines determines the destination path of the symlink. For c, b determines the major/minor of the device node, with major and minor formatted as integers, separated by :, e.g. "1:3". For f, F, w may be used to specify a short string that is written to the file, suffixed by a newline. Ignored for all other lines.
Example

Example 1. /etc/tmpfiles.d/screen.conf example

screen needs two directories created at boot with specific modes and ownership.

d /var/run/screens  1777 root root 10d
d /var/run/uscreens 0755 root root 10d12h


See Also

systemd(1), systemd-tmpfiles(8), systemd-delta(1) 
