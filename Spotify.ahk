; Adapted from https://gist.githubusercontent.com/jcsteh/7ccbc6f7b1b7eb85c1c14ac5e0d65195/raw/71e98d719c6fa9e37094009d311b1f38f0c5d245/SpotifyGlobalKeys.ahk
; Author: James Teh <jamie@jantrid.net>
; Copyright 2017-2018 James Teh
; License: GNU General Public License version 2.0

; Get the HWND of the Spotify main window.
getSpotifyHwnd() {
    WinGet, spotifyHwnd, ID, ahk_exe Spotify.exe
	; We need the app's third top level window, so get next twice.
	spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
	spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
	Return spotifyHwnd
}

; Send a key to Spotify.
spotifyKey(key) {
	spotifyHwnd := getSpotifyHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
	ControlSend, , %key%, ahk_id %spotifyHwnd%
	Return
}
