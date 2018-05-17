;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Autohotkey.ahk
;;; Targets Autohotkey v1.1.28.02+
;;; Ryan D Johnson
;;;
;;; #Win ^Ctrl !Alt +Shift
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; CapsLock, Control, vkFF
;;;
;;; Windows registry changes keycodes thus:
;;;
;;; CapsLock = LCtrl
;;; LCtrl = vkFF (usually used for laptop Fn keys)
;;; RCtrl = RCtrl
;;;
;;; This lets me distinguish between CapsLock, LCtrl, and RCtrl
;;; physical keys. The universal section maps vkFF to LCtrl, then in
;;; any section that I care about them being different I undo that
;;; mapping.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; BEGIN AUTO-EXECUTION
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KeyLoggerMode := 0
#If !KeyLoggerMode
#KeyHistory 0
#If KeyLoggerMode
#KeyHistory 100
#InstallKeybdHook
#If

#MenuMaskKey vkFFsc001 ; Default is Ctrl, which Emacs doesn't like

#NoEnv ; Don't create AHK vars for all env vars
;ComSpec := A_ComSpec
EnvGet ProgramData, ProgramData
EnvGet ProgramFiles32, ProgramFiles(x86)
EnvGet UserProfile, UserProfile

Chrome := "ahk_exe chrome.exe"
Emacs := "ahk_exe emacs.exe"
FFXIV := "ahk_exe ffxiv_dx11.exe"
FFXIV_Launcher := "ahk_exe ffxivlauncher.exe"
Fortnite := "ahk_exe FortniteClient-Win64-Shipping.exe"
Overwatch := "ahk_exe Overwatch.exe"
Pubg := "ahk_exe TslGame.exe"
Rainbow6 := "ahk_exe RainbowSix.exe"
Witcher3 := "ahk_exe witcher3.exe"

ffKeyboardMode := new FFKeyboardMode()

#Include FFPassword.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; END AUTO-EXECUTION
;;;
;;; No code -- including var init -- runs below this line.
;;;
;;; The rest of the file can only use #Directives and hotkey defs.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Return

RdjModeWindow( title := "" ) {
  if ( title != "" ) {
    Progress B ZH0 Y0, %title%
  }
  else {
    Progress off
  }
}

RdjIndexOf( ByRef a, needle ) {
    for i, val in a {
        if ( val == needle ) {
            return i
        }
    }
}

;; When AHK intercepts a Win+? hotkey, it sends the value from
;; #MenuMaskKey (default Ctrl) to prevent the start menu from opening.
;; We can do the same thing in just the LWin/RWin handlers to prevent
;; the start menu from coming up when a particular program is active.
;; Would be better to share the MenuMaskKey instead of duplicating it,
;; but there doesn't seem to be a way to access to the value, and the
;; #MenuMaskKey directive can't reference variables or functions.
RdjDisableStartMenu() {
    Send {Blind}{vkFFsc001}
}

;; Use WinKill A instead, I think
; RdjKillActiveProgram() {
;     local proc
;     WinGet proc, ProcessName, A
;     Run taskkill /f /im "%proc%",,hide
; }

class FFKeyboardMode {
    static MODE_DEFAULT := ""
    static MODE_NUMPAD := "NUMPAD"
    static MODE_FISHING := "FISHING"
    static ALL_MODES = [ FFKeyboardMode.MODE_DEFAULT, FFKeyboardMode.MODE_NUMPAD, FFKeyboardMode.MODE_FISHING ]

    _currentMode := FFKeyboardMode.MODE_DEFAULT
    CurrentMode[] {
        get {
            return this._currentMode
        }
    }

    IsDefault[] {
        get {
            return this._currentMode == FFKeyboardMode.MODE_DEFAULT
        }
    }

    IsFishing[] {
        get {
            return this._currentMode == FFKeyboardMode.MODE_FISHING
        }
    }

    IsNumpad[] {
        get {
            return this._currentMode == FFKeyboardMode.MODE_NUMPAD
        }
    }

    Cycle() {
        local currentModeIndex := RdjIndexOf( FFKeyboardMode.ALL_MODES, this._currentMode )
        local nextIndex = Mod( currentModeIndex, FFKeyboardMode.ALL_MODES.Length() ) + 1
        this._currentMode := FFKeyboardMode.ALL_MODES[nextIndex]
        if ( this.IsDefault ) {
            RdjModeWindow()
        }
        else {
            RdjModeWindow( this.CurrentMode . " MODE" )
        }
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Universal hotkeys
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#If
  ;%LeftControlVirtualKey%::LCtrl
  vkFF::LCtrl

  #F8:: Send {Media_Play_Pause}
  #F10:: Send {Volume_Mute}
  #F11:: Send {Volume_Down}
  #F12:: Send {Volume_Up}

  #^1:: Run %ProgramFiles32%\1Password 4\1Password.exe
  #^c:: Run %ComSpec%,%UserProfile%
  #^d:: Run %UserProfile%\Dropbox
  #^e:: Run %ProgramData%\chocolatey\bin\runemacs.exe,,hide
  #^p:: Run putty
  #^u:: Run %ProgramFiles32%\Google\Chrome\Application\chrome.exe
  #+c:: Run *RunAs %A_ComSpec%
  #+e:: Edit
  #+r:: Reload
#If

#If KeyLoggerMode
  #Escape:: KeyHistory
#If

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Program-specific hotkeys
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#If WinActive( Chrome )
  ;; Disable back/forward mouse buttons in chrome
  XButton1:: Return
  XButton2:: Return
  #If

;; Common Games
#If WinActive( Pubg )
 || WinActive( Overwatch )
 || WinActive( Fortnite )
 || WinActive( Rainbow6 )

  ~LWin:: RdjDisableStartMenu()
  ~RWin:: RdjDisableStartMenu()

  *Down:: Send {Media_Play_Pause}
  *Up:: Send {Media_Next}
  
  #^k:: WinKill A
#If

#If WinActive( Witcher3 )
  vk07:: ; Xbox guide button
    Send {F5 Down}
    Sleep 10
    Send {F5 Up}
    Return
#If

#If WinActive( FFXIV_Launcher )
  `::
    SetKeyDelay 0
    Send % FFPassword()
    Send {Tab}
    Return
#If

#If WinActive( FFXIV )
  ~LWin:: RdjDisableStartMenu()
  ~RWin:: RdjDisableStartMenu()

  ;; Physical LCtrl becomes Ctrl+Shift+Alt. CapsLock is still LCtrl.
  VKFF::
  *VKFF::
    SetKeyDelay -1
    Send {Blind}{Ctrl DownTemp}{Shift DownTemp}{Alt DownTemp}
    Return
  *VKFF up::
    SetKeyDelay -1
    Send {Blind}{Ctrl Up}{Shift Up}{Alt Up}
    Return
  
  #f1:: Send {numpadAdd}
  #q:: Send {numpad7}
  #w:: Send {numpad8}
  #e:: Send {numpad9}
  
  #a:: Send {numpad4}
  #s:: Send {numpad2}
  #d:: Send {numpad6}
  #f:: Send {numpad0}
  
  #z:: Send {numpad1}
  #x:: Send {numpadDot}
  #c:: Send {numpad3}
  #v:: Send {numpadMult}
  AppsKey Up:: Send {NumpadMult}
  
  #^q:: Send ^{numpad7}
  #^w:: Send ^{numpad8}
  #^e:: Send ^{numpad9}
  
  #^a:: Send ^{numpad4}
  #^s:: Send ^{numpad2}
  #^d:: Send ^{numpad6}
  #^f:: Send {numpad0}
  
  #^z:: Send ^{numpad1}
  #^x:: Send {numpadDot}
  #^c:: Send ^{numpad3}
  #^v:: Send {numpadMult}
    
  #Down:: Send {Media_Play_Pause}
  #Up:: Send {Media_Next}
  #Right:: Send !{F2} ; Mutes in-game audio

  #Space:: ffKeyboardMode.Cycle()
#If

#If WinActive( FFXIV ) && ffKeyboardMode.IsFishing
  Space:: Send 1
#If

#If WinActive( FFXIV ) && ffKeyboardMode.IsNumpad
  q:: Send {numpad7}
  w:: Send {numpad8}
  e:: Send {numpad9}
  
  a:: Send {numpad4}
  s:: Send {numpad2}
  d:: Send {numpad6}
  f:: Send {numpad0}
  
  z:: Send {numpad1}
  x:: Send {numpadDot}
  c:: Send {numpad3}
  v:: Send {numpadMult}
#If
