#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2013 Stephan Raue (stephan@openelec.tv)

. /etc/profile

# start locking mechanism - allows only one instance to be run at a time
HDHR_LOCKFILE="/var/lock/userspace-driver-hdhomerun.lck"
HDHR_LOCKFD=99
# obtain an exclusive lock
exlock() { eval "exec $HDHR_LOCKFD>\"$HDHR_LOCKFILE\""; flock -x $HDHR_LOCKFD; }
# drop a lock
unlock() { flock -u $HDHR_LOCKFD; flock -xn $HDHR_LOCKFD && rm -f "$HDHR_LOCKFILE"; }
# end locking mechanism

# exclusive lock
exlock

HDHR_ADDON_DIR="$HOME/.kodi/addons/driver.dvb.hdhomerun"
HDHR_ADDON_HOME="$HOME/.kodi/userdata/addon_data/driver.dvb.hdhomerun"
HDHR_ADDON_SETTINGS="$HDHR_ADDON_HOME/settings.xml"

# modules are not automatically loaded
modprobe dvb_hdhomerun
modprobe dvb_hdhomerun_fe

mkdir -p $HDHR_ADDON_HOME

if [ ! -f "$HDHR_ADDON_HOME/dvbhdhomerun.sample" ]; then
  cp $HDHR_ADDON_DIR/config/* $HDHR_ADDON_HOME/
fi

if [ ! -f "$HDHR_ADDON_SETTINGS" ]; then
  cp $HDHR_ADDON_DIR/settings-default.xml $HDHR_ADDON_SETTINGS
fi

mkdir -p /var/config

# check settings version
XML_SETTINGS_VER="$(xmlstarlet sel -t -m settings -v @version $HDHR_ADDON_SETTINGS)"
if [ "$XML_SETTINGS_VER" = "2" ]; then
  xmlstarlet sel -t -m settings/setting -v @id -o "=\"" -v . -o "\"" -n "$HDHR_ADDON_SETTINGS" > /var/config/hdhomerun-addon.conf
else
  xmlstarlet sel -t -m settings -m setting -v @id -o "=\"" -v @value -o "\"" -n "$HDHR_ADDON_SETTINGS" > /var/config/hdhomerun-addon.conf
fi

. /var/config/hdhomerun-addon.conf

if [ -z "$(pidof userhdhomerun)" ]; then
  if [ "$ENABLE_TUNER_TYPES" = "true" ]; then
    DVBHDHOMERUN_CONF_TMP=/tmp/dvbhdhomerun.conf
    touch $HDHR_ADDON_HOME/dvbhdhomerun.conf
    cp $HDHR_ADDON_HOME/dvbhdhomerun.conf $DVBHDHOMERUN_CONF_TMP

    # get tuner serial numbers
    SERIALS=$(cat /var/config/hdhomerun-addon.conf | sed -n 's|^ATTACHED_TUNER_\(.*\)_DVBMODE=.*|\1|gp' | sort | uniq)
    . /var/config/hdhomerun-addon.conf

    for SERIAL_UNIQ in $SERIALS; do
      DVBMODE=$(eval echo \$ATTACHED_TUNER_${SERIAL_UNIQ}_DVBMODE)
      FULLNAME=$(eval echo \$ATTACHED_TUNER_${SERIAL_UNIQ}_FULLNAME)
      DISABLE=$(eval echo \$ATTACHED_TUNER_${SERIAL_UNIQ}_DISABLE)
      NUMBERS=$(eval echo \$ATTACHED_TUNER_${SERIAL_UNIQ}_NUMBERS)

      NUMBERS=$(( $NUMBERS -1 ))
      NUMBERS=$(( $NUMBERS *1 ))

      for i in $(seq 0 $NUMBERS); do
        SERIAL="$SERIAL_UNIQ-$i"

        [ "$DVBMODE" = "auto" ] && DVBMODE=""

        # remove setttings for this tuner
        awk -v val="[$SERIAL]" '$0 == val {flag=1; next} /^tuner_type=|^use_full_name=|^disable=|^#|^$/{if (flag==1) next} /.*/{flag=0; print}' $DVBHDHOMERUN_CONF_TMP >${DVBHDHOMERUN_CONF_TMP}-types
        mv ${DVBHDHOMERUN_CONF_TMP}-types $DVBHDHOMERUN_CONF_TMP
        echo "" >>$DVBHDHOMERUN_CONF_TMP
        # remove empty lines at the end of file
        sed -i -e ':a' -e '/^\n*$/{$d;N;};/\n$/ba' $DVBHDHOMERUN_CONF_TMP

        ADDNEW=true
        if [ -n "$DVBMODE" ]; then
          [ $ADDNEW = true ] && ADDNEW=false && echo "[$SERIAL]" >>$DVBHDHOMERUN_CONF_TMP
          echo "tuner_type=$DVBMODE" >>$DVBHDHOMERUN_CONF_TMP
        fi
        if [ "$FULLNAME" = "true" ]; then
          [ $ADDNEW = true ] && ADDNEW=false && echo "[$SERIAL]" >>$DVBHDHOMERUN_CONF_TMP
          echo "use_full_name=true" >>$DVBHDHOMERUN_CONF_TMP
        fi
        if [ "$DISABLE" = "true" ]; then
          [ $ADDNEW = true ] && ADDNEW=false && echo "[$SERIAL]" >>$DVBHDHOMERUN_CONF_TMP
          echo "disable=true" >>$DVBHDHOMERUN_CONF_TMP
        fi

        echo "" >>$DVBHDHOMERUN_CONF_TMP
      done
    done

    # remove logging from libhdhomerun library
    awk -v val="[libhdhomerun]" '$0 == val {flag=1; next} /^enable=|^logfile=|^#|^$/{if (flag==1) next} /.*/{flag=0; print}' $DVBHDHOMERUN_CONF_TMP >${DVBHDHOMERUN_CONF_TMP}-log
    mv ${DVBHDHOMERUN_CONF_TMP}-log $DVBHDHOMERUN_CONF_TMP
    echo "" >>$DVBHDHOMERUN_CONF_TMP
    # remove empty lines at the end of file
    sed -i -e ':a' -e '/^\n*$/{$d;N;};/\n$/ba' $DVBHDHOMERUN_CONF_TMP

    if [ "$LIBHDHOMERUN_LOG" = "true" ]; then
      cat >>$DVBHDHOMERUN_CONF_TMP << EOF

[libhdhomerun]
enable=true
logfile=/var/log/dvbhdhomerun_libhdhomerun.log

EOF
    fi

    md5_1=$(md5sum -b $DVBHDHOMERUN_CONF_TMP | awk '{print $1}')
    md5_2=$(md5sum -b $HDHR_ADDON_HOME/dvbhdhomerun.conf | awk '{print $1}')
    if [ "$md5_1" != "$md5_2" ]; then
      # file changed - copy to addon home
      cp $DVBHDHOMERUN_CONF_TMP $HDHR_ADDON_HOME/dvbhdhomerun.conf
    fi
  fi

  rm -f /tmp/dvbhdhomerun
  if [ -f $HDHR_ADDON_HOME/dvbhdhomerun.conf ]; then
    ln -s $HDHR_ADDON_HOME/dvbhdhomerun.conf /tmp/dvbhdhomerun
  fi

  [ -z "$PRE_WAIT" ] && PRE_WAIT=0
  PRE_WAIT=$(( $PRE_WAIT *1 ))
  [ -z "$POST_WAIT" ] && POST_WAIT=0
  POST_WAIT=$(( $POST_WAIT *1 ))

  logger -t HDHomeRun "### Pre wait for $PRE_WAIT sec ###"
  sleep $PRE_WAIT

  mkdir -p /var/log/
  rm -f /var/log/dvbhdhomerun.log

  if [ "$USERHDHOMERUN_LOG" = "true" ]; then
    userhdhomerun -f
  else
    userhdhomerun -f -d
  fi

  logger -t HDHomeRun "### Post wait for $POST_WAIT sec ###"
  sleep $POST_WAIT

# save adapter names in background
(
  sleep 4
  sn_old=$(cat $HDHR_ADDON_HOME/adapters.txt 2>/dev/null)
  sn_new=$(grep "Name of device: " /var/log/dvbhdhomerun.log)
  if [ "$sn_old" != "$sn_new" ]; then
    echo -n $sn_new >$HDHR_ADDON_HOME/adapters.txt
  fi
)&
fi

logger -t HDHomeRun "### HDHomeRun ready ###"

# unlock the lock
unlock
