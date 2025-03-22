#!/bin/bash

cd /storage/roms/ports/shovelknight/64

export LIBGL_NOBANNER=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX64_LOG=0
export BOX64_LD_LIBRARY_PATH=/emuelec/bin/box64/lib/
export BOX64_DYNAREC=1
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/emuelec/bin/box64/lib/
fbfix
/emuelec/bin/box64/box64 ShovelKnight
