#!/usr/bin/env bash

export LD_LIBRARY_PATH="/emuelec/lib32:$LD_LIBRARY_PATH"
exec /usr/bin/retroarch32 "$@"
