#!/bin/bash

. /etc/profile

directory="/storage/roms"

gamedir="/$directory/ports/celeste"
gameassembly="Celeste.exe"

# Untar port files
if [[ ! -f "${gamedir}/celeste-repacker" ]]; then
tar -xf "/emuelec/configs/celeste.tar.xz" -C "$directory/ports"
fi

# check if required fmodengine files are installed
if [[ -f "${gamedir}/fmodstudioapi20216linux.tar.gz" ]] && [[ ! -f "${gamedir}/libs/libfmod.so.13" ]]; then
    mkdir -p "/emuelec/configs/fmod/"
    tar -xvf "${gamedir}/fmodstudioapi20216linux.tar.gz" -C "/emuelec/configs/fmod/"
    cd "/emuelec/configs/fmod/"
    tar -xvf "fmodstudioapi20216linux.tar.gz"
    cp fmodstudioapi20216linux/api/core/lib/arm64/libfmod.so.13.16 "${gamedir}/libs/libfmod.so.13"
    cp fmodstudioapi20216linux/api/studio/lib/arm64/libfmodstudio.so.13.16 "${gamedir}/libs/libfmodstudio.so.13"
    rm -rf "/emuelec/configs/fmod/"
fi

# Double check if required fmod files are installed, because why not. 
if [[ ! -f "${gamedir}/libs/libfmod.so.13" ]] || [[ ! -f "${gamedir}/libs/libfmodstudio.so.13" ]]; then
    text_viewer -e -w -t "ERROR!" -f 24 -m "Fmod does not exist on ${gamedir}/libs\n\nYou need to provide the fmodengine files from https://www.fmod.com/ then copy the file fmodstudioapi20216linux.tar.gz to ${gamedir}"
    exit 0
fi

# check if required game files are installed
if [[ ! -f "${gamedir}/gamedata/${gameassembly}" ]]; then
    text_viewer -e -w -t "ERROR!" -f 24 -m "Celeste Game Data does not exist on ${gamedir}/gamedata\n\nYou need to provide your own game data from your copy of the game"
    exit 0
fi

cd "$gamedir/gamedata"

# Setup mono
monodir="/emuelec/mono"
monofile="$directory/ports/mono-6.12.0.122-aarch64.squashfs"

if [ ! -e "${monofile}" ]; then
monourl="https://github.com/PortsMaster/PortMaster-Hosting/releases/download/large-files/mono-6.12.0.122-aarch64.squashfs"
    text_viewer -y -w -f 24 -t "MONO does not exists!" -m "It seems this is the first time you are launching Celeste or the MONO file does not exists\n\nMONO is about 260 MB, and you need to be connected to the internet\n\nIMPORTANT: THIS IS NOT THE GAME DATA! YOU STILL NEED TO PROVIDE THIS FROM YOUR COPY OF THE ITCH.IO VERSION OF THE GAME!\n\nDownload and continue?"
        if [[ $? == 21 ]]; then
            ee_console enable
            wget "${monourl}" -O "${monofile}" -q --show-progress > /dev/tty0 2>&1
            ee_console disable
        else
            exit 0
        fi
else
    mkdir -p "$monodir"
    umount "$monofile" || true
    mount "$monofile" "$monodir"
fi

# Setup savedir
export XDG_DATA_HOME=/emuelec/configs
if [ ! -L ${XDG_DATA_HOME}/Celeste ]; then
rm -rf ${XDG_DATA_HOME}/Celeste
mkdir -p ${XDG_DATA_HOME}/Celeste
ln -sfv "${gamedir}/savedata" ${XDG_DATA_HOME}/Celeste
fi

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll
cp $gamedir/libs/Celeste.exe.config $gamedir/gamedata

# Setup path and other environment variables
export FNA_PATCH="$gamedir/dlls/CelestePatches.dll"
export MONO_PATH="$gamedir/dlls"
export LD_LIBRARY_PATH="$gamedir/libs":"${monodir}/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

# For Amlogic-NG we can use the textures at full size so skip the conversion
[[ "${EE_DEVICE}" == "Amlogic-ng" ]] && touch "$gamedir/.astc_done"

# Compress all textures with ASTC codec, bringing massive vram gains
if [[ ! -f "$gamedir/.astc_done" ]]; then
	echo "Optimizing textures..." >> /dev/tty0
	"$gamedir/celeste-repacker" "$gamedir/gamedata/Content/Graphics/" --install >> /dev/tty0
	if [ $? -eq 0 ]; then
		touch "$gamedir/.astc_done"
	fi
fi

# first_time_setup
mono Celeste.exe
kill -9 $(pidof gptokeyb)
umount "$monodir"
