/* LICENSE>>
Copyright 2020 Soji Yamakawa (CaptainYS, http://www.ysflight.com)

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<< LICENSE */

#define GL_SILENCE_DEPRECATION

#include <stdio.h>
#ifdef _WIN32
	#include <direct.h>
	#define chdir _chdir
	#define getcwd _getcwd
#else
	#include <unistd.h>
#endif

#ifndef FSSIMPLEWINDOW_DONT_INCLUDE_OPENGL_HEADERS
#define FSSIMPLEWINDOW_DONT_INCLUDE_OPENGL_HEADERS
#endif
#include "fssimplewindow.h"
#include "fssimplewindow_connection.h"

// G** D*** Windows headers! >>
#ifdef REG_NONE
#undef REG_NONE
#endif
#ifdef OUT
#undef OUT
#endif
// *od *amn Windows headers! <<

#include "cpputil.h"
#include "towns.h"
#include "icons.h"
#include "ysgamepad.h"
#include "townsparam.h"

#ifndef TSUGARU_I486_HIGH_FIDELITY
#define WINDOW_TITLE "FM Towns Emulator - TSUGARU"
#else
#define WINDOW_TITLE "FM Towns Emulator - TSUGARU (High-Fidelity Mode)"
#endif


FsSimpleWindowConnection::FsSimpleWindowConnection()
{
	FSKEYtoTownsKEY=new unsigned int [FSKEY_NUM_KEYCODE];
	FSKEYState=new unsigned int [FSKEY_NUM_KEYCODE];

	SetKeyboardMode(TOWNS_KEYBOARD_MODE_DIRECT);
	SetKeyboardLayout(KEYBOARD_LAYOUT_US);

	for(int i=0; i<FSKEY_NUM_KEYCODE; ++i)
	{
		FSKEYState[i]=0;
	}
}
FsSimpleWindowConnection::~FsSimpleWindowConnection()
{
	delete [] FSKEYtoTownsKEY;
	delete [] FSKEYState;
}

std::string FsSimpleWindowConnection::GetProgramResourceDirectory(void) const
{
	// SDL2/Linux port: derive the resource directory from /proc/self/exe
	// instead of FsChangeToProgramDir (which is a no-op in fssimplenowindow).
	char buf[1024];
	auto len=readlink("/proc/self/exe",buf,sizeof(buf)-1);
	if(0<len)
	{
		buf[len]=0;
		std::string path=buf;
		auto pos=path.find_last_of('/');
		if(std::string::npos!=pos)
		{
			return path.substr(0,pos);
		}
	}
	return ".";
}

/* virtual */ std::vector <std::string> FsSimpleWindowConnection::MakeDefaultKeyMappingText(void) const
{
	unsigned int FSKEYtoTownsKEY[FSKEY_NUM_KEYCODE];
	MakeKeyMapFromLayout(FSKEYtoTownsKEY,KEYBOARD_LAYOUT_US);
	std::vector <std::string> text;
	text.push_back("#HostKeyCode            TownsKeyCode");
	for(int i=0; i<FSKEY_NUM_KEYCODE; ++i)
	{
		text.push_back("");
		text.back()+=FsKeyCodeToString(i);
		text.back()+=" ";
		while(text.back().size()<24)
		{
			text.back()+=" ";
		}
		text.back()+=TownsKeyCodeToStr(FSKEYtoTownsKEY[i]);
	}
	text.push_back("# Available Host Key Code");
	for(int i=0; i<FSKEY_NUM_KEYCODE; ++i)
	{
		text.push_back(std::string("#")+FsKeyCodeToString(i));
	}
	text.push_back("# Available Towns Key Code");
	for(int i=0; i<256; ++i)
	{
		auto str=TownsKeyCodeToStr(i);
		if(""!=str)
		{
			text.push_back("#"+str);
		}
	}
	return text;
}

/* virtual */ std::vector <std::string> FsSimpleWindowConnection::MakeKeyMappingText(void) const
{
	std::vector <std::string> text;
	for(int i=0; i<FSKEY_NUM_KEYCODE; ++i)
	{
		text.push_back("");
		text.back()+=FsKeyCodeToString(i);
		text.back()+=" ";
		while(text.back().size()<24)
		{
			text.back()+=" ";
		}
		text.back()+=TownsKeyCodeToStr(FSKEYtoTownsKEY[i]);
	}
	return text;
}
/* virtual */ void FsSimpleWindowConnection::LoadKeyMappingFromText(const std::vector <std::string> &text)
{
	for(int i=0; i<FSKEY_NUM_KEYCODE; ++i)
	{
		FSKEYtoTownsKEY[i]=TOWNS_JISKEY_NULL;
	}
	for(auto str : text)
	{
		if('#'==str[0])
		{
			continue;
		}
		auto argv=cpputil::Parser(str.c_str());
		if(2==argv.size())
		{
			auto fsKey=FsStringToKeyCode(argv[0].c_str());
			auto townsKey=TownsStrToKeyCode(argv[1]);
			FSKEYtoTownsKEY[fsKey]=townsKey;
		}
	}
}

/* virtual */ void FsSimpleWindowConnection::Start(void)
{
}
/* virtual */ void FsSimpleWindowConnection::Stop(void)
{
}

/* virtual */ void FsSimpleWindowConnection::DevicePolling(class FMTownsCommon &towns)
{
	// WindosInterface class is now in charge of updating device status.
	// Before DevicePolling is called, TownsThread::VMMainLoop calls WindowInterface::Communicate
	// to transfer cached events and device status to this->windowEvent.

	bool ctrlKey=(0!=windowEvent.keyState[FSKEY_CTRL]);
	bool shiftKey=(0!=windowEvent.keyState[FSKEY_SHIFT]);

	if(true!=Outside_World::gameDevsNeedUpdateCached)
	{
		std::cout << "Squawk!  Game Devices that need updates not cached!" << std::endl;
	}

	for(auto &mos : windowEvent.mouseEvents)
	{
		if(LOWER_RIGHT_NONE!=lowerRightIcon && FSMOUSEEVENT_LBUTTONDOWN==mos.evt)
		{
			int wid=windowEvent.winWid;
			int hei=windowEvent.winHei;

			int iconWid=0;
			int iconHei=0;
			switch(lowerRightIcon)
			{
			case LOWER_RIGHT_NONE:
				break;
			case LOWER_RIGHT_PAUSE:
				iconWid=PAUSE_wid;
				iconHei=PAUSE_hei;
				break;
			case LOWER_RIGHT_MENU:
				iconWid=MENU_wid;
				iconHei=MENU_hei;
				break;
			}
			if(wid-iconWid<mos.mx && hei-iconHei<mos.my)
			{
				this->pauseKey=true;
			}
		}

		if(FSMOUSEEVENT_MBUTTONDOWN==mos.evt)
		{
			this->commandQueue.push("TOGGLE DIFFMOUSE");
		}
	}

	int lb=windowEvent.lastKnownMouse.lb;
	int mb=windowEvent.lastKnownMouse.mb;
	int rb=windowEvent.lastKnownMouse.rb;
	int mx=windowEvent.lastKnownMouse.mx;
	int my=windowEvent.lastKnownMouse.my;

	auto &gamePads=windowEvent.gamePads;

	if(prevGamePads.size()!=gamePads.size())
	{
		// Probably the first time.  There is no previous game-pad states.
		// Make it a copy.
		prevGamePads=gamePads;
	}

	bool gamePadEmulationByKey=false; // Emulate a gamepad with keyboard
	bool gamePad6EmulationByKey=false; // Emulate CAPCOM CPSF or 6-button Pad with keyboard
	bool mouseEmulationByNumPad=false; // Emulate mouse with keyboard numpad
	for(unsigned int portId=0; portId<TOWNS_NUM_GAMEPORTS; ++portId)
	{
		if(TOWNS_GAMEPORTEMU_KEYBOARD==gamePort[portId] ||
		   TOWNS_GAMEPORTEMU_MOUSE_BY_KEY==gamePort[portId])
		{
			gamePadEmulationByKey=true;
		}
		if(TOWNS_GAMEPORTEMU_CAPCOM_BY_KEY==gamePort[portId] ||
		   TOWNS_GAMEPORTEMU_6BTNPAD_BY_KEY==gamePort[portId])
		{
			gamePad6EmulationByKey=true;
		}
		if(TOWNS_GAMEPORTEMU_MOUSE_BY_NUMPAD==gamePort[portId])
		{
			mouseEmulationByNumPad=true;
		}
	}

	for(auto vk : virtualKeys)
	{
		if(0<=vk.physicalId && vk.physicalId<gamePads.size())
		{
			if(prevGamePads[vk.physicalId].buttons[vk.button]!=gamePads[vk.physicalId].buttons[vk.button])
			{
				if(0!=gamePads[vk.physicalId].buttons[vk.button])
				{
					towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_PRESS  ,vk.townsKey);
				}
				else
				{
					towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,vk.townsKey);
				}
			}
		}
	}


	// Strike Commander throttle control.
	if(TOWNS_APPSPECIFIC_STRIKECOMMANDER==towns.state.appSpecificSetting && 0<=throttlePhysicalId && throttlePhysicalId<gamePads.size())
	{
		if(prevGamePads[throttlePhysicalId].axes[throttleAxis]!=
		   gamePads[throttlePhysicalId].axes[throttleAxis])
		{
			int prev=(1.0F-prevGamePads[throttlePhysicalId].axes[throttleAxis])*5.0F;
			int now=(1.0F-gamePads[throttlePhysicalId].axes[throttleAxis])*5.0F;

			if(prev<0)
			{
				prev=0;
			}
			else if(9<prev)
			{
				prev=9;
			}
			if(now<0)
			{
				now=0;
			}
			else if(9<now)
			{
				now=9;
			}
			// When C++17 is available :-P
			// prev=std::clamp<int>(prev,0,9);
			// now=std::clamp<int>(prev,0,9);

			if(prev!=now)
			{
				unsigned int key;
				if(now<9)
				{
					key=TOWNS_JISKEY_1+now;
				}
				else
				{
					key=TOWNS_JISKEY_0;
				}
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_PRESS  ,key);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,key);
			}
		}
	}
	// Wing Commander Throttle Control
	if(0<=throttlePhysicalId && throttlePhysicalId<gamePads.size())
	{
		/* The following method does not make too many key strokes,
		   however, if another key is pressed while the set speed is still changing,
		   the speed stops changing.
		if(TOWNS_APPSPECIFIC_WINGCOMMANDER1==towns.state.appSpecificSetting)
		{
			unsigned int setSpeed,maxSpeed;
			towns.GetWingCommanderSetSpeedMaxSpeed(setSpeed,maxSpeed);

			unsigned int thr=(unsigned int)((1.0f-gamePads[throttlePhysicalId].axes[throttleAxis])*128.0f); // 0-255 scale
			thr=thr*maxSpeed/255;
			if(1!=wingCommander1ThrottleState && setSpeed<thr)
			{
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_MINUS);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_PLUS);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_PRESS  ,TOWNS_JISKEY_NUM_PLUS);
				wingCommander1ThrottleState=1;
			}
			else if(-1!=wingCommander1ThrottleState && thr<setSpeed)
			{
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_PLUS);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_MINUS);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_PRESS  ,TOWNS_JISKEY_NUM_MINUS);
				wingCommander1ThrottleState=-1;
			}
			else if((0<wingCommander1ThrottleState && thr<=setSpeed) ||
			        (wingCommander1ThrottleState<0 && setSpeed<=thr))
			{
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_PLUS);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_MINUS);
				wingCommander1ThrottleState=0;
			}
		} */
		if(TOWNS_APPSPECIFIC_WINGCOMMANDER2==towns.state.appSpecificSetting ||
		   TOWNS_APPSPECIFIC_WINGCOMMANDER1==towns.state.appSpecificSetting)
		{
			unsigned int setSpeed,maxSpeed;
			towns.GetWingCommanderSetSpeedMaxSpeed(setSpeed,maxSpeed);

			unsigned int prevThr=(unsigned int)((1.0f-prevGamePads[throttlePhysicalId].axes[throttleAxis])*128.0f); // 0-255 scale
			unsigned int thr=(unsigned int)((1.0f-gamePads[throttlePhysicalId].axes[throttleAxis])*128.0f); // 0-255 scale
			prevThr=prevThr*maxSpeed/255;
			thr=thr*maxSpeed/255;

			if(prevThr!=thr)
			{
				std::cout << "pre " << prevThr << " new " << thr << " set " << setSpeed << " max " << maxSpeed << std::endl;
				lastThrottleMoveTime=towns.state.townsTime;
				nextThrottleUpdateTime=towns.state.townsTime;
			}

			if(towns.state.townsTime<lastThrottleMoveTime+4*PER_SECOND && nextThrottleUpdateTime<=towns.state.townsTime)
			{
				// Wing Commander I speed up/slow down while plus or minus key is held down.
				// However, if another key is pressed during the acceleration or desceleration
				// the set-speed stops changing.
				// Therefore, it needs to send key-release code periodically to make the program
				// think the plus or minus key is re-pressed to allow throttle to work while
				// other keys are functional.
				nextThrottleUpdateTime=towns.state.townsTime+PER_SECOND/16;
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_PLUS);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_NUM_MINUS);
				if(setSpeed<thr)
				{
					towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_PRESS  ,TOWNS_JISKEY_NUM_PLUS);
				}
				else if(thr<setSpeed)
				{
					towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_PRESS  ,TOWNS_JISKEY_NUM_MINUS);
				}
			}
		}
		else if(TOWNS_APPSPECIFIC_AIRWARRIOR_V2==towns.state.appSpecificSetting)
		{
			unsigned int prevInputThr=(unsigned int)((1.0f-prevGamePads[throttlePhysicalId].axes[throttleAxis])*8.1f); // 0 to 16 scale
			unsigned int inputThr=(unsigned int)((1.0f-gamePads[throttlePhysicalId].axes[throttleAxis])*8.1f); // 0 to 16 scale

			if(prevInputThr!=inputThr)
			{
				lastThrottleMoveTime=towns.state.townsTime;
				nextThrottleUpdateTime=towns.state.townsTime;
			}

			if(towns.state.townsTime<lastThrottleMoveTime+4*PER_SECOND && nextThrottleUpdateTime<=towns.state.townsTime)
			{
				nextThrottleUpdateTime=towns.state.townsTime+PER_SECOND/16;
				unsigned int currentThr=(towns.mem.FetchByte(towns.state.appSpecific_ThrottlePtr))/12; // 0 to 16
				unsigned int keyToPress=TOWNS_JISKEY_NULL;
				if(currentThr<inputThr)
				{
					keyToPress=TOWNS_JISKEY_C;
				}
				else if(inputThr<currentThr)
				{
					keyToPress=TOWNS_JISKEY_V;
				}
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_PRESS  ,keyToPress);
				towns.keyboard.PushFifo(TOWNS_KEYFLAG_JIS_RELEASE,keyToPress);
			}
		}
		else if(TOWNS_APPSPECIFIC_AFTERBURNER2==towns.state.appSpecificSetting)
		{
			// Afterburner II Application-Specific Customization
			// Contribution from BCC.
			unsigned int inputThr = (unsigned int)((1.0f - gamePads[throttlePhysicalId].axes[throttleAxis]) * 1.5f); // 0 to 2 scale
			towns.AB2_Throttle(inputThr);
		}
	}

	// For the time translation mode only.
	// if(true==keyTranslationMode)
	if(TOWNS_KEYBOARD_MODE_DIRECT!=keyboardMode) // Means one of the translation modes.
	{
		for(auto c : windowEvent.charCode)
		{
			if(0==windowEvent.keyState[FSKEY_CTRL])
			{
				if(' '<=c)
				{
					unsigned char byteData[2]={0,0};
					if(0<TownsKeyboard::TranslateChar(byteData,c))
					{
						towns.keyboard.TypeToFifo(byteData);
					}
				}
			}
		}
		for(auto c : windowEvent.keyCode)
		{
			if(PAUSE_KEY_CODE==c)
			{
				PauseKeyPressed();
			}
			if(hostShortCut[c].inUse && hostShortCut[c].ctrl==ctrlKey && hostShortCut[c].shift==shiftKey)
			{
				this->commandQueue.push(hostShortCut[c].cmdStr);
				continue;
			}

			this->ProcessInkey(towns,FSKEYtoTownsKEY[c]);
			unsigned char keyFlags=0;
			switch(c)
			{
			default:
				// CTRL+C, CTRL+S, CTRL+Q...
				if(ctrlKey && FSKEY_A<=c && c<=FSKEY_Z)
				{
					// Can take Ctrl+? and Ctrl+Shift+?, but Shift+? is taken by FsInkeyChar() already.
					// Therefore this block should only process only if Ctrl key is held down.
					keyFlags=TOWNS_KEYFLAG_CTRL;
					if(shiftKey)
					{
						keyFlags=TOWNS_KEYFLAG_SHIFT;
					}
					const unsigned char byteData[2]=
					{
						(unsigned char)(keyFlags|TOWNS_KEYFLAG_TYPE_FIRSTBYTE|TOWNS_KEYFLAG_TYPE_JIS),
						(unsigned char)FSKEYtoTownsKEY[c]
					};
					towns.keyboard.TypeToFifo(byteData);
				}
				break;
			case FSKEY_ESC:
				// User Request: Want to use ESC as ESC.
				// Problem: F-BASIC386 uses Break.
				// Trying: Physical ESC key makes both BREAK and ESC strokes.
				keyFlags|=(ctrlKey ? TOWNS_KEYFLAG_CTRL : 0);
				keyFlags|=(shiftKey ? TOWNS_KEYFLAG_SHIFT : 0);
				if(TOWNS_KEYBOARD_MODE_TRANSLATION1==keyboardMode)
				{
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_PRESS,  TOWNS_JISKEY_BREAK);
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_BREAK);
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_PRESS,  TOWNS_JISKEY_ESC);
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_ESC);
				}
				else if(TOWNS_KEYBOARD_MODE_TRANSLATION2==keyboardMode)
				{
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_PRESS,  TOWNS_JISKEY_ESC);
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_ESC);
				}
				else if(TOWNS_KEYBOARD_MODE_TRANSLATION3==keyboardMode)
				{
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_PRESS,  TOWNS_JISKEY_BREAK);
					towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_RELEASE,TOWNS_JISKEY_BREAK);
				}
				break;
			case FSKEY_ENTER:
			case FSKEY_BS:
			case FSKEY_TAB:
			case FSKEY_HOME:
			case FSKEY_END:
			case FSKEY_PAGEUP:
			case FSKEY_PAGEDOWN:
			case FSKEY_NUMLOCK:
			case FSKEY_ALT:
			case FSKEY_INS:
			case FSKEY_DEL:
			case FSKEY_F1:
			case FSKEY_F2:
			case FSKEY_F3:
			case FSKEY_F4:
			case FSKEY_F5:
			case FSKEY_F6:
			case FSKEY_F7:
			case FSKEY_F8:
			case FSKEY_F9:
			case FSKEY_F10:
			case FSKEY_F11:
			case FSKEY_F12:
			case FSKEY_CAPSLOCK:
			case FSKEY_CONVERT:
			case FSKEY_NONCONVERT:
			case FSKEY_KANA:       // Japanese JIS Keyboard Only => Win32 VK_KANA
			case FSKEY_RO:         // Japanese JIS Keyboard Only => Win32 VK_OEM_102
			case FSKEY_ZENKAKU:    // Japanese JIS Keyboard Only => Full Pitch/Half Pitch
			case FSKEY_WHEELUP:
			case FSKEY_WHEELDOWN:
			case FSKEY_CONTEXT:
			case FSKEY_UP:
			case FSKEY_DOWN:
			case FSKEY_LEFT:
			case FSKEY_RIGHT:
				keyFlags|=(ctrlKey ? TOWNS_KEYFLAG_CTRL : 0);
				keyFlags|=(shiftKey ? TOWNS_KEYFLAG_SHIFT : 0);
				towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_PRESS,  FSKEYtoTownsKEY[c]);
				towns.keyboard.PushFifo(keyFlags|TOWNS_KEYFLAG_JIS_RELEASE,FSKEYtoTownsKEY[c]);
				break;
			}
		}
	}
	else // if(TOWNS_KEYBOARD_MODE_DIRECT==keyboardMode)
	{
		for(auto c : windowEvent.keyCode)
		{
			unsigned char byteData=0;
			this->ProcessInkey(towns,FSKEYtoTownsKEY[c]);
			if(PAUSE_KEY_CODE==c)
			{
				PauseKeyPressed();
			}
			if(hostShortCut[c].inUse && hostShortCut[c].ctrl==ctrlKey && hostShortCut[c].shift==shiftKey)
			{
				this->commandQueue.push(hostShortCut[c].cmdStr);
				continue;
			}

			if(TOWNS_JISKEY_NULL!=FSKEYtoTownsKEY[c])
			{
				if(true==gamePadEmulationByKey &&
				   (FSKEY_Z==c ||
				    FSKEY_X==c ||
				    FSKEY_A==c ||
				    FSKEY_S==c ||
				    FSKEY_LEFT==c ||
				    FSKEY_RIGHT==c ||
				    FSKEY_UP==c ||
				    FSKEY_DOWN==c))
				{
					break;
				}
				if(true==mouseEmulationByNumPad &&
				   (FSKEY_TEN0==c ||
				    FSKEY_TEN1==c ||
				    FSKEY_TEN2==c ||
				    FSKEY_TEN3==c ||
				    FSKEY_TEN4==c ||
				    FSKEY_TEN5==c ||
				    FSKEY_TEN6==c ||
				    FSKEY_TEN7==c ||
				    FSKEY_TEN8==c ||
				    FSKEY_TEN9==c ||
				    FSKEY_TENSTAR==c ||
				    FSKEY_TENSLASH==c))
				{
					break;
				}

				byteData|=(ctrlKey ? TOWNS_KEYFLAG_CTRL : 0);
				byteData|=(shiftKey ? TOWNS_KEYFLAG_SHIFT : 0);
				if(0!=FSKEYState[c])
				{
					byteData|=0xF0; // Typamatic==Repeat?
				}
				else
				{
					byteData|=TOWNS_KEYFLAG_JIS_PRESS;
				}
				towns.keyboard.PushFifo(byteData,FSKEYtoTownsKEY[c]);

				// There is a possibility that FsGetKeyState turns 1 before FsInkey catches a keycode.
				// If so, the first inkey may make a typamatic (repeat) code, which may be disregarded
				// by some programs.
				// Therefore, turn it 1 upon inkey, and turn it off if FsGetKeyState detects key release.
				// Don't turn it on by FsGetKeyState.
				FSKEYState[c]=1;
			}
		}
		for(int key=FSKEY_NULL; key<FSKEY_NUM_KEYCODE; ++key)
		{
			if(true==gamePadEmulationByKey &&
			   (FSKEY_Z==key ||
			    FSKEY_X==key ||
			    FSKEY_A==key ||
			    FSKEY_S==key ||
			    FSKEY_LEFT==key ||
			    FSKEY_RIGHT==key ||
			    FSKEY_UP==key ||
			    FSKEY_DOWN==key))
			{
				continue;
			}
			if(true==gamePad6EmulationByKey &&
			   (FSKEY_Z==key ||
			    FSKEY_X==key ||
			    FSKEY_C==key ||
			    FSKEY_A==key ||
			    FSKEY_S==key ||
			    FSKEY_D==key ||
			    FSKEY_Q==key ||
			    FSKEY_W==key ||
			    FSKEY_LEFT==key ||
			    FSKEY_RIGHT==key ||
			    FSKEY_UP==key ||
			    FSKEY_DOWN==key))
			{
				continue;
			}
			if(true==mouseEmulationByNumPad &&
			   (FSKEY_TEN0==key ||
			    FSKEY_TEN1==key ||
			    FSKEY_TEN2==key ||
			    FSKEY_TEN3==key ||
			    FSKEY_TEN4==key ||
			    FSKEY_TEN5==key ||
			    FSKEY_TEN6==key ||
			    FSKEY_TEN7==key ||
			    FSKEY_TEN8==key ||
			    FSKEY_TEN9==key ||
			    FSKEY_TENSTAR==key ||
			    FSKEY_TENSLASH==key))
			{
				continue;
			}

			unsigned char byteData=0;
			auto sta=windowEvent.keyState[key];
			if(0!=FSKEYtoTownsKEY[key] && 0!=FSKEYState[key] && 0==sta)
			{
				byteData|=(ctrlKey ? TOWNS_KEYFLAG_CTRL : 0);
				byteData|=(shiftKey ? TOWNS_KEYFLAG_SHIFT : 0);
				byteData|=TOWNS_KEYFLAG_JIS_RELEASE;
				towns.keyboard.PushFifo(byteData,FSKEYtoTownsKEY[key]);
			}
			// See comment above regarding the timing of FsGetKeyState and FsInkey.
			if(0==sta)
			{
				FSKEYState[key]=0;
			}
		}
	}

	if(towns.eventLog.mode!=TownsEventLog::MODE_PLAYBACK)
	{
		bool mouseEmulationByAnalogAxis=false;
		for(unsigned int portId=0; portId<TOWNS_NUM_GAMEPORTS; ++portId)
		{
			switch(gamePort[portId])
			{
			default:
				// Not implemented yet.
				break;
			case TOWNS_GAMEPORTEMU_KEYBOARD:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_KEY:
				{
					bool Abutton=(0!=windowEvent.keyState[FSKEY_Z]);
					bool Bbutton=(0!=windowEvent.keyState[FSKEY_X]);
					bool run=(0!=windowEvent.keyState[FSKEY_A]);
					bool pause=(0!=windowEvent.keyState[FSKEY_S]);
					bool left=(0!=windowEvent.keyState[FSKEY_LEFT]);
					bool right=(0!=windowEvent.keyState[FSKEY_RIGHT]);
					if(true==left && true==right)
					{
						right=false;
					}
					bool up=(0!=windowEvent.keyState[FSKEY_UP]);
					bool down=(0!=windowEvent.keyState[FSKEY_DOWN]);
					if(true==up && true==down)
					{
						down=false;
					}
					bool zoom=false;
					if(TOWNS_GAMEPORTEMU_MARTYPAD_BY_KEY==gamePort[portId])
					{
						zoom=(0!=windowEvent.keyState[FSKEY_Q]);
					}
					towns.SetGamePadState(portId,Abutton,Bbutton,left,right,up,down,run,pause,zoom);
				}
				break;
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_KEY:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_KEY:
				{
					bool Abutton=(0!=windowEvent.keyState[FSKEY_Z]);
					bool Bbutton=(0!=windowEvent.keyState[FSKEY_X]);
					bool Cbutton=(0!=windowEvent.keyState[FSKEY_C]);
					bool Dbutton=(0!=windowEvent.keyState[FSKEY_A]);
					bool Ebutton=(0!=windowEvent.keyState[FSKEY_S]);
					bool Fbutton=(0!=windowEvent.keyState[FSKEY_D]);
					bool run=(0!=windowEvent.keyState[FSKEY_Q]);
					bool pause=(0!=windowEvent.keyState[FSKEY_W]);

					bool lf=(0!=windowEvent.keyState[FSKEY_LEFT]);
					bool ri=(0!=windowEvent.keyState[FSKEY_RIGHT]);
					if(true==lf && true==ri)
					{
						ri=false;
					}
					bool up=(0!=windowEvent.keyState[FSKEY_UP]);
					bool dn=(0!=windowEvent.keyState[FSKEY_DOWN]);
					if(true==up && true==dn)
					{
						dn=false;
					}

					towns.SetCAPCOMCPSFState(
					    portId,
					    lf,
					    ri,
					    up,
					    dn,
					    Abutton,
					    Bbutton,
					    Cbutton,
					    Dbutton,
					    Ebutton,
					    Fbutton,
					    run,
					    pause);
				}
				break;

			case TOWNS_GAMEPORTEMU_PHYSICAL0:
			case TOWNS_GAMEPORTEMU_PHYSICAL1:
			case TOWNS_GAMEPORTEMU_PHYSICAL2:
			case TOWNS_GAMEPORTEMU_PHYSICAL3:
			case TOWNS_GAMEPORTEMU_PHYSICAL4:
			case TOWNS_GAMEPORTEMU_PHYSICAL5:
			case TOWNS_GAMEPORTEMU_PHYSICAL6:
			case TOWNS_GAMEPORTEMU_PHYSICAL7:
				{
					int padId=gamePort[portId]-TOWNS_GAMEPORTEMU_PHYSICAL0;
					if(0<=padId && padId<gamePads.size())
					{
						auto &reading=gamePads[padId];
						towns.SetGamePadState(
						    portId,
						    reading.buttons[0],
						    reading.buttons[1],
						    reading.dirs[0].upDownLeftRight[2],
						    reading.dirs[0].upDownLeftRight[3],
						    reading.dirs[0].upDownLeftRight[0],
						    reading.dirs[0].upDownLeftRight[1],
						    reading.buttons[2],
						    reading.buttons[3],
						    false);
					}
				}
				break;

			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL0:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL1:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL2:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL3:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL4:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL5:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL6:
			case TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL7:
				{
					int padId=gamePort[portId]-TOWNS_GAMEPORTEMU_MARTYPAD_BY_PHYSICAL0;
					if(0<=padId && padId<gamePads.size())
					{
						auto &reading=gamePads[padId];
						towns.SetGamePadState(
						    portId,
						    reading.buttons[0],
						    reading.buttons[1],
						    reading.dirs[0].upDownLeftRight[2],
						    reading.dirs[0].upDownLeftRight[3],
						    reading.dirs[0].upDownLeftRight[0],
						    reading.dirs[0].upDownLeftRight[1],
						    reading.buttons[2],
						    reading.buttons[3],
						    reading.buttons[4]);
					}
				}
				break;

			case TOWNS_GAMEPORTEMU_ANALOG0:
			case TOWNS_GAMEPORTEMU_ANALOG1:
			case TOWNS_GAMEPORTEMU_ANALOG2:
			case TOWNS_GAMEPORTEMU_ANALOG3:
			case TOWNS_GAMEPORTEMU_ANALOG4:
			case TOWNS_GAMEPORTEMU_ANALOG5:
			case TOWNS_GAMEPORTEMU_ANALOG6:
			case TOWNS_GAMEPORTEMU_ANALOG7:
				{
					int padId=gamePort[portId]-TOWNS_GAMEPORTEMU_ANALOG0;
					if(0<=padId && padId<gamePads.size())
					{
						auto &reading=gamePads[padId];
						YsGamdPadTranslateAnalogToDigital(&reading.dirs[0],reading.axes[0],reading.axes[1]);
						towns.SetGamePadState(
						    portId,
						    reading.buttons[0],
						    reading.buttons[1],
						    reading.dirs[0].upDownLeftRight[2],
						    reading.dirs[0].upDownLeftRight[3],
						    reading.dirs[0].upDownLeftRight[0],
						    reading.dirs[0].upDownLeftRight[1],
						    reading.buttons[2],
						    reading.buttons[3],
						    /*zoom=*/false);
					}
				}
				break;

			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL0:
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL1:
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL2:
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL3:
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL4:
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL5:
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL6:
			case TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL7:

			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL0:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL1:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL2:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL3:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL4:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL5:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL6:
			case TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL7:
				{
					int padId=gamePort[portId]-TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL0;

					if(TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL0<=gamePort[portId] && gamePort[portId]<=TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL7)
					{
						padId=gamePort[portId]-TOWNS_GAMEPORTEMU_6BTNPAD_BY_PHYSICAL0;
					}

					if(0<=padId && padId<gamePads.size())
					{
						auto &reading=gamePads[padId];
						bool up=reading.dirs[0].upDownLeftRight[0];
						bool dn=reading.dirs[0].upDownLeftRight[1];
						bool lf=reading.dirs[0].upDownLeftRight[2];
						bool ri=reading.dirs[0].upDownLeftRight[3];

						// Muscle Bomber cannot start without pressing START button.
						// So, I use physical buttons 8 and 9 for START/SELECT.
						if(reading.buttons[8])
						{
							lf=true;
							ri=true;
						}
						if(reading.buttons[9])
						{
							up=true;
							dn=true;
						}

						towns.SetCAPCOMCPSFState(
						    portId,
						    lf,
						    ri,
						    up,
						    dn,
						    reading.buttons[0],
						    reading.buttons[1],
						    reading.buttons[2],
						    reading.buttons[3],
						    reading.buttons[4],
						    reading.buttons[5],
						    reading.buttons[6],
						    reading.buttons[7]);
					}
				}
				break;

			case TOWNS_GAMEPORTEMU_MOUSE_BY_KEY:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_NUMPAD:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL0:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL1:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL2:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL3:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL4:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL5:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL6:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL7:
				{
					{
						const int accel=1;
						const int maxSpeed=80;
						const int div=20;

						bool upDownLeftRight[4]={false,false,false,false};
						bool button[2]={false,false};

						mouseEmulationByAnalogAxis=true;
						if(TOWNS_GAMEPORTEMU_MOUSE_BY_KEY==gamePort[portId])
						{
							upDownLeftRight[0]=(0!=windowEvent.keyState[FSKEY_UP]);
							upDownLeftRight[1]=(0!=windowEvent.keyState[FSKEY_DOWN]);
							upDownLeftRight[2]=(0!=windowEvent.keyState[FSKEY_LEFT]);
							upDownLeftRight[3]=(0!=windowEvent.keyState[FSKEY_RIGHT]);
							button[0]=(0!=windowEvent.keyState[FSKEY_Z]);
							button[1]=(0!=windowEvent.keyState[FSKEY_X]);
						}
						else if(TOWNS_GAMEPORTEMU_MOUSE_BY_NUMPAD==gamePort[portId])
						{
							upDownLeftRight[0]=(0!=windowEvent.keyState[FSKEY_TEN7] || 0!=windowEvent.keyState[FSKEY_TEN8] || 0!=windowEvent.keyState[FSKEY_TEN9]);
							upDownLeftRight[1]=(0!=windowEvent.keyState[FSKEY_TEN1] || 0!=windowEvent.keyState[FSKEY_TEN2] || 0!=windowEvent.keyState[FSKEY_TEN3]);
							upDownLeftRight[2]=(0!=windowEvent.keyState[FSKEY_TEN1] || 0!=windowEvent.keyState[FSKEY_TEN4] || 0!=windowEvent.keyState[FSKEY_TEN7]);
							upDownLeftRight[3]=(0!=windowEvent.keyState[FSKEY_TEN3] || 0!=windowEvent.keyState[FSKEY_TEN6] || 0!=windowEvent.keyState[FSKEY_TEN9]);
							button[0]=(0!=windowEvent.keyState[FSKEY_TENSLASH]);
							button[1]=(0!=windowEvent.keyState[FSKEY_TENSTAR]);
						}
						else
						{
							int padId=gamePort[portId]-TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL0;
							if(0<=padId && padId<gamePads.size())
							{
								const auto &reading=gamePads[padId];
								upDownLeftRight[0]=(0!=reading.dirs[0].upDownLeftRight[0]);
								upDownLeftRight[1]=(0!=reading.dirs[0].upDownLeftRight[1]);
								upDownLeftRight[2]=(0!=reading.dirs[0].upDownLeftRight[2]);
								upDownLeftRight[3]=(0!=reading.dirs[0].upDownLeftRight[3]);
								button[0]=(0!=reading.buttons[0]);
								button[1]=(0!=reading.buttons[1]);
							}
						}
						if(true==upDownLeftRight[0])
						{
							mouseDY+=accel;
						}
						else if(true==upDownLeftRight[1])
						{
							mouseDY-=accel;
						}
						else
						{
							mouseDY=0;
						}
						if(mouseDY<-maxSpeed)
						{
							mouseDY=-maxSpeed;
						}
						if(mouseDY>maxSpeed)
						{
							mouseDY=maxSpeed;
						}
						if(0!=true==upDownLeftRight[2])
						{
							mouseDX+=accel;
						}
						else if(0!=true==upDownLeftRight[3])
						{
							mouseDX-=accel;
						}
						else
						{
							mouseDX=0;
						}
						if(mouseDX<-maxSpeed)
						{
							mouseDX=-maxSpeed;
						}
						if(mouseDX>maxSpeed)
						{
							mouseDX=maxSpeed;
						}
						towns.SetMouseMotion(portId,mouseDX/div,mouseDY/div);
						towns.SetMouseButtonState(button[0],button[1]);
					}
				}
				break;
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG0:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG1:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG2:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG3:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG4:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG5:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG6:
			case TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG7:
				{
					{
						const double maxSpeed=20.0;

						mouseEmulationByAnalogAxis=true;
						int padId=gamePort[portId]-TOWNS_GAMEPORTEMU_MOUSE_BY_ANALOG0;
						if(0<=padId && padId<gamePads.size())
						{
							const auto &reading=gamePads[padId];
							float dx=reading.axes[0]*maxSpeed;
							float dy=reading.axes[1]*maxSpeed;
							towns.SetMouseMotion(portId,-dx,-dy);
							towns.SetMouseButtonState(0!=reading.buttons[0],0!=reading.buttons[1]);
						}
					}
				}
				break;

			case TOWNS_GAMEPORTEMU_PHYSICAL0_AS_CYBERSTICK:
			case TOWNS_GAMEPORTEMU_PHYSICAL1_AS_CYBERSTICK:
			case TOWNS_GAMEPORTEMU_PHYSICAL2_AS_CYBERSTICK:
			case TOWNS_GAMEPORTEMU_PHYSICAL3_AS_CYBERSTICK:
			case TOWNS_GAMEPORTEMU_PHYSICAL4_AS_CYBERSTICK:
			case TOWNS_GAMEPORTEMU_PHYSICAL5_AS_CYBERSTICK:
			case TOWNS_GAMEPORTEMU_PHYSICAL6_AS_CYBERSTICK:
			case TOWNS_GAMEPORTEMU_PHYSICAL7_AS_CYBERSTICK:
				{
					auto physId=gamePort[portId]-TOWNS_GAMEPORTEMU_PHYSICAL0_AS_CYBERSTICK;
					if(0<=physId && physId<gamePads.size())
					{
						auto axisReading=gamePads[physId];

						float x=axisReading.axes[0];
						float y=axisReading.axes[1];
						float z=axisReading.axes[2];
						float w=axisReading.axes[3];
						int ix=x*127.0;
						int iy=y*127.0;
						int iz=z*127.0;
						int iw=w*127.0;
						ix=cpputil::Clamp(ix,-128,127);
						iy=cpputil::Clamp(iy,-128,127);
						iz=cpputil::Clamp(iz,-128,127);
						iw=cpputil::Clamp(iw,-128,127);

						unsigned int trig=0;
						trig|=(axisReading.buttons[0] ? 0x01 : 0);
						trig|=(axisReading.buttons[1] ? 0x02 : 0);
						trig|=(axisReading.buttons[2] ? 0x04 : 0);
						trig|=(axisReading.buttons[3] ? 0x08 : 0);
						trig|=(axisReading.buttons[4] ? 0x10 : 0);
						trig|=(axisReading.buttons[5] ? 0x20 : 0);
						trig|=(axisReading.buttons[6] ? 0x40 : 0);
						trig|=(axisReading.buttons[7] ? 0x80 : 0);
						trig|=(axisReading.buttons[8] ? 0x100 : 0);
						trig|=(axisReading.buttons[9] ? 0x200 : 0);
						trig|=(axisReading.buttons[10] ? 0x400 : 0);
						trig|=(axisReading.buttons[11] ? 0x800 : 0);
						towns.SetCyberStickState(portId,ix,iy,iz,iw,trig);
					}
				}
				break;

			case TOWNS_GAMEPORTEMU_CYBERSTICK:
				if(true==cyberStickAssignment && 0<=mouseByFlightstickPhysicalId && mouseByFlightstickPhysicalId<gamePads.size())
				{
					auto axisReading=gamePads[mouseByFlightstickPhysicalId];
					decltype(axisReading) throttleReading;
					float z=0;
					if(0<=throttlePhysicalId && throttlePhysicalId<gamePads.size())
					{
						throttleReading=gamePads[throttlePhysicalId];
						z=gamePads[throttlePhysicalId].axes[throttleAxis];
					}
					else
					{
						throttleReading=axisReading;
						z=gamePads[throttlePhysicalId].axes[2];
					}

					float x=axisReading.axes[0];
					float y=axisReading.axes[1];
					int ix=x*127.0;
					int iy=y*127.0;
					int iz=z*127.0;
					int iw=0;
					ix=cpputil::Clamp(ix,-128,127);
					iy=cpputil::Clamp(iy,-128,127);
					iz=cpputil::Clamp(iz,-128,127);

					unsigned int trig=0;
					trig|=((axisReading.buttons[0] || throttleReading.buttons[0]) ? 0x01 : 0);
					trig|=((axisReading.buttons[1] || throttleReading.buttons[1]) ? 0x02 : 0);
					trig|=((axisReading.buttons[2] || throttleReading.buttons[2]) ? 0x04 : 0);
					trig|=((axisReading.buttons[3] || throttleReading.buttons[3]) ? 0x08 : 0);
					trig|=((axisReading.buttons[4] || throttleReading.buttons[4]) ? 0x10 : 0);
					trig|=((axisReading.buttons[5] || throttleReading.buttons[5]) ? 0x20 : 0);
					trig|=((axisReading.buttons[6] || throttleReading.buttons[6]) ? 0x40 : 0);
					trig|=((axisReading.buttons[7] || throttleReading.buttons[7]) ? 0x80 : 0);
					trig|=((axisReading.buttons[8] || throttleReading.buttons[8]) ? 0x100 : 0);
					trig|=((axisReading.buttons[9] || throttleReading.buttons[9]) ? 0x200 : 0);
					trig|=((axisReading.buttons[10] || throttleReading.buttons[10]) ? 0x400 : 0);
					trig|=((axisReading.buttons[11] || throttleReading.buttons[11]) ? 0x800 : 0);
					towns.SetCyberStickState(portId,ix,iy,iz,iw,trig);
				}
				break;

			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG0:
			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG1:
			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG2:
			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG3:
			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG4:
			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG5:
			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG6:
			case TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG7:
				{
					int padId=gamePort[portId]-TOWNS_GAMEPORTEMU_LIBBLE_RABBLE_PAD_BY_ANALOG0;
					if(0<=padId && padId<gamePads.size())
					{
						auto &reading=gamePads[padId];
						YsGamdPadTranslateAnalogToDigital(&reading.dirs[0],reading.axes[0],reading.axes[1]);

						struct YsGamePadDirectionButton dir2;
						YsGamdPadTranslateAnalogToDigital(&dir2,reading.axes[2],reading.axes[3]);

						towns.SetLibbleRabblePadState(
						    portId,
						    reading.buttons[0],
						    reading.buttons[1],
						    reading.dirs[0].upDownLeftRight[2],
						    reading.dirs[0].upDownLeftRight[3],
						    reading.dirs[0].upDownLeftRight[0],
						    reading.dirs[0].upDownLeftRight[1],
						    dir2.upDownLeftRight[2],
						    dir2.upDownLeftRight[3],
						    dir2.upDownLeftRight[0],
						    dir2.upDownLeftRight[1],
						    reading.buttons[2],
						    reading.buttons[3]);
					}
				}
				break;
			}
		}

		if(TOWNS_APPSPECIFIC_DAIKOUKAIJIDAI2==towns.state.appSpecificSetting &&
		   true==towns.Daikoukai2_ControlMouseByArrowKeys(
			    lb,mb,rb,mx,my,
			    windowEvent.keyState[FSKEY_LEFT],
			    windowEvent.keyState[FSKEY_UP],
			    windowEvent.keyState[FSKEY_RIGHT],
			    windowEvent.keyState[FSKEY_DOWN]))
		{
			this->ProcessMouse(towns,lb,mb,rb,mx,my);
		}
		else if(mouseEmulationByAnalogAxis!=true)
		{
			struct YsGamePadReading reading;
			mx-=this->dx;
			my-=this->dy;
			if(true==mouseByFlightstickAvailable && 0<=mouseByFlightstickPhysicalId && mouseByFlightstickPhysicalId<gamePads.size())
			{
				reading=gamePads[mouseByFlightstickPhysicalId];
				if(true!=mouseByFlightstickEnabled)
				{
					float dx=reading.axes[0]-lastJoystickPos[0];
					float dy=reading.axes[1]-lastJoystickPos[1];
					if(dx<=-0.1F || 0.1F<=dx || dy<=-0.1F || 0.1F<=dy)
					{
						mouseByFlightstickEnabled=true;
						lastMousePosForSwitchBackToNormalMode[0]=mx;
						lastMousePosForSwitchBackToNormalMode[1]=my;
					}
				}
				else
				{
					int dx=mx-lastMousePosForSwitchBackToNormalMode[0];
					int dy=my-lastMousePosForSwitchBackToNormalMode[1];
					if(dx<-10 || 10<dx || dy<-10 || 10<dy)
					{
						mouseByFlightstickEnabled=false;
						lastJoystickPos[0]=reading.axes[0];
						lastJoystickPos[1]=reading.axes[1];
					}
				}
			}

			if(true==mouseByFlightstickEnabled && TOWNS_APPSPECIFIC_WINGCOMMANDER1==towns.state.appSpecificSetting)
			{
				// Wing Commander 1 turned out to be using separate joystick position from the mouse coordinate.
				// Need to translate to the mouse coordinate.
				int curStickX,curStickY;
				curStickX=towns.mem.FetchDword(towns.state.appSpecific_StickPosXPtr);
				curStickY=towns.mem.FetchDword(towns.state.appSpecific_StickPosYPtr);
				curStickX=(curStickX&0x7FFF)-(curStickX&0x8000);
				curStickY=(curStickY&0x7FFF)-(curStickY&0x8000);

				float fx=reading.axes[0];
				float fy=reading.axes[1];
				fx=ApplyZeroZone(fx,mouseByFlightstickZeroZoneX);
				fy=ApplyZeroZone(fy,mouseByFlightstickZeroZoneY);
				int inputX=(int)(fx*80.0f);  // Thrustmaster does not really let stick coord move to the corner.
				int inputY=(int)(fy*80.0f);  // Should take some buffer to let it maneuver at full rotational speed.  (64.0->80.0)

				if(inputX<-63)
				{
					inputX=-63;
				}
				if(63<inputX)
				{
					inputX=63;
				}
				if(inputY<-63)
				{
					inputY=-63;
				}
				if(63<inputY)
				{
					inputY=63;
				}

				// Joystick Input Left=negative Right=positive    NoseUp=positive NoseDown=negative
				// Wing Commander Internal  Left=negative RIght=positive    NoseUp=positive NoseDown=negative
				int diffX=inputX-curStickX;
				int diffY=inputY-curStickY;

				if(diffX<-15)
				{
					diffX=-15;
				}
				if(15<diffX)
				{
					diffX=15;
				}
				if(diffY<-15)
				{
					diffY=-15;
				}
				if(15<diffY)
				{
					diffY=15;
				}

				towns.SetMouseButtonState((0!=lb),(0!=rb));
				for(auto &p : towns.gameport.state.ports)
				{
					if(p.device==TownsGamePort::MOUSE)
					{
						p.mouseMotion.Set(-diffX,-diffY);
					}
				}
			}
			else if(true==mouseByFlightstickEnabled && TOWNS_APPSPECIFIC_AIRWARRIOR_V2==towns.state.appSpecificSetting)
			{
				// Wing Commander 1 turned out to be using separate joystick position from the mouse coordinate.
				// Need to translate to the mouse coordinate.
				int curStickX,curStickY;
				curStickX=towns.mem.FetchDword(towns.state.appSpecific_StickPosXPtr);
				curStickY=towns.mem.FetchDword(towns.state.appSpecific_StickPosYPtr);
				curStickX=(curStickX&0x7FFF)-(curStickX&0x8000);
				curStickY=(curStickY&0x7FFF)-(curStickY&0x8000);

				float fx=reading.axes[0];
				float fy=reading.axes[1];
				fx=ApplyZeroZone(fx,mouseByFlightstickZeroZoneX);
				fy=ApplyZeroZone(fy,mouseByFlightstickZeroZoneY);
				int inputX=(int)(fx*250.0f);
				int inputY=(int)(fy*250.0f);

				// Joystick Input Left=negative Right=positive    NoseUp=positive NoseDown=negative
				// Wing Commander Internal  Left=negative RIght=positive    NoseUp=positive NoseDown=negative
				int diffX=inputX-curStickX;
				int diffY=inputY-curStickY;

				if(diffX<-80)
				{
					diffX=-80;
				}
				if(80<diffX)
				{
					diffX=80;
				}
				if(diffY<-80)
				{
					diffY=-80;
				}
				if(80<diffY)
				{
					diffY=80;
				}

				const int minimum_threshold=16;
				if(-minimum_threshold<diffX && diffX<0)
				{
					diffX=-minimum_threshold;
				}
				if(0<diffX && diffX<minimum_threshold)
				{
					diffX=minimum_threshold;
				}
				if(-minimum_threshold<diffY && diffY<0)
				{
					diffY=-minimum_threshold;
				}
				if(0<diffY && diffY<minimum_threshold)
				{
					diffY=minimum_threshold;
				}

				towns.SetMouseButtonState((0!=lb),(0!=rb));
				for(auto &p : towns.gameport.state.ports)
				{
					if(p.device==TownsGamePort::MOUSE)
					{
						p.mouseMotion.Set(-diffX,-diffY);
					}
				}
			}
			else if(true==mouseByFlightstickEnabled)
			{
				float fx=reading.axes[0];
				float fy=reading.axes[1];
				fx=ApplyZeroZone(fx,mouseByFlightstickZeroZoneX);
				fy=ApplyZeroZone(fy,mouseByFlightstickZeroZoneY);
				fx*=mouseByFlightstickScaleX;
                fy*=mouseByFlightstickScaleY;
				mx=mouseByFlightstickCenterX+(int)fx;
				my=mouseByFlightstickCenterY+(int)fy;
				lb=reading.buttons[0];
				rb=reading.buttons[1];
				if(TOWNS_APPSPECIFIC_WINGCOMMANDER2==towns.state.appSpecificSetting)
				{
					// Wing Commander 2 allows negative mouse coordinate, or the control will be really slow nose down.
					// But sending below -120 (2x scale) apparently changes the neutral position.
					if(mx<-20)
					{
						mx=-20;
					}
					if(my<-240)
					{
						my=-240;
					}
				}
				else
				{
					if(mx<0)
					{
						mx=0;
					}
					if(my<0)
					{
						my=0;
					}
				}
				this->ProcessMouse(towns,lb,mb,rb,mx,my);
			}
			else
			{
				int wid=windowEvent.winWid;
				int hei=windowEvent.winHei;
				if(mx<0)
				{
					mx=0;
				}
				else if(wid<=mx)
				{
					mx=wid-1;
				}
				if(my<0)
				{
					my=0;
				}
				else if(hei<=my)
				{
					my=hei-1;
				}
				if(0!=scalingX && 0!=scalingY) // Just in case
				{
					mx=mx*100/scalingX;
					my=my*100/scalingY;
				}
				if(true!=differentialMouseIntegration)
				{
					this->ProcessMouse(towns,lb,mb,rb,mx,my);
				}
				else
				{
					int dx=windowEvent.mouseMoveXY[0];
					int dy=windowEvent.mouseMoveXY[1];
					this->ProcessMouseDifferential(towns,lb,mb,rb,dx,dy,wid/2,hei/2);
				}
			}
		}
	}
}

/* virtual */ bool FsSimpleWindowConnection::ImageNeedsFlip(void)
{
	return false;
}
/* virtual */ void FsSimpleWindowConnection::SetKeyboardLayout(unsigned int layout)
{
	MakeKeyMapFromLayout(FSKEYtoTownsKEY,layout);
}

/* static */ void FsSimpleWindowConnection::MakeKeyMapFromLayout(unsigned int FSKEYtoTownsKEY[FSKEY_NUM_KEYCODE],unsigned int layout)
{
	for(int i=0; i<FSKEY_NUM_KEYCODE; ++i)
	{
		FSKEYtoTownsKEY[i]=TOWNS_JISKEY_NULL;
	}
	FSKEYtoTownsKEY[FSKEY_NULL]=        TOWNS_JISKEY_NULL;
	FSKEYtoTownsKEY[FSKEY_SPACE]=       TOWNS_JISKEY_SPACE;
	FSKEYtoTownsKEY[FSKEY_0]=           TOWNS_JISKEY_0;
	FSKEYtoTownsKEY[FSKEY_1]=           TOWNS_JISKEY_1;
	FSKEYtoTownsKEY[FSKEY_2]=           TOWNS_JISKEY_2;
	FSKEYtoTownsKEY[FSKEY_3]=           TOWNS_JISKEY_3;
	FSKEYtoTownsKEY[FSKEY_4]=           TOWNS_JISKEY_4;
	FSKEYtoTownsKEY[FSKEY_5]=           TOWNS_JISKEY_5;
	FSKEYtoTownsKEY[FSKEY_6]=           TOWNS_JISKEY_6;
	FSKEYtoTownsKEY[FSKEY_7]=           TOWNS_JISKEY_7;
	FSKEYtoTownsKEY[FSKEY_8]=           TOWNS_JISKEY_8;
	FSKEYtoTownsKEY[FSKEY_9]=           TOWNS_JISKEY_9;
	FSKEYtoTownsKEY[FSKEY_A]=           TOWNS_JISKEY_A;
	FSKEYtoTownsKEY[FSKEY_B]=           TOWNS_JISKEY_B;
	FSKEYtoTownsKEY[FSKEY_C]=           TOWNS_JISKEY_C;
	FSKEYtoTownsKEY[FSKEY_D]=           TOWNS_JISKEY_D;
	FSKEYtoTownsKEY[FSKEY_E]=           TOWNS_JISKEY_E;
	FSKEYtoTownsKEY[FSKEY_F]=           TOWNS_JISKEY_F;
	FSKEYtoTownsKEY[FSKEY_G]=           TOWNS_JISKEY_G;
	FSKEYtoTownsKEY[FSKEY_H]=           TOWNS_JISKEY_H;
	FSKEYtoTownsKEY[FSKEY_I]=           TOWNS_JISKEY_I;
	FSKEYtoTownsKEY[FSKEY_J]=           TOWNS_JISKEY_J;
	FSKEYtoTownsKEY[FSKEY_K]=           TOWNS_JISKEY_K;
	FSKEYtoTownsKEY[FSKEY_L]=           TOWNS_JISKEY_L;
	FSKEYtoTownsKEY[FSKEY_M]=           TOWNS_JISKEY_M;
	FSKEYtoTownsKEY[FSKEY_N]=           TOWNS_JISKEY_N;
	FSKEYtoTownsKEY[FSKEY_O]=           TOWNS_JISKEY_O;
	FSKEYtoTownsKEY[FSKEY_P]=           TOWNS_JISKEY_P;
	FSKEYtoTownsKEY[FSKEY_Q]=           TOWNS_JISKEY_Q;
	FSKEYtoTownsKEY[FSKEY_R]=           TOWNS_JISKEY_R;
	FSKEYtoTownsKEY[FSKEY_S]=           TOWNS_JISKEY_S;
	FSKEYtoTownsKEY[FSKEY_T]=           TOWNS_JISKEY_T;
	FSKEYtoTownsKEY[FSKEY_U]=           TOWNS_JISKEY_U;
	FSKEYtoTownsKEY[FSKEY_V]=           TOWNS_JISKEY_V;
	FSKEYtoTownsKEY[FSKEY_W]=           TOWNS_JISKEY_W;
	FSKEYtoTownsKEY[FSKEY_X]=           TOWNS_JISKEY_X;
	FSKEYtoTownsKEY[FSKEY_Y]=           TOWNS_JISKEY_Y;
	FSKEYtoTownsKEY[FSKEY_Z]=           TOWNS_JISKEY_Z;
	FSKEYtoTownsKEY[FSKEY_ESC]=         TOWNS_JISKEY_BREAK;
	FSKEYtoTownsKEY[FSKEY_F1]=          TOWNS_JISKEY_PF01;
	FSKEYtoTownsKEY[FSKEY_F2]=          TOWNS_JISKEY_PF02;
	FSKEYtoTownsKEY[FSKEY_F3]=          TOWNS_JISKEY_PF03;
	FSKEYtoTownsKEY[FSKEY_F4]=          TOWNS_JISKEY_PF04;
	FSKEYtoTownsKEY[FSKEY_F5]=          TOWNS_JISKEY_PF05;
	FSKEYtoTownsKEY[FSKEY_F6]=          TOWNS_JISKEY_PF06;
	FSKEYtoTownsKEY[FSKEY_F7]=          TOWNS_JISKEY_PF07;
	FSKEYtoTownsKEY[FSKEY_F8]=          TOWNS_JISKEY_PF08;
	FSKEYtoTownsKEY[FSKEY_F9]=          TOWNS_JISKEY_PF09;
	FSKEYtoTownsKEY[FSKEY_F10]=         TOWNS_JISKEY_PF10;
	FSKEYtoTownsKEY[FSKEY_F11]=         TOWNS_JISKEY_PF11;
	FSKEYtoTownsKEY[FSKEY_F12]=         TOWNS_JISKEY_PF12;
	FSKEYtoTownsKEY[FSKEY_PRINTSCRN]=   TOWNS_JISKEY_NULL;
	FSKEYtoTownsKEY[FSKEY_CAPSLOCK]=    TOWNS_JISKEY_CAPS;
	FSKEYtoTownsKEY[FSKEY_SCROLLLOCK]=  TOWNS_JISKEY_NULL; // Can assign something later.
	FSKEYtoTownsKEY[FSKEY_PAUSEBREAK]=  TOWNS_JISKEY_BREAK;
	FSKEYtoTownsKEY[FSKEY_BS]=          TOWNS_JISKEY_BACKSPACE;
	FSKEYtoTownsKEY[FSKEY_TAB]=         TOWNS_JISKEY_TAB;
	FSKEYtoTownsKEY[FSKEY_ENTER]=       TOWNS_JISKEY_RETURN;
	FSKEYtoTownsKEY[FSKEY_SHIFT]=       TOWNS_JISKEY_SHIFT;
	FSKEYtoTownsKEY[FSKEY_CTRL]=        TOWNS_JISKEY_CTRL;
	FSKEYtoTownsKEY[FSKEY_ALT]=         TOWNS_JISKEY_NULL; // Can assign something later.
	FSKEYtoTownsKEY[FSKEY_INS]=         TOWNS_JISKEY_INSERT;
	FSKEYtoTownsKEY[FSKEY_DEL]=         TOWNS_JISKEY_DELETE;
	FSKEYtoTownsKEY[FSKEY_HOME]=        TOWNS_JISKEY_HOME;
	FSKEYtoTownsKEY[FSKEY_END]=         TOWNS_JISKEY_NULL; // Should be translated as SHIFT+DEL
	FSKEYtoTownsKEY[FSKEY_PAGEUP]=      TOWNS_JISKEY_PREV;
	FSKEYtoTownsKEY[FSKEY_PAGEDOWN]=    TOWNS_JISKEY_NEXT;
	FSKEYtoTownsKEY[FSKEY_UP]=          TOWNS_JISKEY_UP;
	FSKEYtoTownsKEY[FSKEY_DOWN]=        TOWNS_JISKEY_DOWN;
	FSKEYtoTownsKEY[FSKEY_LEFT]=        TOWNS_JISKEY_LEFT;
	FSKEYtoTownsKEY[FSKEY_RIGHT]=       TOWNS_JISKEY_RIGHT;
	FSKEYtoTownsKEY[FSKEY_NUMLOCK]=     TOWNS_JISKEY_NULL; // Can assign something later.
	FSKEYtoTownsKEY[FSKEY_TILDA]=       TOWNS_JISKEY_ESC;
	FSKEYtoTownsKEY[FSKEY_MINUS]=       TOWNS_JISKEY_MINUS;
	FSKEYtoTownsKEY[FSKEY_PLUS]=        TOWNS_JISKEY_HAT;
	FSKEYtoTownsKEY[FSKEY_LBRACKET]=    TOWNS_JISKEY_LEFT_SQ_BRACKET;
	FSKEYtoTownsKEY[FSKEY_RBRACKET]=    TOWNS_JISKEY_RIGHT_SQ_BRACKET;
	FSKEYtoTownsKEY[FSKEY_BACKSLASH]=   TOWNS_JISKEY_BACKSLASH;
	FSKEYtoTownsKEY[FSKEY_SEMICOLON]=   TOWNS_JISKEY_SEMICOLON;
	FSKEYtoTownsKEY[FSKEY_SINGLEQUOTE]= TOWNS_JISKEY_COLON;
	FSKEYtoTownsKEY[FSKEY_COMMA]=       TOWNS_JISKEY_COMMA;
	FSKEYtoTownsKEY[FSKEY_DOT]=         TOWNS_JISKEY_DOT;
	FSKEYtoTownsKEY[FSKEY_SLASH]=       TOWNS_JISKEY_SLASH;
	FSKEYtoTownsKEY[FSKEY_TEN0]=        TOWNS_JISKEY_NUM_0;
	FSKEYtoTownsKEY[FSKEY_TEN1]=        TOWNS_JISKEY_NUM_1;
	FSKEYtoTownsKEY[FSKEY_TEN2]=        TOWNS_JISKEY_NUM_2;
	FSKEYtoTownsKEY[FSKEY_TEN3]=        TOWNS_JISKEY_NUM_3;
	FSKEYtoTownsKEY[FSKEY_TEN4]=        TOWNS_JISKEY_NUM_4;
	FSKEYtoTownsKEY[FSKEY_TEN5]=        TOWNS_JISKEY_NUM_5;
	FSKEYtoTownsKEY[FSKEY_TEN6]=        TOWNS_JISKEY_NUM_6;
	FSKEYtoTownsKEY[FSKEY_TEN7]=        TOWNS_JISKEY_NUM_7;
	FSKEYtoTownsKEY[FSKEY_TEN8]=        TOWNS_JISKEY_NUM_8;
	FSKEYtoTownsKEY[FSKEY_TEN9]=        TOWNS_JISKEY_NUM_9;
	FSKEYtoTownsKEY[FSKEY_TENDOT]=      TOWNS_JISKEY_NUM_DOT;
	FSKEYtoTownsKEY[FSKEY_TENSLASH]=    TOWNS_JISKEY_NUM_SLASH;
	FSKEYtoTownsKEY[FSKEY_TENSTAR]=     TOWNS_JISKEY_NUM_STAR;
	FSKEYtoTownsKEY[FSKEY_TENMINUS]=    TOWNS_JISKEY_NUM_MINUS;
	FSKEYtoTownsKEY[FSKEY_TENPLUS]=     TOWNS_JISKEY_NUM_PLUS;
	FSKEYtoTownsKEY[FSKEY_TENENTER]=    TOWNS_JISKEY_NUM_RETURN;
	FSKEYtoTownsKEY[FSKEY_WHEELUP]=     TOWNS_JISKEY_UP;
	FSKEYtoTownsKEY[FSKEY_WHEELDOWN]=   TOWNS_JISKEY_DOWN;
	FSKEYtoTownsKEY[FSKEY_CONTEXT]=     TOWNS_JISKEY_ALT; // Can assign something later.

	// Japanese keyboard
	FSKEYtoTownsKEY[FSKEY_CONVERT]=     TOWNS_JISKEY_CONVERT;
	FSKEYtoTownsKEY[FSKEY_NONCONVERT]=  TOWNS_JISKEY_NO_CONVERT;
	FSKEYtoTownsKEY[FSKEY_KANA]=        TOWNS_JISKEY_KATAKANA;
	// FSKEYtoTownsKEY[FSKEY_COLON]=       TOWNS_JISKEY_COLON; // Need to switch with single quote
	// FSKEYtoTownsKEY[FSKEY_AT]=          TOWNS_JISKEY_AT;  // FSKEY_AT collides with FSKEY_TILDA. This disables ESC.
	FSKEYtoTownsKEY[FSKEY_RO]=          TOWNS_JISKEY_DOUBLEQUOTE;

	// The following key codes won't be returned by FsInkey()
	// These may return non zero for FsGetKeyState
	FSKEYtoTownsKEY[FSKEY_LEFT_CTRL]=   TOWNS_JISKEY_CTRL;
	FSKEYtoTownsKEY[FSKEY_RIGHT_CTRL]=  TOWNS_JISKEY_CTRL;
	FSKEYtoTownsKEY[FSKEY_LEFT_SHIFT]=  TOWNS_JISKEY_SHIFT;
	FSKEYtoTownsKEY[FSKEY_RIGHT_SHIFT]= TOWNS_JISKEY_SHIFT;
	FSKEYtoTownsKEY[FSKEY_LEFT_ALT]=    TOWNS_JISKEY_NULL;
	FSKEYtoTownsKEY[FSKEY_RIGHT_ALT]=   TOWNS_JISKEY_NULL;
}

/* virtual */ void FsSimpleWindowConnection::RegisterHostShortCut(std::string hostKeyLabel,bool ctrl,bool shift,std::string cmdStr)
{
	auto fsKey=FsStringToKeyCode(hostKeyLabel.c_str());
	if(FSKEY_NULL!=fsKey)
	{
		hostShortCut[fsKey].inUse=true;
		hostShortCut[fsKey].ctrl=ctrl;
		hostShortCut[fsKey].shift=shift;
		hostShortCut[fsKey].cmdStr=cmdStr;
	}
}

/* virtual */ void FsSimpleWindowConnection::RegisterPauseResume(std::string hostKeyLabel)
{
	auto fsKey=FsStringToKeyCode(hostKeyLabel.c_str());
	if(FSKEY_NULL!=fsKey)
	{
		PAUSE_KEY_CODE=fsKey;
	}
	else
	{
		PAUSE_KEY_CODE=DEFAULT_PAUSE_KEY_CODE;
	}
}

void FsSimpleWindowConnection::PauseKeyPressed(void)
{
	if(0==windowEvent.keyState[FSKEY_SHIFT])
	{
		this->pauseKey=true;
	}
	else
	{
		ToggleMouseCursor();
	}
}

/* virtual */ void FsSimpleWindowConnection::ToggleMouseCursor(void)
{
	showMouseCursor=(showMouseCursor!=true);
}

////////////////////////////////////////////////////////////////

void FsSimpleWindowConnection::WindowConnection::Start(void)
{
	if(0==SDL_WasInit(SDL_INIT_VIDEO))
	{
		if(0>SDL_InitSubSystem(SDL_INIT_VIDEO))
		{
			fprintf(stderr,"SDL_InitSubSystem(VIDEO) failed: %s\n",SDL_GetError());
		}
	}

	// PAUSE and MENU icons.  Unlike the OpenGL back-end, SDL textures are
	// top-down, therefore the icons are copied without the vertical flip.
	PAUSEicon.resize(4*PAUSE_wid*PAUSE_hei);
	MENUicon.resize(4*MENU_wid*MENU_hei);
	for(int i=0; i<4*PAUSE_wid*PAUSE_hei; ++i)
	{
		PAUSEicon[i]=PAUSE[i];
	}
	for(int i=0; i<4*MENU_wid*MENU_hei; ++i)
	{
		MENUicon[i]=MENU[i];
	}

	if(nullptr==sdlWindow)
	{
		int wid=640*shared.scalingX/100;
		int hei=480*shared.scalingY/100;
		Uint32 flags=SDL_WINDOW_SHOWN;
		switch(windowModeOnStartUp)
		{
		case TownsStartParameters::WINDOW_MAXIMIZE:
		case TownsStartParameters::WINDOW_FULLSCREEN:
			flags|=SDL_WINDOW_FULLSCREEN_DESKTOP;
			break;
		case TownsStartParameters::WINDOW_SPECIFY_SIZE:
			wid=windowSizeOnStartUp[0];
			hei=windowSizeOnStartUp[1];
			break;
		}
		sdlWindow=SDL_CreateWindow(WINDOW_TITLE,SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,wid,hei+STATUS_HEI,flags);
		if(nullptr==sdlWindow)
		{
			fprintf(stderr,"SDL_CreateWindow failed: %s\n",SDL_GetError());
		}
		else
		{
			sdlRenderer=SDL_CreateRenderer(sdlWindow,-1,SDL_RENDERER_ACCELERATED|SDL_RENDERER_PRESENTVSYNC);
			if(nullptr==sdlRenderer)
			{
				sdlRenderer=SDL_CreateRenderer(sdlWindow,-1,0);
			}
			if(nullptr==sdlRenderer)
			{
				fprintf(stderr,"SDL_CreateRenderer failed: %s\n",SDL_GetError());
			}
		}
	}

	// On KMSDRM (EmuELEC) the window always covers the whole display.
	// Scale-to-fit with aspect ratio is the only sensible mode there,
	// and it also behaves well on a desktop.
	autoScaling=true;

	SDL_StartTextInput();

	winThr.winWid=640;
	winThr.winHei=480;

	if(nullptr!=sdlRenderer)
	{
		statusTex=SDL_CreateTexture(sdlRenderer,SDL_PIXELFORMAT_RGBA32,SDL_TEXTUREACCESS_STREAMING,STATUS_WID,STATUS_HEI);
		pauseIconTex=MakeStaticTexture(sdlRenderer,PAUSE_wid,PAUSE_hei,PAUSEicon.data());
		menuIconTex=MakeStaticTexture(sdlRenderer,MENU_wid,MENU_hei,MENUicon.data());
	}

	// Make initial status bitmap
	Put16x16Invert(0,15,CD_IDLE);
	for(int fd=0; fd<2; ++fd)
	{
		Put16x16Invert(16+16*fd,15,FD_IDLE);
	}
	for(int hdd=0; hdd<6; ++hdd)
	{
		Put16x16Invert(48+16*hdd,15,HDD_IDLE);
	}

	if(true!=winThrEx.gamePadInitialized)
	{
		YsGamePadInitialize();
		winThrEx.gamePadInitialized=true;
	}

	auto nGameDevs=YsGamePadGetNumDevices();
	if(0<nGameDevs)
	{
		winThrEx.primary.gamePads.resize(nGameDevs);
		for(unsigned int i=0; i<nGameDevs; ++i)
		{
			YsGamePadRead(&winThrEx.primary.gamePads[i],i);
		}
	}
}
void FsSimpleWindowConnection::WindowConnection::Stop(void)
{
	SDL_StopTextInput();
	if(nullptr!=mainTex)
	{
		SDL_DestroyTexture(mainTex);
		mainTex=nullptr;
		mainTexWid=0;
		mainTexHei=0;
	}
	if(nullptr!=statusTex)
	{
		SDL_DestroyTexture(statusTex);
		statusTex=nullptr;
	}
	if(nullptr!=pauseIconTex)
	{
		SDL_DestroyTexture(pauseIconTex);
		pauseIconTex=nullptr;
	}
	if(nullptr!=menuIconTex)
	{
		SDL_DestroyTexture(menuIconTex);
		menuIconTex=nullptr;
	}
}
static int SDLScancodeToFSKEY(int scancode)
{
	switch(scancode)
	{
	case SDL_SCANCODE_SPACE:        return FSKEY_SPACE;
	case SDL_SCANCODE_0:            return FSKEY_0;
	case SDL_SCANCODE_1:            return FSKEY_1;
	case SDL_SCANCODE_2:            return FSKEY_2;
	case SDL_SCANCODE_3:            return FSKEY_3;
	case SDL_SCANCODE_4:            return FSKEY_4;
	case SDL_SCANCODE_5:            return FSKEY_5;
	case SDL_SCANCODE_6:            return FSKEY_6;
	case SDL_SCANCODE_7:            return FSKEY_7;
	case SDL_SCANCODE_8:            return FSKEY_8;
	case SDL_SCANCODE_9:            return FSKEY_9;
	case SDL_SCANCODE_A:            return FSKEY_A;
	case SDL_SCANCODE_B:            return FSKEY_B;
	case SDL_SCANCODE_C:            return FSKEY_C;
	case SDL_SCANCODE_D:            return FSKEY_D;
	case SDL_SCANCODE_E:            return FSKEY_E;
	case SDL_SCANCODE_F:            return FSKEY_F;
	case SDL_SCANCODE_G:            return FSKEY_G;
	case SDL_SCANCODE_H:            return FSKEY_H;
	case SDL_SCANCODE_I:            return FSKEY_I;
	case SDL_SCANCODE_J:            return FSKEY_J;
	case SDL_SCANCODE_K:            return FSKEY_K;
	case SDL_SCANCODE_L:            return FSKEY_L;
	case SDL_SCANCODE_M:            return FSKEY_M;
	case SDL_SCANCODE_N:            return FSKEY_N;
	case SDL_SCANCODE_O:            return FSKEY_O;
	case SDL_SCANCODE_P:            return FSKEY_P;
	case SDL_SCANCODE_Q:            return FSKEY_Q;
	case SDL_SCANCODE_R:            return FSKEY_R;
	case SDL_SCANCODE_S:            return FSKEY_S;
	case SDL_SCANCODE_T:            return FSKEY_T;
	case SDL_SCANCODE_U:            return FSKEY_U;
	case SDL_SCANCODE_V:            return FSKEY_V;
	case SDL_SCANCODE_W:            return FSKEY_W;
	case SDL_SCANCODE_X:            return FSKEY_X;
	case SDL_SCANCODE_Y:            return FSKEY_Y;
	case SDL_SCANCODE_Z:            return FSKEY_Z;
	case SDL_SCANCODE_ESCAPE:       return FSKEY_ESC;
	case SDL_SCANCODE_F1:           return FSKEY_F1;
	case SDL_SCANCODE_F2:           return FSKEY_F2;
	case SDL_SCANCODE_F3:           return FSKEY_F3;
	case SDL_SCANCODE_F4:           return FSKEY_F4;
	case SDL_SCANCODE_F5:           return FSKEY_F5;
	case SDL_SCANCODE_F6:           return FSKEY_F6;
	case SDL_SCANCODE_F7:           return FSKEY_F7;
	case SDL_SCANCODE_F8:           return FSKEY_F8;
	case SDL_SCANCODE_F9:           return FSKEY_F9;
	case SDL_SCANCODE_F10:          return FSKEY_F10;
	case SDL_SCANCODE_F11:          return FSKEY_F11;
	case SDL_SCANCODE_F12:          return FSKEY_F12;
	case SDL_SCANCODE_PRINTSCREEN:  return FSKEY_PRINTSCRN;
	case SDL_SCANCODE_CAPSLOCK:     return FSKEY_CAPSLOCK;
	case SDL_SCANCODE_SCROLLLOCK:   return FSKEY_SCROLLLOCK;
	case SDL_SCANCODE_PAUSE:        return FSKEY_PAUSEBREAK;
	case SDL_SCANCODE_BACKSPACE:    return FSKEY_BS;
	case SDL_SCANCODE_TAB:          return FSKEY_TAB;
	case SDL_SCANCODE_RETURN:       return FSKEY_ENTER;
	case SDL_SCANCODE_LSHIFT:       return FSKEY_LEFT_SHIFT;
	case SDL_SCANCODE_RSHIFT:       return FSKEY_RIGHT_SHIFT;
	case SDL_SCANCODE_LCTRL:        return FSKEY_LEFT_CTRL;
	case SDL_SCANCODE_RCTRL:        return FSKEY_RIGHT_CTRL;
	case SDL_SCANCODE_LALT:         return FSKEY_LEFT_ALT;
	case SDL_SCANCODE_RALT:         return FSKEY_RIGHT_ALT;
	case SDL_SCANCODE_INSERT:       return FSKEY_INS;
	case SDL_SCANCODE_DELETE:       return FSKEY_DEL;
	case SDL_SCANCODE_HOME:         return FSKEY_HOME;
	case SDL_SCANCODE_END:          return FSKEY_END;
	case SDL_SCANCODE_PAGEUP:       return FSKEY_PAGEUP;
	case SDL_SCANCODE_PAGEDOWN:     return FSKEY_PAGEDOWN;
	case SDL_SCANCODE_UP:           return FSKEY_UP;
	case SDL_SCANCODE_DOWN:         return FSKEY_DOWN;
	case SDL_SCANCODE_LEFT:         return FSKEY_LEFT;
	case SDL_SCANCODE_RIGHT:        return FSKEY_RIGHT;
	case SDL_SCANCODE_NUMLOCKCLEAR: return FSKEY_NUMLOCK;
	case SDL_SCANCODE_GRAVE:        return FSKEY_TILDA;
	case SDL_SCANCODE_MINUS:        return FSKEY_MINUS;
	case SDL_SCANCODE_EQUALS:       return FSKEY_PLUS;
	case SDL_SCANCODE_LEFTBRACKET:  return FSKEY_LBRACKET;
	case SDL_SCANCODE_RIGHTBRACKET: return FSKEY_RBRACKET;
	case SDL_SCANCODE_BACKSLASH:    return FSKEY_BACKSLASH;
	case SDL_SCANCODE_SEMICOLON:    return FSKEY_SEMICOLON;
	case SDL_SCANCODE_APOSTROPHE:   return FSKEY_SINGLEQUOTE;
	case SDL_SCANCODE_COMMA:        return FSKEY_COMMA;
	case SDL_SCANCODE_PERIOD:       return FSKEY_DOT;
	case SDL_SCANCODE_SLASH:        return FSKEY_SLASH;
	case SDL_SCANCODE_KP_0:         return FSKEY_TEN0;
	case SDL_SCANCODE_KP_1:         return FSKEY_TEN1;
	case SDL_SCANCODE_KP_2:         return FSKEY_TEN2;
	case SDL_SCANCODE_KP_3:         return FSKEY_TEN3;
	case SDL_SCANCODE_KP_4:         return FSKEY_TEN4;
	case SDL_SCANCODE_KP_5:         return FSKEY_TEN5;
	case SDL_SCANCODE_KP_6:         return FSKEY_TEN6;
	case SDL_SCANCODE_KP_7:         return FSKEY_TEN7;
	case SDL_SCANCODE_KP_8:         return FSKEY_TEN8;
	case SDL_SCANCODE_KP_9:         return FSKEY_TEN9;
	case SDL_SCANCODE_KP_PERIOD:    return FSKEY_TENDOT;
	case SDL_SCANCODE_KP_DIVIDE:    return FSKEY_TENSLASH;
	case SDL_SCANCODE_KP_MULTIPLY:  return FSKEY_TENSTAR;
	case SDL_SCANCODE_KP_MINUS:     return FSKEY_TENMINUS;
	case SDL_SCANCODE_KP_PLUS:      return FSKEY_TENPLUS;
	case SDL_SCANCODE_KP_ENTER:     return FSKEY_TENENTER;
	case SDL_SCANCODE_APPLICATION:  return FSKEY_CONTEXT;
	case SDL_SCANCODE_INTERNATIONAL3: return FSKEY_RO;        // JIS RO
	case SDL_SCANCODE_INTERNATIONAL4: return FSKEY_CONVERT;   // Henkan
	case SDL_SCANCODE_INTERNATIONAL5: return FSKEY_NONCONVERT;// Muhenkan
	case SDL_SCANCODE_LANG1:        return FSKEY_KANA;
	case SDL_SCANCODE_LANG5:        return FSKEY_ZENKAKU;
	}
	return FSKEY_NULL;
}

/*! Called from the Window Thread.
*/
void FsSimpleWindowConnection::WindowConnection::Interval(void)
{
	BaseInterval();

	SDL_Event sdlEvent;
	while(0!=SDL_PollEvent(&sdlEvent))
	{
		switch(sdlEvent.type)
		{
		case SDL_QUIT:
			{
				std::lock_guard <std::mutex> lock(deviceStateLock);
				closeWindow=true;
			}
			break;
		case SDL_KEYDOWN:
			if(0==sdlEvent.key.repeat)
			{
				auto fskey=SDLScancodeToFSKEY(sdlEvent.key.keysym.scancode);
				if(FSKEY_NULL!=fskey)
				{
					winThrEx.primary.keyCode.push_back(fskey);
				}
			}
			break;
		case SDL_TEXTINPUT:
			for(const char *ptr=sdlEvent.text.text; 0!=*ptr; ++ptr)
			{
				auto c=(unsigned char)*ptr;
				if(c<0x80) // ASCII only.  FM Towns doesn't take UTF-8 anyway.
				{
					winThrEx.primary.charCode.push_back(c);
				}
			}
			break;
		case SDL_MOUSEBUTTONDOWN:
		case SDL_MOUSEBUTTONUP:
			{
				bool down=(SDL_MOUSEBUTTONDOWN==sdlEvent.type);
				MouseEvent mos;
				mos.evt=FSMOUSEEVENT_NONE;
				switch(sdlEvent.button.button)
				{
				case SDL_BUTTON_LEFT:
					mouseLb=(down ? 1 : 0);
					mos.evt=(down ? FSMOUSEEVENT_LBUTTONDOWN : FSMOUSEEVENT_LBUTTONUP);
					break;
				case SDL_BUTTON_MIDDLE:
					mouseMb=(down ? 1 : 0);
					mos.evt=(down ? FSMOUSEEVENT_MBUTTONDOWN : FSMOUSEEVENT_MBUTTONUP);
					break;
				case SDL_BUTTON_RIGHT:
					mouseRb=(down ? 1 : 0);
					mos.evt=(down ? FSMOUSEEVENT_RBUTTONDOWN : FSMOUSEEVENT_RBUTTONUP);
					break;
				}
				mouseX=sdlEvent.button.x;
				mouseY=sdlEvent.button.y;
				if(FSMOUSEEVENT_NONE!=mos.evt)
				{
					mos.lb=mouseLb;
					mos.mb=mouseMb;
					mos.rb=mouseRb;
					mos.mx=mouseX;
					mos.my=mouseY;
					winThrEx.primary.mouseEvents.push_back(mos);
					winThrEx.primary.lastKnownMouse=mos;
				}
			}
			break;
		case SDL_MOUSEMOTION:
			{
				mouseX=sdlEvent.motion.x;
				mouseY=sdlEvent.motion.y;
				MouseEvent mos;
				mos.evt=FSMOUSEEVENT_MOVE;
				mos.lb=mouseLb;
				mos.mb=mouseMb;
				mos.rb=mouseRb;
				mos.mx=mouseX;
				mos.my=mouseY;
				winThrEx.primary.mouseEvents.push_back(mos);
				winThrEx.primary.lastKnownMouse=mos;
			}
			break;
		case SDL_MOUSEWHEEL:
			winThrEx.primary.keyCode.push_back(0<sdlEvent.wheel.y ? FSKEY_WHEELUP : FSKEY_WHEELDOWN);
			break;
		}
	}

	if(nullptr!=sdlWindow)
	{
		SDL_GetWindowSize(sdlWindow,&winThrEx.primary.winWid,&winThrEx.primary.winHei);
	}

	// Key states from SDL's keyboard-state array, translated into the FSKEY space.
	{
		int numSDLKeys=0;
		const Uint8 *sdlKeyState=SDL_GetKeyboardState(&numSDLKeys);
		for(int key=0; key<FSKEY_NUM_KEYCODE; ++key)
		{
			winThrEx.primary.keyState[key]=0;
		}
		for(int sc=0; sc<numSDLKeys; ++sc)
		{
			if(0!=sdlKeyState[sc])
			{
				auto fskey=SDLScancodeToFSKEY(sc);
				if(FSKEY_NULL!=fskey)
				{
					winThrEx.primary.keyState[fskey]=1;
				}
			}
		}
		// Aggregate modifiers.  DevicePolling uses FSKEY_SHIFT/CTRL/ALT.
		if(0!=winThrEx.primary.keyState[FSKEY_LEFT_SHIFT] || 0!=winThrEx.primary.keyState[FSKEY_RIGHT_SHIFT])
		{
			winThrEx.primary.keyState[FSKEY_SHIFT]=1;
		}
		if(0!=winThrEx.primary.keyState[FSKEY_LEFT_CTRL] || 0!=winThrEx.primary.keyState[FSKEY_RIGHT_CTRL])
		{
			winThrEx.primary.keyState[FSKEY_CTRL]=1;
		}
		if(0!=winThrEx.primary.keyState[FSKEY_LEFT_ALT] || 0!=winThrEx.primary.keyState[FSKEY_RIGHT_ALT])
		{
			winThrEx.primary.keyState[FSKEY_ALT]=1;
		}
	}

	if(true==shared.differentialMouseIntegration)
	{
		int mx,my;
		SDL_GetMouseState(&mx,&my);

		winThrEx.primary.mouseMoveXY[0]+=mx-diffMouseXY[0];
		winThrEx.primary.mouseMoveXY[1]+=my-diffMouseXY[1];

		diffMouseXY[0]=mx;
		diffMouseXY[1]=my;

		int minX=winThrEx.primary.winWid/4;
		int minY=winThrEx.primary.winHei/4;
		int maxX=winThrEx.primary.winWid*3/4;
		int maxY=winThrEx.primary.winHei*3/4;

		if(mx<minX || my<minY ||
           maxX<mx || maxY<my)
        {
			int cx=winThrEx.primary.winWid/2;
			int cy=winThrEx.primary.winHei/2;

			diffMouseXY[0]=cx;
			diffMouseXY[1]=cy;

			if(nullptr!=sdlWindow)
			{
				SDL_WarpMouseInWindow(sdlWindow,cx,cy);
			}
		}
	}

	PollGamePads();

	{
		std::lock_guard <std::mutex> lock(deviceStateLock);

		bool mouseCursorVisible=(true!=shared.differentialMouseIntegration && true==shared.showMouseCursor);
		if(mouseCursorVisible!=(SDL_ENABLE==SDL_ShowCursor(SDL_QUERY)))
		{
			SDL_ShowCursor(true==mouseCursorVisible ? SDL_ENABLE : SDL_DISABLE);
		}

		winThr.VMClosed=shared.VMClosedFromVMThread;
		winThr.gamePadsNeedUpdate=shared.gamePadsNeedUpdate;
		if(true==sharedEx.readyToSend.EventEmpty())
		{
			sharedEx.readyToSend=winThrEx.primary;
			winThrEx.primary.CleanUpEvents();
		}
	}
}
/*! Called from the Window thread.
      VM thread may access scaling, dx, dy, and lowerRightIcon, which therefore must be locked.
*/
void FsSimpleWindowConnection::WindowConnection::Render(bool swapBuffers)
{
	if(nullptr==sdlWindow || nullptr==sdlRenderer)
	{
		return;
	}

	int winWid,winHei;
	SDL_GetWindowSize(sdlWindow,&winWid,&winHei);

	if(0==winThr.mostRecentImage.wid || 0==winThr.mostRecentImage.hei)
	{
		return;
	}

	auto imgWid=winThr.mostRecentImage.wid;
	auto imgHei=winThr.mostRecentImage.hei;

	// {
	renderingLock.lock();

	if(true==autoScaling)
	{
		if(true==maintainAspect)
		{
			if(0<imgWid && 0<imgHei)
			{
				unsigned int scaleX=100*winWid/imgWid;
				unsigned int scaleY=100*(winHei-STATUS_HEI)/imgHei;
				shared.scalingX=std::min(scaleX,scaleY);
				shared.scalingY=shared.scalingX;
			}
		}
		else
		{
			if(0<imgWid && 0<imgHei)
			{
				shared.scalingX=100*winWid/imgWid;
				shared.scalingY=100*(winHei-STATUS_HEI)/imgHei;
			}
		}
	}

	unsigned int renderWid=imgWid*shared.scalingX/100;
	unsigned int renderHei=imgHei*shared.scalingY/100;
	shared.dx=(renderWid<winWid ? (winWid-renderWid)/2 : 0);
	shared.dy=(renderHei<(winHei-STATUS_HEI) ? (winHei-STATUS_HEI-renderHei)/2 : 0);

	UpdateStatusBitmap();

	if(nullptr!=statusTex)
	{
		SDL_UpdateTexture(statusTex,nullptr,winThr.statusBitmap,STATUS_WID*4);
	}
	UpdateTextureSDL(mainTex,mainTexWid,mainTexHei,winThr.mostRecentImage.wid,winThr.mostRecentImage.hei,winThr.mostRecentImage.rgba.data());

	auto lowerRightIcon=shared.lowerRightIcon;

	auto dx=shared.dx;
	auto dy=shared.dy;
	auto scalingX=shared.scalingX;
	auto scalingY=shared.scalingY;

	auto strikeCommanderSpecial=sharedEx.statusBarInfo.strikeCommanderSpecial;
	auto rocketRangerSpecial=sharedEx.statusBarInfo.rocketRangerSpecial;
	auto rocketRangerTiming=sharedEx.statusBarInfo.rocketRangerTiming;
	auto rocketRangerSpeed=sharedEx.statusBarInfo.rocketRangerSpeed;
	auto rocketRangerNecessarySpeed=sharedEx.statusBarInfo.rocketRangerNecessarySpeed;

	renderingLock.unlock();
	// }

	// Unlike the OpenGL back-end there is no window resizing here.
	// On KMSDRM the window is the display; autoScaling handles the rest.

	SDL_SetRenderDrawColor(sdlRenderer,0,0,0,255);
	SDL_RenderClear(sdlRenderer);

	// Status bar.  The status bitmap is written bottom-up (OpenGL convention
	// of the original back-end and of Outside_World::WindowInterface::Put16x16),
	// therefore it is drawn vertically flipped.
	if(nullptr!=statusTex)
	{
		SDL_Rect dst;
		dst.x=0;
		dst.y=winHei-STATUS_HEI;
		dst.w=STATUS_WID;
		dst.h=STATUS_HEI;
		SDL_RenderCopyEx(sdlRenderer,statusTex,nullptr,&dst,0.0,nullptr,SDL_FLIP_VERTICAL);
	}

	switch(lowerRightIcon)
	{
	case LOWER_RIGHT_NONE:
		break;
	case LOWER_RIGHT_PAUSE:
		if(nullptr!=pauseIconTex)
		{
			SDL_Rect dst;
			dst.x=winWid-PAUSE_wid;
			dst.y=winHei-PAUSE_hei;
			dst.w=PAUSE_wid;
			dst.h=PAUSE_hei;
			SDL_RenderCopy(sdlRenderer,pauseIconTex,nullptr,&dst);
		}
		break;
	case LOWER_RIGHT_MENU:
		if(nullptr!=menuIconTex)
		{
			SDL_Rect dst;
			dst.x=winWid-MENU_wid;
			dst.y=winHei-MENU_hei;
			dst.w=MENU_wid;
			dst.h=MENU_hei;
			SDL_RenderCopy(sdlRenderer,menuIconTex,nullptr,&dst);
		}
		break;
	}

	// Main VM image.  ImageNeedsFlip() is false: rows are top-down, drawn as-is.
	if(nullptr!=mainTex)
	{
		SDL_Rect dst;
		dst.x=dx;
		dst.y=dy;
		dst.w=imgWid*scalingX/100;
		dst.h=imgHei*scalingY/100;
		SDL_RenderCopy(sdlRenderer,mainTex,nullptr,&dst);
	}

	if(true==strikeCommanderSpecial)
	{
		int x;
		SDL_SetRenderDrawColor(sdlRenderer,128,128,255,255);

		x=dx+160*2*scalingX/100;
		SDL_RenderDrawLine(sdlRenderer,x,winHei-1,x,winHei-STATUS_HEI+1);

		x=dx+224*2*scalingX/100;
		SDL_RenderDrawLine(sdlRenderer,x,winHei-1,x,winHei-STATUS_HEI+1);

		x=dx+278*2*scalingX/100;
		SDL_RenderDrawLine(sdlRenderer,x,winHei-1,x,winHei-STATUS_HEI+1);
	}

	if(true==rocketRangerSpecial)
	{
		int x0=dx+100*2*scalingX/100;
		int x1=dx+130*2*scalingX/100;

		int x2=dx+220*2*scalingX/100;
		int x3=dx+250*2*scalingX/100;

		// timing: Cyclic Counter 2 to 0x20.
		//         Button should be pressed when the number is 05h or 17h, released when the number is 9
		//         Timing:
		//         2->5->8->11->14->17->20->23->26->29->32
		//           On  Off                On  Off
		int t=rocketRangerTiming;

		SDL_Rect rect;

		if((2<=t && t<=5) || (20<=t && t<=23))
		{
			SDL_SetRenderDrawColor(sdlRenderer,255,255,255,255);
		}
		else
		{
			SDL_SetRenderDrawColor(sdlRenderer,0,0,0,255);
		}
		rect.x=x0;
		rect.y=winHei-STATUS_HEI+1;
		rect.w=x1-x0;
		rect.h=STATUS_HEI-2;
		SDL_RenderFillRect(sdlRenderer,&rect);

		if(rocketRangerSpeed<rocketRangerNecessarySpeed)
		{
			SDL_SetRenderDrawColor(sdlRenderer,255,0,0,255);
		}
		else
		{
			SDL_SetRenderDrawColor(sdlRenderer,0,255,0,255);
		}
		rect.x=x2;
		rect.y=winHei-STATUS_HEI+1;
		rect.w=x3-x2;
		rect.h=STATUS_HEI-2;
		SDL_RenderFillRect(sdlRenderer,&rect);
	}

	if(true==swapBuffers)
	{
		SDL_RenderPresent(sdlRenderer);
	}
}

void FsSimpleWindowConnection::WindowConnection::UpdateImage(TownsRender::ImageCopy &img)
{
	renderingLock.lock();
	std::swap(winThr.mostRecentImage,img);
	renderingLock.unlock();
}

/*! Called in the VM thread.
    WindowInterface  ->(Device State)-> Outside_World
    WindowInterface  <-(Game Pads In Use)<- Outside_World
    WindowInterface  <-(Show Mouse Cursor) <- Outside_World
*/
void FsSimpleWindowConnection::WindowConnection::Communicate(Outside_World *ow)
{
	auto outside_world=dynamic_cast<FsSimpleWindowConnection*>(ow);
	std::swap(outside_world->prevGamePads,outside_world->windowEvent.gamePads);

	{
		std::lock_guard<std::mutex> lock(deviceStateLock);

		// Kind of want to use swap, but Communicate can be called more than once before the
		// next Interval is called, in which case state can go back and force between two
		// samples.  Therefore, copy here.
		outside_world->windowEvent=sharedEx.readyToSend;
		sharedEx.readyToSend.CleanUpEvents();

		shared.gamePadsNeedUpdate=outside_world->gamePadsNeedUpdate;
		shared.showMouseCursor=outside_world->showMouseCursor;
		shared.differentialMouseIntegration=outside_world->differentialMouseIntegration;

		outside_world->closeWindow=closeWindow;
	}
	{
		std::lock_guard<std::mutex> lock(renderingLock);

		sharedEx.statusBarInfo=outside_world->statusBarInfo;
		shared.lowerRightIcon=outside_world->lowerRightIcon;

		outside_world->scalingX=shared.scalingX;
		outside_world->scalingY=shared.scalingY;
		outside_world->dx=shared.dx;
		outside_world->dy=shared.dy;
	}
}

Outside_World::WindowInterface *FsSimpleWindowConnection::CreateWindowInterface(void) const
{
	return new WindowConnection;
}
void FsSimpleWindowConnection::DeleteWindowInterface(Outside_World::WindowInterface *PTR) const
{
	auto ptr=dynamic_cast<WindowConnection*>(PTR);
	if(nullptr!=ptr)
	{
		delete ptr;
	}
}

void FsSimpleWindowConnection::WindowConnection::PollGamePads(void)
{
	for(auto padId : winThr.gamePadsNeedUpdate)
	{
		if(padId<winThrEx.primary.gamePads.size())
		{
			YsGamePadRead(&winThrEx.primary.gamePads[padId],padId);
		}
	}
}

void FsSimpleWindowConnection::WindowConnection::UpdateStatusBitmap(void)
{
	// Update Status Bitmap
	if(winThrEx.prevStatusBarInfo.cdAccessLamp!=sharedEx.statusBarInfo.cdAccessLamp)
	{
		Put16x16SelectInvert(0,15,CD_IDLE,CD_BUSY,sharedEx.statusBarInfo.cdAccessLamp);
	}
	for(int fd=0; fd<2; ++fd)
	{
		if(winThrEx.prevStatusBarInfo.fdAccessLamp[fd]!=sharedEx.statusBarInfo.fdAccessLamp[fd])
		{
			Put16x16SelectInvert(16+16*fd,15,FD_IDLE,FD_BUSY,sharedEx.statusBarInfo.fdAccessLamp[fd]);
		}
	}
	for(int hdd=0; hdd<6; ++hdd)
	{
		if(winThrEx.prevStatusBarInfo.scsiAccessLamp[hdd]!=sharedEx.statusBarInfo.scsiAccessLamp[hdd])
		{
			Put16x16SelectInvert(48+16*hdd,15,HDD_IDLE,HDD_BUSY,sharedEx.statusBarInfo.scsiAccessLamp[hdd]);
		}
	}

	if(true==sharedEx.statusBarInfo.rocketRangerSpecial &&
	   sharedEx.statusBarInfo.rocketRangerPosition!=winThrEx.prevStatusBarInfo.rocketRangerPosition)
	{
		UpdateStatusBitmapRocketRangerSpecial(sharedEx.statusBarInfo.rocketRangerPosition);
	}


	winThrEx.prevStatusBarInfo=sharedEx.statusBarInfo;
}

void FsSimpleWindowConnection::WindowConnection::UpdateStatusBitmapRocketRangerSpecial(unsigned int position)
{
	const char *const countries[]=
	{
		"ATLANTIC   ",		"USA        ",		"CANADA     ",		"COLUMBIA   ",
		"ARABIA     ",		"VENEZUELA  ",		"PERU       ",		"BRAZIL     ",
		"CONGO      ",		"KENYA      ",		"EAST AFRICA",		"WEST AFRICA",
		"NIGERIA    ",		"SUDAN      ",		"ENGLAND    ",		"EGYPT      ",
		"U.S.S.R    ",		"PERSIA     ",		"LIBYA      ",		"MIDEAST    ",
		"SCANDINAVIA",		"ALGERIA    ",		"SPAIN      ",		"FRANCE     ",
		"YUGOSLAVIA ",		"ITALY      ",		"GERMANY    ",
	};
	if(position<0x1B)
	{
		Print(260,countries[position]);
	}
	else
	{
		Print(260,"UNKNOWN    ");
	}
}

void FsSimpleWindowConnection::WindowConnection::UpdateTextureSDL(SDL_Texture *&tex,int &texWid,int &texHei,int wid,int hei,const unsigned char *rgba)
{
	if(nullptr==sdlRenderer)
	{
		return;
	}
	if(nullptr==tex || texWid!=wid || texHei!=hei)
	{
		if(nullptr!=tex)
		{
			SDL_DestroyTexture(tex);
			tex=nullptr;
		}
		tex=SDL_CreateTexture(sdlRenderer,SDL_PIXELFORMAT_RGBA32,SDL_TEXTUREACCESS_STREAMING,wid,hei);
		if(nullptr==tex)
		{
			fprintf(stderr,"SDL_CreateTexture failed: %s\n",SDL_GetError());
			return;
		}
		texWid=wid;
		texHei=hei;
	}
	SDL_UpdateTexture(tex,nullptr,rgba,wid*4);
}

/* static */ SDL_Texture *FsSimpleWindowConnection::WindowConnection::MakeStaticTexture(SDL_Renderer *renderer,int wid,int hei,const unsigned char *rgba)
{
	auto tex=SDL_CreateTexture(renderer,SDL_PIXELFORMAT_RGBA32,SDL_TEXTUREACCESS_STATIC,wid,hei);
	if(nullptr!=tex)
	{
		SDL_SetTextureBlendMode(tex,SDL_BLENDMODE_BLEND);
		SDL_UpdateTexture(tex,nullptr,rgba,wid*4);
	}
	return tex;
}

////////////////////////////////////////////////////////////////

Outside_World::Sound *FsSimpleWindowConnection::CreateSound(void) const
{
	return new SoundConnection;
}

void FsSimpleWindowConnection::DeleteSound(Sound *PTR) const
{
	auto ptr=dynamic_cast<SoundConnection *>(PTR);
	if(nullptr!=ptr)
	{
		delete ptr;
	}
}

void FsSimpleWindowConnection::SoundConnection::Start(void)
{
	soundPlayer.Start();
	cddaStartHSG=0;
#ifdef AUDIO_USE_STREAMING
	YsSoundPlayer::StreamingOption FMPCMStreamOpt;
	FMPCMStreamOpt.ringBufferLengthMillisec=TownsSound::FM_PCM_MILLISEC_PER_WAVE*2+TownsSound::WAVE_STREAMING_SAFETY_BUFFER;
	soundPlayer.StartStreaming(FMPCMStream,FMPCMStreamOpt);
#endif
}
void FsSimpleWindowConnection::SoundConnection::Stop(void)
{
	soundPlayer.End();
}

void FsSimpleWindowConnection::SoundConnection::Polling(void)
{
	soundPlayer.KeepPlaying();
}

void FsSimpleWindowConnection::SoundConnection::CDDAPlay(const DiscImage &discImg,DiscImage::MinSecFrm from,DiscImage::MinSecFrm to,bool repeat,unsigned int,unsigned int)
{
	auto wave=discImg.GetWave(from,to);
	cddaChannel.CreateFromSigned16bitStereo(44100,wave);
	if(true==repeat)
	{
		soundPlayer.PlayBackground(cddaChannel);
	}
	else
	{
		soundPlayer.PlayOneShot(cddaChannel);
	}
	cddaStartHSG=from.ToHSG();
}
void FsSimpleWindowConnection::SoundConnection::CDDASetVolume(float leftVol,float rightVol)
{
	soundPlayer.SetVolumeLR(cddaChannel,leftVol,rightVol);
}
void FsSimpleWindowConnection::SoundConnection::CDDAStop(void)
{
	soundPlayer.Stop(cddaChannel);
}
void FsSimpleWindowConnection::SoundConnection::CDDAPause(void)
{
	soundPlayer.Pause(cddaChannel);
}
void FsSimpleWindowConnection::SoundConnection::CDDAResume(void)
{
	soundPlayer.Resume(cddaChannel);
}
bool FsSimpleWindowConnection::SoundConnection::CDDAIsPlaying(void)
{
	return (YSTRUE==soundPlayer.IsPlaying(cddaChannel));
}
DiscImage::MinSecFrm FsSimpleWindowConnection::SoundConnection::CDDACurrentPosition(void)
{
	double sec=soundPlayer.GetCurrentPosition(cddaChannel);
	unsigned long long secHSG=(unsigned long long)(sec*75.0);
	unsigned long long posInDisc=secHSG+cddaStartHSG;

	DiscImage::MinSecFrm msf;
	msf.FromHSG(posInDisc);
	return msf;
}

void FsSimpleWindowConnection::SoundConnection::FMPCMPlay(std::vector <unsigned char> &wave)
{
#ifdef AUDIO_USE_STREAMING
	YsSoundPlayer::SoundData nextWave;
	nextWave.CreateFromSigned16bitStereo(YM2612::WAVE_SAMPLING_RATE,wave);
	soundPlayer.AddNextStreamingSegment(FMPCMStream,nextWave);
#else
	FMPCMChannel.CreateFromSigned16bitStereo(YM2612::WAVE_SAMPLING_RATE,wave);
	soundPlayer.PlayOneShot(FMPCMChannel);
#endif
}
void FsSimpleWindowConnection::SoundConnection::FMPCMPlayStop(void)
{
}
bool FsSimpleWindowConnection::SoundConnection::FMPCMChannelPlaying(void)
{
#ifdef AUDIO_USE_STREAMING
	unsigned int numSamples=(TownsSound::FM_PCM_MILLISEC_PER_WAVE*YM2612::WAVE_SAMPLING_RATE+999)/1000;
	return YSTRUE!=soundPlayer.StreamPlayerReadyToAcceptNextNumSample(FMPCMStream,numSamples);
#else
	return YSTRUE==soundPlayer.IsPlaying(FMPCMChannel);
#endif
}

void FsSimpleWindowConnection::SoundConnection::BeepPlay(int samplingRate, std::vector<unsigned char> &wave) {
	BeepChannel.CreateFromSigned16bitStereo(samplingRate, wave);
	soundPlayer.PlayOneShot(BeepChannel);
}

void FsSimpleWindowConnection::SoundConnection::BeepPlayStop() {
	soundPlayer.Stop(BeepChannel);
}

bool FsSimpleWindowConnection::SoundConnection::BeepChannelPlaying() const {
	return YSTRUE == soundPlayer.IsPlaying(BeepChannel);
}
