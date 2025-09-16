# taken from wirbelscan-2017.06.04 backup/Makefile.old
# -- v20120526, Winfried Koehler --

PLUGIN = wirbelscan

VERSION = $(shell grep 'static const char \*VERSION *=' $(PLUGIN).c | awk '{ print $$6 }' | sed -e 's/[";]//g')

CXX      ?= g++
CXXFLAGS ?= -g -O3 -Wall -Wextra -Werror=overloaded-virtual -Wformat=2 -Wswitch-default -fstack-protector-all -D_FORTIFY_SOURCE=2

VDRDIR ?= ../../..
LIBDIR ?= ../../lib
TMPDIR ?= /tmp

include $(VDRDIR)/Make.global

-include $(VDRDIR)/Make.config

APIVERSION = $(shell sed -ne '/define APIVERSION/s/^.*"\(.*\)".*$$/\1/p' $(VDRDIR)/config.h)

ARCHIVE = $(PLUGIN)-$(VERSION)
PACKAGE = vdr-$(ARCHIVE)

INCLUDES += -I$(VDRDIR)/include

DEFINES += -D_GNU_SOURCE -DPLUGIN_NAME_I18N='"$(PLUGIN)"'

UNCRUSTIFY_FILES = scanner.c scanner.h scanfilter.c scanfilter.h statemachine.h statemachine.c

OBJS = $(PLUGIN).o common.o menusetup.o satellites.o scanner.o dvb_wrapper.o
OBJS += scanfilter.o statemachine.o countries.o

all: libvdr-$(PLUGIN).so i18n

%.o: %.c
	$(CXX) -std=c++11 $(CXXFLAGS) -c $(DEFINES) $(INCLUDES) $<

MAKEDEP = $(CXX) -MM -MG
DEPFILE = .dependencies
$(DEPFILE): Makefile
	@$(MAKEDEP) $(DEFINES) $(INCLUDES) $(OBJS:%.o=%.c) > $@

-include $(DEPFILE)

PODIR     = po
LOCALEDIR = $(VDRDIR)/locale
I18Npo    = $(wildcard $(PODIR)/*.po)
I18Nmsgs  = $(addprefix $(LOCALEDIR)/, $(addsuffix /LC_MESSAGES/vdr-$(PLUGIN).mo, $(notdir $(foreach file, $(I18Npo), $(basename $(file))))))
I18Npot   = $(PODIR)/$(PLUGIN).pot

%.mo: %.po
	@msgfmt -c -o $@ $<

$(I18Npot): $(wildcard *.c)
	@xgettext -C -cTRANSLATORS --no-wrap --no-location -k -ktr -ktrNOOP --package-name=vdr-$(PLUGIN) --package-version=$(VERSION) --msgid-bugs-address='<see README>' -o $@ $^

%.po: $(I18Npot)
	@msgmerge -U --no-wrap --no-location --backup=none -q $@ $<
	@touch $@

$(I18Nmsgs): $(LOCALEDIR)/%/LC_MESSAGES/vdr-$(PLUGIN).mo: $(PODIR)/%.mo
	@mkdir -p $(dir $@)
	@cp $< $@

.PHONY: i18n
i18n: $(I18Nmsgs) $(I18Npot)

libvdr-$(PLUGIN).so: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared $(OBJS) -o $@
	@cp --remove-destination $@ $(LIBDIR)/$@.$(APIVERSION)

perm:
	@chmod 644 *.{c,h,html} COPYING HISTORY README TODO Makefile
	@chmod 755 po/


dist: $(I18Npo) clean perm
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@mkdir $(TMPDIR)/$(ARCHIVE)
	@cp -a * $(TMPDIR)/$(ARCHIVE)
	@tar czf $(PACKAGE).tgz -C $(TMPDIR) $(ARCHIVE)
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@echo Distribution package created as $(PACKAGE).tgz

