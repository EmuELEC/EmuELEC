# EmuELEC  
Retro emulation for Amlogic devices.
Based on  [CoreELEC](https://github.com/CoreELEC/CoreELEC) and [Lakka](https://github.com/libretro/Lakka-LibreELEC) with tidbits from [Batocera](https://github.com/batocera-linux/batocera.linux). I just combine them with [Batocera-Emulationstation](https://github.com/batocera-linux/batocera-emulationstation) and some standalone emulators ([Advancemame](https://github.com/amadvance/advancemame), [PPSSPP](https://github.com/hrydgard/ppsspp), [Reicast](https://github.com/reicast/reicast-emulator), [Amiberry](https://github.com/midwan/amiberry) and others). 

---
[![GitHub Release](https://img.shields.io/github/release/EmuELEC/EmuELEC.svg)](https://github.com/EmuELEC/EmuELEC/releases/latest)
[![GPL-2.0 Licensed](https://shields.io/badge/license-GPL2-blue)](https://github.com/EmuELEC/EmuELEC/blob/master/licenses/GPL2.txt)
[![Discord](https://img.shields.io/badge/chat-on%20discord-7289da.svg?logo=discord)](https://discord.gg/jQWCFwTn5T)

### ⚠️**IMPORTANT**⚠️
#### EmuELEC is now aarch64 ONLY, compiling and using the ARM version after version 3.9 is no longer supported. Please have a look at the master_32bit branch if you want to build the 32-bit version.

---
## Development

### Build prerequisites

These instructions are only for Debian/Ubuntu based systems.

```
$ apt install gcc make git unzip wget xz-utils libsdl2-dev libsdl2-mixer-dev libfreeimage-dev libfreetype6-dev libcurl4-openssl-dev rapidjson-dev libasound2-dev libgl1-mesa-dev build-essential libboost-all-dev cmake fonts-droid-fallback libvlc-dev libvlccore-dev vlc-bin texinfo premake4 golang libssl-dev curl patchelf xmlstarlet default-jre xsltproc libvpx-dev rdfind
```

### Building EmuELEC
To build EmuELEC locally do the following:

```
$ git clone https://github.com/EmuELEC/EmuELEC.git
$ cd EmuELEC
$ git checkout dev
$ PROJECT=Amlogic-ce DEVICE=Amlogic-ng ARCH=aarch64 DISTRO=EmuELEC make image
```

For the Odroid GO Advance/Super:
```
$ PROJECT=Rockchip DEVICE=OdroidGoAdvance ARCH=aarch64 DISTRO=EmuELEC make image
```

Note: In some cases you may also need to install the tzdata, xfonts-utils and/or lzop packages.
```
$ apt install tzdata xfonts-utils lzop
```


**Remember to use the proper DTB for your device!**

### Submitting patches
Please create a pull request with the changes you made in the dev branch and make sure to include a brief description of what you changed and why you did it.

## Get in touch
If you have a question, suggestions for new features, or need help configuring or installing EmuELEC, please visit [our forum](https://emuelec.org/). You may also want to visit our [wiki](https://github.com/EmuELEC/EmuELEC/wiki) or join our [Discord](https://discord.gg/jQWCFwTn5T).

**EmuELEC DOES NOT INCLUDE KODI**

Please note, this is mainly a personal project, I can't guarantee it will work with your box. I've spent many hours tweaking many things and making sure everything works, but I can't test everything and some things may not work yet. Also, be aware of hardware limitations and don't expect everything to run at 60FPS (especially N64, PSP, and Reicast). I can't guarantee that changes will be incorporated to fit your specific needs, but I welcome pull requests, help testing other boxes, and fixing problems in general.  
I'm working on this project in my spare time, I'm not making any money from it, so it will take me a while to test all the changes properly, but I'll do my best to help you fix any problems you might have on other boxes, in my spare time.

## License

EmuELEC is based on CoreELEC, which in turn is licensed under the GPLv2 (and GPLv2-or-later). All original files created by the EmuELEC team are licensed as GPLv2-or-later and marked as such.

However, the distro contains many non-commercial emulators/libraries/cores/binaries and therefore **cannot be sold, bundled, offered, included in commercial products/applications or anything similar, including but not limited to Android devices, smart TVs, TV boxes, handheld devices, computers, SBCs or anything else that can run EmuELEC** with the included emulators/libraries/cores/binaries.

Also note the license section from the README from the CoreELEC team, which has been adapted for EmuELEC:

As EmuELEC includes code from many upstream projects it includes many copyright owners. EmuELEC makes NO claim of copyright on any upstream code. Patches to upstream code have the same license as the upstream project, unless specified otherwise. For a complete copyright list please checkout the source code to examine license headers. Unless expressly stated otherwise all code submitted to the EmuELEC project (in any form) is licensed under GPLv2-or-later. You are absolutely free to retain copyright. To retain copyright simply add a copyright header to each submitted code page. If you submit code that is not your own work it is your responsibility to place a header stating the copyright.

### Branding

All EmuELEC related logos, videos, images and branding in general are the sole property of EmuELEC. They are all copyrighted by the EmuELEC team and may not be included in any commercial application without proper permission (yes, that includes EmuELEC bundled with ROMS for donations!).

However, you have permission to include/modify them in your forks/projects as long as they are fully open source and freely available (i.e. not under a bunch of "click on this sponsored ad to get the link!" buttons) and do not violate any copyright laws, even if you receive donations for such a project (we are not against donations for honest people!), we just ask that you give us the appropriate credits and if possible a link to this repo.

Happy retrogaming!
