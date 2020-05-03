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

;; Run this script elevated so it can control elevated windows
#Include Elevate.ahk
Elevate()

#Include FFPassword.ahk
#Include ShellRun.ahk

#KeyHistory 0
;;#KeyHistory 100
;;#InstallKeybdHook

#MenuMaskKey vkFFsc001 ; Default is Ctrl, which Emacs doesn't like

SetTitleMatchMode RegEx

#NoEnv ; Don't create AHK vars for all env vars
EnvGet AppData, APPDATA
EnvGet AllUsersProfile, AllUsersProfile
;ComSpec := A_ComSpec
EnvGet ProgramData, ProgramData
EnvGet ProgramFiles32, ProgramFiles(x86)
EnvGet SystemRoot, SystemRoot
EnvGet UserProfile, UserProfile

Apex           := "ahk_exe r5apex.exe"
BlackOps4      := "ahk_exe BlackOps4.exe"
FFXIV          := "ahk_exe ffxiv_dx11.exe"
FFXIV_Launcher := "ahk_exe ffxivlauncher.exe"
Fortnite       := "ahk_exe FortniteClient-Win64-Shipping.exe"
Overwatch      := "ahk_exe Overwatch.exe"
Pubg           := "ahk_exe TslGame.exe"
Rainbow6       := "ahk_exe RainbowSix.exe"
Witcher3       := "ahk_exe witcher3.exe"

ffKeyboardMode := new FFKeyboardMode()
progs := new RdjProgs()

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
    ACT               := "act"
    BLIZZARD          := "blizzard"
    BLIZZARD_FRIENDS  := "blizzard_friends"
    CHATTY            := "chatty"
    CHROME            := "chrome"
    CMD               := "cmd"
    CMD_ADMIN         := "cmd_admin"
    DISCORD           := "discord"
    DROPBOX           := "dropbox"
    EMACS             := "emacs"
    FIREFOX           := "firefox"
    GIT_SHELL         := "git_shell"
    ITUNES            := "itunes"
    ONEPASSWORD       := "1password"
    PANDORA           := "pandora"
    STEAM             := "steam"
    TEAMCRAFT         := "teamcraft"
    TEAMCRAFT_OVERLAY := "teamcraft_overlay"
    TERMINAL          := "terminal"
    TERMINAL_ADMIN    := "terminal_admin"
    TWITCH            := "twitch"
    ALL := {}

    ; Chrome's window is inset compared to its window system position
    CHROME_OFFSET_X := -8
    CHROME_OFFSET_W := 15
    CHROME_OFFSET_H := 8

    FIREFOX_OFFSET_W := 10
    FIREFOX_OFFSET_H := 6
    FIREFOX_OFFSET_X := - ( this.FIREFOX_OFFSET_W / 2 )
    FIREFOX_OFFSET_Y := -1

    ;; This is a mess, but AHK's version of line continutation is
    ;; pretty funky and ill-suited to formatting this reasonably
    __New() {
        this.ALL[this.ACT] := { title: "^Advanced Combat Tracker", exe: "Advanced Combat Tracker.exe", path: "%ProgramFiles32%\Advanced Combat Tracker\", admin: true, x: -1080 + this.CHROME_OFFSET_X, y: 743, w: 1080 + this.CHROME_OFFSET_W, h: 637 + this.CHROME_OFFSET_H }
        this.ALL[this.BLIZZARD] := { title: "Blizzard Battle[.]net", exe: "Battle.net.exe", runTarget: "%ProgramFiles32%\Battle.net\Battle.net Launcher.exe", x: -1080, y: 743, w: 1080, h: 637 }
        this.ALL[this.BLIZZARD_FRIENDS] := { title: "Friends", exe: "Battle.net.exe", x: -320, y: 743, w: 320, h: 637 }
        this.ALL[this.CHROME] := { title: "^(?!FFXIV Crafting Optimizer)", exe: "chrome.exe", path: "%ProgramFiles32%\Google\Chrome\Application\", x: ( -1080 + this.CHROME_OFFSET_X ), y: 0, w: ( 1080 + this.CHROME_OFFSET_W ), h: ( 300 + 743 + this.CHROME_OFFSET_H ) } ; Chrome has like a phantom window that it insets the client window in
        this.ALL[this.CHATTY] := { exe: "Chatty.exe", title: "Chatty", path: "%ProgramFiles32%\Chatty\", x: -1080, y: 1380, w: 1080, h: 500 }
        this.ALL[this.CMD] := { title: "^(?!Administrator)", exe:"cmd.exe", path: "%SystemRoot%\system32\" }
        this.ALL[this.CMD_ADMIN] := { title: "Administrator", exe:"cmd.exe", path: "%SystemRoot%\system32\", admin: true }
        this.ALL[this.DROPBOX] := { title: "Dropbox", exe: "Explorer.EXE", runTarget: "%UserProfile%\Dropbox" }
        this.ALL[this.DISCORD] := { exe: "Discord.exe", runTarget: "%AppData%\Microsoft\Windows\Start Menu\Programs\Hammer & Chisel, Inc\Discord.lnk", x: -1080, y: 1380, w: 1080, h: 500 }
        this.ALL[this.EMACS] := { exe: "emacs.exe", runTarget: "%ProgramData%\chocolatey\bin\runemacs.exe", hide: true }
        this.ALL[this.FIREFOX] := { title: "ahk_class MozillaWindowClass", exe: "firefox.exe", path: "%ProgramFiles%\Mozilla Firefox\", x: -1080 + this.FIREFOX_OFFSET_X, y: 0 + this.FIREFOX_OFFSET_Y, w: 1080 + this.FIREFOX_OFFSET_W, h: 100 + 743 + this.FIREFOX_OFFSET_H }
        this.ALL[this.GIT_SHELL] := { exe: "mintty.exe", runTarget: "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\Git\Git Bash.lnk" }
        this.ALL[this.ITUNES] := { exe: "iTunes.exe", path: "%ProgramFiles%\iTunes\", x: -1080, y: 743, w: 1080, h: 637 }
        this.ALL[this.ONEPASSWORD] := { exe: "1Password.exe", path: "%UserProfile%\AppData\Local\1Password\app\7\" }
        this.ALL[this.PANDORA] := { exe: "Pandora.exe", runTarget: "shell:AppsFolder\PandoraMediaInc.29680B314EFC2_n619g4d5j0fnw!App", x: ( -1080 + this.CHROME_OFFSET_X ), y: 0, w: ( 1080 + this.CHROME_OFFSET_W ), h: ( 743 + this.CHROME_OFFSET_H ) }
        this.ALL[this.STEAM] := { title: "Friends", exe: "steamwebhelper.exe", runTarget: "%ProgramFiles32%\Steam\Steam.exe", x: -1080, y: 743, w: 320, h: 637 }
        this.ALL[this.TEAMCRAFT] := { title: "^(?!FFXIV Teamcraft - Alarms overlay)", exe: "FFXIV Teamcraft.exe", path: "%UserProfile%\%AppData\Local\ffxiv-teamcraft\", x: -1080 + this.CHROME_OFFSET_X, y: 743, w: 1080 + this.CHROME_OFFSET_W, h: 637 + this.CHROME_OFFSET_H }
        this.ALL[this.TEAMCRAFT_OVERLAY] := { title: "^FFXIV Teamcraft - Alarms overlay$", exe: "FFXIV Teamcraft.exe", x: 1874 + this.CHROME_OFFSET_X, y: 0, w: 300 + this.CHROME_OFFSET_W, h: 240 + this.CHROME_OFFSET_H }
        this.ALL[this.TERMINAL] := { title: "^(?!Administrator)", exe:"WindowsTerminal.exe", runTarget: "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App" }
        this.ALL[this.TERMINAL_ADMIN] := { title: "^Administrator", exe:"WindowsTerminal.exe", runTarget: "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App", admin: true }
        this.ALL[this.TWITCH] := { exe: "TwitchUI.exe", runTarget: "%AppData%\Twitch\Bin\Twitch.exe", x: -1080, y: 743, w: 1080, h: 637 }
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
        if ( "" == spec ) {
            return
        }
        if ( local hwnd := WinExist( this.WinTarget( spec ) ) ) {
            WinActivate ahk_id %hwnd%
        }
        else {
            ; nShowCmd values are documented here:
            ; https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutea
            local nShowCmd := 1 ; SW_SHOWNORMAL
            if ( spec.hide ) {
                nShowCmd := 0 ; SW_HIDE
            }
            local operation
            if ( spec.admin ) {
                operation := "runas"
            }
            ; Since this script runs elevated, any command executed
            ; with Run would also run elevated. By using ShellRun,
            ; commands run with limited permissions unless we use the
            ; runas operation.
            ShellRun( this.RunTarget( spec ), , UserProfile, operation, nShowCmd )
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

    ; Default behavior when accessing a non-existent property on an
    ; object is just to return blank, which defeats the whole purpose
    ; of using pseudo-constants for the program keys
    __Get( aName ) {
        MsgBox Non-existant property: %aName%
    }
}

class FFKeyboardMode {
    static MODE_DEFAULT := ""
    static MODE_NUMPAD := "NUMPAD"
    static MODE_FISHING := "FISHING"
    static ALL_MODES := [ FFKeyboardMode.MODE_DEFAULT, FFKeyboardMode.MODE_NUMPAD, FFKeyboardMode.MODE_FISHING ]

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
        local nextIndex := Mod( currentModeIndex, FFKeyboardMode.ALL_MODES.Length() ) + 1
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
  #^a:: progs.RunOrActivate( progs.ACT )
  #^c:: progs.RunOrActivate( progs.TERMINAL )
  #+c:: progs.RunOrActivate( progs.TERMINAL_ADMIN )
  #^d:: progs.RunOrActivate( progs.DROPBOX )
  #^e:: progs.RunOrActivate( progs.EMACS )
  #+f:: progs.RunOrActivate( progs.TEAMCRAFT )
  #^h:: progs.RunOrActivate( progs.CHATTY )
  #^i:: progs.RunOrActivate( progs.ITUNES )
  #^p:: progs.RunOrActivate( progs.PANDORA )
  #^q:: progs.RunOrActivate( progs.ACT )
  #^r:: progs.RepositionAll()
  #^s:: progs.RunOrActivate( progs.DISCORD )
  #^t:: progs.RunOrActivate( progs.STEAM )
  #^u:: progs.RunOrActivate( progs.FIREFOX )
  #^w:: progs.RunOrActivate( progs.TWITCH )
  #^x:: progs.RunOrActivate( progs.GIT_SHELL )
  #^z:: progs.RunOrActivate( progs.BLIZZARD )

  #+e:: Edit
  #+r:: Reload
#If

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Program-specific hotkeys
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#If progs.IsActive( progs.CHROME ) || progs.IsActive( progs.FIREFOX )
  ;; Disable back/forward mouse buttons in chrome
  XButton1:: Return
  XButton2:: Return

  ;; Mac-style keybinds for cycling through browser tabs
  !+[:: Send +^{Tab}
  !+]:: Send ^{Tab}
#If

;; Common Games
#If WinActive( Pubg )
 || WinActive( Overwatch )
 || WinActive( Fortnite )
 || WinActive( Rainbow6 )
 || WinActive( BlackOps4 )
 || WinActive( Apex )

  ~LWin:: RdjDisableStartMenu()
  ~RWin:: RdjDisableStartMenu()
  !Tab:: return ; disable alt-tab

  *Down:: Send {Media_Play_Pause}
  *Up:: Send {Media_Next}

  *ScrollLock:: Send ^{F12} ;; Nvidia screen shot
  
  #^k::
    ;; This use to just be
    ;;   WinKill A
    ;; But for some reason that stopped working
    WinGet active_pid, PID, A
    Process Close, %active_pid%
    Return
#If

#If WinActive( BlackOps4 )
  ;; Physical LCtrl becomes CapsLock. CapsLock is still LCtrl.
  vkFF::CapsLock
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
    SendRaw % FFPassword()
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

  *AppsKey::
    SetKeyDelay -1
    Send {Blind}{Ctrl DownTemp}{Shift DownTemp}{Alt DownTemp}
    Return
  *AppsKey up::
    SetKeyDelay -1
    Send {Blind}{Ctrl Up}{Shift Up}{Alt Up}
    Return

  ;; Sometimes I hit Tab to try to switch targets in game while I have
  ;; my AppsKey modifier down, so we don't want that switching programs
  ^!+Tab:: Send {Tab}
  
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

  #1:: SendRaw 
  #2:: SendRaw 
  #3:: SendRaw 
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
