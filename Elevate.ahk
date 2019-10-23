;; Elevate.ahk
;
; Provides the Elevate() function to automatically reinvoke this
; script with elevated UAC permissions. This is useful because it
; allows our script to interact with other elevated windows.
;
; Take care when using this, since any commands executed with Run will
; also have elevated permissions. See ShellRun.ahk for an alternate
; way to run commands with limited user permissions.
;
; This implementation is based on the example from the AutoHotkey help
; page for Run.

Elevate() {
    local cmdline
    if ( A_IsAdmin ) {
        return
    }

    cmdline := DllCall( "KERNEL32\GetCommandLineW", "WStr" )
    if ( RegExMatch( cmdline, "\b/restart\b" ) ) {
        MsgBox % "Failed to elevate, UAC likely disabled"
        return
    }

    local restartCmd := A_AhkPath . " /restart " . A_ScriptFullPath
    if ( A_IsCompiled ) {
        restartCmd := A_ScriptFullPath . " /restart"
    }

    try {
        Run % "*RunAs " . restartCmd
    }
    finally {
        ExitApp
    }
}

