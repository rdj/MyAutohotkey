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
EnvGet AppData, APPDATA
;ComSpec := A_ComSpec
EnvGet ProgramData, ProgramData
EnvGet ProgramFiles32, ProgramFiles(x86)
EnvGet UserProfile, UserProfile

FFXIV          := "ahk_exe ffxiv_dx11.exe"
FFXIV_Launcher := "ahk_exe ffxivlauncher.exe"
Fortnite       := "ahk_exe FortniteClient-Win64-Shipping.exe"
Overwatch      := "ahk_exe Overwatch.exe"
Pubg           := "ahk_exe TslGame.exe"
Rainbow6       := "ahk_exe RainbowSix.exe"
Witcher3       := "ahk_exe witcher3.exe"

ffKeyboardMode := new FFKeyboardMode()
progs := new RdjProgs()

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

class RdjProgs {
    static BLIZZARD    := "blizzard"
    static CHROME      := "chrome"
    static DISCORD     := "discord"
    static DROPBOX     := "dropbox"
    static EMACS       := "emacs"
    static GIT_SHELL   := "git_shell"
    static ONEPASSWORD := "1password"
    static STEAM       := "steam"
    static TWITCH      := "twitch"
    ALL := {}

    ;; AHK doesn't let you split long lines so it seems much saner to
    ;; set up the specs in the ctor
    __New() {
        this.ALL[this.BLIZZARD] := { title: "Blizzard Battle.net", exe: "Battle.net.exe", runTarget: "%ProgramFiles32%\Battle.net\Battle.net Launcher.exe", x: -1080, y: 743, w: 1080, h: 637 }
        this.ALL[this.BLIZZARD . "_friends"] := { title: "Friends", exe: "Battle.net.exe", x: -320, y: 743, w: 320, h: 637 }
        this.ALL[this.CHROME] := { exe: "chrome.exe", path: "%ProgramFiles32%\Google\Chrome\Application\", x: -1088, y: 0, w: 1095, h: 751 } ; Chrome has like a phantom window that it insets the client window in
        this.ALL[this.DROPBOX] := { title: "Dropbox", exe: "Explorer.EXE", runTarget: "%UserProfile%\Dropbox" }
        this.ALL[this.DISCORD] := { exe: "Discord.exe", runTarget: "C:\Users\ryan\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Hammer & Chisel, Inc\Discord.lnk", x: -1080, y: 1380, w: 1080, h: 500 }
        this.ALL[this.EMACS] := { exe: "emacs.exe", runTarget: "%ProgramData%\chocolatey\bin\runemacs.exe", flags: "hide" }
        this.ALL[this.GIT_SHELL] := { exe: "bash.exe", runTarget: "C:\Users\ryan\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\GitHub, Inc\Git Shell.lnk" }
        this.ALL[this.ONEPASSWORD] := { exe: "1Password.exe", path: "%ProgramFiles32%\1Password 4\" }
        this.ALL[this.STEAM] := { title: "Friends", exe: "Steam.exe", path: "%ProgramFiles32%\Steam\", x: -1080, y: 743, w: 320, h: 637 }
        this.ALL[this.TWITCH] := { exe: "TwitchUI.exe", runTarget: "%AppData%\Twitch\Bin\Twitch.exe", x: -1080, y: 743, w: 1080, h: 637 }
    }

    AdminCmd() {
        local hwnd
        if ( hwnd := WinExist( "Administrator ahk_exe cmd.exe" ) ) {
            WinActivate ahk_id %hwnd%
        }
        else {
            Run *RunAs %A_ComSpec%
        }
    }

    Cmd() {
        local hwnd
        if ( hwnd := WinExist( "ahk_exe cmd.exe", , "Administrator" ) ) {
            WinActivate ahk_id %hwnd%
        }
        else {
            Run %A_ComSpec%, %UserProfile%
        }
    }

    IsActive( name ) {
        return WinActive( this.WinTarget( this.ALL[name] ) )
    }

    RepositionAll() {
        local foo
        for name, spec in this.ALL {
            this.Reposition( spec )
        }
    }

    Reposition( spec ) {
        local foo
        if ( "" == spec.x ) {
            return
        }
        WinMove % this.WinTarget( spec ), , spec.x, spec.y, spec.w, spec.h
    }

    RunOrActivate( name ) {
        local spec := this.ALL[name]
        if ( local hwnd := WinExist( this.WinTarget( spec ) ) ) {
            WinActivate ahk_id %hwnd%
        }
        else {
            local flags := spec.flags
            Run % this.RunTarget( spec ), %UserProfile%, %flags%
        }
    }

    RunTarget( spec ) {
        local runTarget := spec["runTarget"]
        if ( "" == runTarget ) {
            runTarget := spec["path"] . spec["exe"]
        }
        Transform runTarget, DeRef, %runTarget%
        return runTarget
    }

    WinTarget( spec ) {
        local target := ""
        if ( "" != spec["title"] ) {
            target := spec["title"] . " "
        }
        target := target . "ahk_exe " . spec["exe"]
        return target
    }
}

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
  vkFF::LCtrl

  #F8:: Send {Media_Play_Pause}
  #F10:: Send {Volume_Mute}
  #F11:: Send {Volume_Down}
  #F12:: Send {Volume_Up}

  #^1:: progs.RunOrActivate( progs.ONEPASSWORD )
  #^c:: progs.Cmd()
  #+c:: progs.AdminCmd()
  #^d:: progs.RunOrActivate( progs.DROPBOX )
  #^e:: progs.RunOrActivate( progs.EMACS )
  #^r:: progs.RepositionAll()
  #^s:: progs.RunOrActivate( progs.DISCORD )
  #^t:: progs.RunOrActivate( progs.STEAM )
  #^u:: progs.RunOrActivate( progs.CHROME )
  #^w:: progs.RunOrActivate( progs.TWITCH )
  #^x:: progs.RunOrActivate( progs.GIT_SHELL )
  #^z:: progs.RunOrActivate( progs.BLIZZARD )

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

#If progs.IsActive( progs.CHROME )
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
  vkFF::
  *vkFF::
    SetKeyDelay -1
    Send {Blind}{Ctrl DownTemp}{Shift DownTemp}{Alt DownTemp}
    Return
  *vkFF up::
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
