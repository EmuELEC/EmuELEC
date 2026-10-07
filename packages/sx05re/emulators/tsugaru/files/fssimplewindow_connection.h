/* LICENSE>>
Copyright 2020 Soji Yamakawa (CaptainYS, http://www.ysflight.com)

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<< LICENSE */
#ifndef FSSIMPLEWINDOW_CONNECTION_IS_INCLUDED
#define FSSIMPLEWINDOW_CONNECTION_IS_INCLUDED
/* { */



/*
The original plan was entirely transition to the streaming mode.  However, it turned out DirectSound gives an shameful 60ms latency (practically 80ms), and ALSA apalling 80ms latency.
macOS's AVAudioEngine easily gave a 40ms latency.

DirectSound does better job if I poll play-back state every 1ms and start new 20ms segment, which yields maximum 40ms latency.  The draw back is when you move window or click on 
the window frame, you may hear zapping noise, but I believe latency is more important for games.

ALSA has no choice.  Behind the scenes ALSA code does streaming.

So, my best decision is to use streaming mode in macOS, which should work perfectly.  I have no choice with ALSA.  But, for Windows, I keep it polling-based playback.
*/

#define AUDIO_USE_STREAMING



#include "outside_world.h"
#include "yssimplesound.h"
#include "ysgamepad.h"
#ifndef FSSIMPLEWINDOW_DONT_INCLUDE_OPENGL_HEADERS
#define FSSIMPLEWINDOW_DONT_INCLUDE_OPENGL_HEADERS
#endif
#include "fssimplewindow.h" // FSKEY_* key-code space and FsKeyCodeToString/FsStringToKeyCode (linked from fssimplenowindow; no X11/GL)
#include <SDL2/SDL.h>
#include <vector>
#include <thread>
#include <mutex>

class FsSimpleWindowConnection : public Outside_World
{
public:
	class MouseEvent
	{
	public:
		int evt=0,lb=0,mb=0,rb=0,mx=0,my=0;
		inline void Read(void)
		{
			// SDL2 port: mouse events are constructed from SDL events in
			// WindowConnection::Interval().  Nothing to read here.
			evt=FSMOUSEEVENT_NONE;
		}
	};
	class DeviceAndEvent
	{
	public:
		std::vector <unsigned int> keyCode,charCode;
		std::vector <MouseEvent> mouseEvents;
		unsigned char keyState[FSKEY_NUM_KEYCODE];
		MouseEvent lastKnownMouse;
		int mouseMoveXY[2]={0,0};

		std::vector <struct YsGamePadReading> gamePads;

		int winWid=640,winHei=480;

		DeviceAndEvent()
		{
			for(auto &s : keyState)
			{
				s=0;
			}
		}

		bool EventEmpty(void) const
		{
			return keyCode.empty() && charCode.empty() && mouseEvents.empty();
		}
		void CleanUpEvents(void)
		{
			keyCode.clear();
			charCode.clear();
			mouseEvents.clear();
			mouseMoveXY[0]=0;
			mouseMoveXY[1]=0;
		}
	};

	class HostShortCut
	{
	public:
		bool inUse=false;
		bool ctrl=false,shift=false;
		std::string cmdStr;
	};

	DeviceAndEvent windowEvent;

	#define DEFAULT_PAUSE_KEY_CODE FSKEY_SCROLLLOCK

	HostShortCut hostShortCut[FSKEY_NUM_KEYCODE];
	unsigned int PAUSE_KEY_CODE=DEFAULT_PAUSE_KEY_CODE;

	unsigned int *FSKEYtoTownsKEY=nullptr;
	unsigned int *FSKEYState=nullptr;
	FsSimpleWindowConnection();
	~FsSimpleWindowConnection();

	std::string GetProgramResourceDirectory(void) const override;

	std::vector <struct YsGamePadReading> prevGamePads;

	// For mouse emulation by pad digital axes.
	int mouseDX=0,mouseDY=0;

	virtual std::vector <std::string> MakeDefaultKeyMappingText(void) const override;
	virtual std::vector <std::string> MakeKeyMappingText(void) const override;
	virtual void LoadKeyMappingFromText(const std::vector <std::string> &text) override;

	virtual void Start(void) override;
	virtual void Stop(void) override;
	virtual void DevicePolling(class FMTownsCommon &towns) override;
	virtual bool ImageNeedsFlip(void) override;

	virtual void SetKeyboardLayout(unsigned int layout) override;
	static void MakeKeyMapFromLayout(unsigned int FSKeyToTownsKEY[FSKEY_NUM_KEYCODE],unsigned int layout);

	virtual void RegisterHostShortCut(std::string hostKeyLabel,bool ctrl,bool shift,std::string cmdStr) override;
	virtual void RegisterPauseResume(std::string hostKeyLabel) override;

	virtual void ToggleMouseCursor(void) override;

	void PauseKeyPressed(void);



	class WindowConnection : public WindowInterface
	{
	public:
		class SharedVariables
		{
		public:
			// Locked by deviceStateLock >>
			DeviceAndEvent readyToSend;

			// Locked by renderingLock >>
			StatusBarInfo statusBarInfo;
		};
		class WindowThreadVariables
		{
		public:
			DeviceAndEvent primary;
			StatusBarInfo statusBarInfo,prevStatusBarInfo;
			bool gamePadInitialized=false;
			unsigned int sinceLastResize=0;
		};
		class VMThreadVariables
		{
		public:
		};
		SharedVariables sharedEx;
		WindowThreadVariables winThrEx;
		VMThreadVariables VMThrEx;
		int diffMouseXY[2]={0,0}; // Needs to be polled separately.  See comments in Interval(void).
		int diffMouseNoMotionCount=0;

		// Potential problems in implementing differential mouse integration.
		// (1) If the host system is keeping track of sub-pixel movement.  If mouse is moved back to window center,
		//     it may never detect more than 1 pixel movement.
		// (2) If the guest os is not consuming mouse movement before the next polling in the host,
		//     the mouse motion sent to the host is zeroed in the second polling, and the guest rarely sees
		//     the mouse motion.
		// Fix:  Have separate mouse-coordinate cache.
		//       Let mouse cursor move in some area instead of fixing the mouse cursor at the center of the window.
		//       If the guest has not consumed previous mouse movement, add the motion instead of overwrite.


		// SDL2 window/renderer/textures.  Created in Start(), textures are
		// (re-)allocated on demand when the source image size changes.
		SDL_Window *sdlWindow=nullptr;
		SDL_Renderer *sdlRenderer=nullptr;
		SDL_Texture *mainTex=nullptr,*statusTex=nullptr,*pauseIconTex=nullptr,*menuIconTex=nullptr;
		int mainTexWid=0,mainTexHei=0;
		int mouseLb=0,mouseMb=0,mouseRb=0,mouseX=0,mouseY=0; // last known SDL mouse state (window thread)

		void UpdateTextureSDL(SDL_Texture *&tex,int &texWid,int &texHei,int wid,int hei,const unsigned char *rgba);
		static SDL_Texture *MakeStaticTexture(SDL_Renderer *renderer,int wid,int hei,const unsigned char *rgba);

		void UpdateStatusBitmap(void);
		void UpdateStatusBitmapRocketRangerSpecial(unsigned int position);

		std::vector <unsigned char> PAUSEicon,MENUicon;

		void Start(void) override;
		void Stop(void) override;
		void Interval(void) override;
		void Render(bool swapBuffers) override;
		void UpdateImage(TownsRender::ImageCopy &img) override;
		void Communicate(Outside_World *) override;

		void PollGamePads(void);

		// Called when window-close button is clicked.
		static bool CloseWindowCallBack(void *thisPtr)
		{
			auto self=(FsSimpleWindowConnection::WindowConnection *)thisPtr;
			self->deviceStateLock.lock();
			self->closeWindow=true;
			self->deviceStateLock.unlock();
			return false; // Do not close window right away.
		}
	};
	WindowInterface *CreateWindowInterface(void) const override;
	void DeleteWindowInterface(WindowInterface *) const override;



	class SoundConnection : public Sound
	{
	public:
		YsSoundPlayer soundPlayer;
		YsSoundPlayer::SoundData cddaChannel;
		unsigned long long cddaStartHSG;

	#ifdef AUDIO_USE_STREAMING
		YsSoundPlayer::Stream FMPCMStream;
	#else
		YsSoundPlayer::SoundData FMPCMChannel;
	#endif

		YsSoundPlayer::SoundData BeepChannel;

	public:
		virtual void Start(void) override;
		virtual void Stop(void) override;

		virtual void Polling(void) override;

		virtual void CDDAPlay(const DiscImage &discImg,DiscImage::MinSecFrm from,DiscImage::MinSecFrm to,bool repeat,unsigned int,unsigned int) override;
		virtual void CDDASetVolume(float leftVol,float rightVol) override;
		virtual void CDDAStop(void) override;
		virtual void CDDAPause(void) override;
		virtual void CDDAResume(void) override;
		virtual bool CDDAIsPlaying(void) override;
		virtual DiscImage::MinSecFrm CDDACurrentPosition(void) override;

		virtual void FMPCMPlay(std::vector <unsigned char > &wave) override;
		virtual void FMPCMPlayStop(void) override;
		virtual bool FMPCMChannelPlaying(void) override;

		virtual void BeepPlay(int samplingRate, std::vector<unsigned char> &wave) override;
		virtual void BeepPlayStop() override;
		virtual bool BeepChannelPlaying() const override;
	};
	virtual Sound *CreateSound(void) const override;
	virtual void DeleteSound(Sound *) const override;
};

/* } */
#endif
