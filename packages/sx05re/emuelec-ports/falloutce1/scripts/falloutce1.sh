
if ! test -f /storage/roms/ports/falloutce1/fallout.cfg; then
  cp /usr/config/emuelec/configs/falloutce1/fallout.cfg /storage/roms/ports/falloutce1/
fi

fallout-ce > /emuelec/logs/emuelec.log 2>&1
