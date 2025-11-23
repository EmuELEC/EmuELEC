// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)
	
#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

static int (*orig_open64)(const char *pathname, int flags, ...) = NULL;

struct {
  const char *orig_path;
  const char *redir_path;
} path_mappings[] = {
  { "/dev/mmcblk0rpmb", "/var/run/mmcblk0rpmb" },
  { "/sys/class/mmc_host/mmc0/mmc0:0001/cid", "/var/run/mmc0_0001_cid" },
  { NULL, NULL }
};

static void create_file(const char *new_path) {
  if (access(new_path, F_OK) != 0) {
    FILE *file_ptr = fopen(new_path, "wb");
    if (file_ptr != NULL) {
      fclose(file_ptr);
    } else {
      fprintf(stderr, "Error: Failed to create file: %s\n", new_path);
    }
  }
}

static const char *get_redir_path(const char *pathname) {
  for (size_t i = 0;
       i < sizeof(path_mappings) / sizeof(path_mappings[0]) && path_mappings[i].orig_path != NULL;
       i++) {
    if (strcmp(pathname, path_mappings[i].orig_path) == 0) {
      const char *new_path = path_mappings[i].redir_path;
      fprintf(stderr, "tee redirecting path %s -> %s\n", pathname, new_path);
      create_file(new_path);
      return new_path;
    }
  }

  return pathname;
}

int open64(const char *pathname, int flags, ...) {
  if (!orig_open64) {
    orig_open64 = dlsym(RTLD_NEXT, "open64");
    if (!orig_open64) {
      fprintf(stderr, "Error: Failed to find original open64\n");
      return -EPERM;
    }
  }

  const char *redir_path = get_redir_path(pathname);

  if (flags & O_CREAT) {
    va_list args;
    va_start(args, flags);
    mode_t mode = va_arg(args, mode_t);
    va_end(args);
    return orig_open64(redir_path, flags, mode);
  }

  return orig_open64(redir_path, flags);
}
