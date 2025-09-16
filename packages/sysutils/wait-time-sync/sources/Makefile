# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

.PHONY: all
all: wait-time-sync

PREFIX = /usr

.PHONY: install
install: wait-time-sync
	install -d $(DESTDIR)$(PREFIX)/bin
	install $< $(DESTDIR)$(PREFIX)/bin
