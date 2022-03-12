;; FFPassword.ahk
;
; Provides the FFPassword() function for loading your FFXIV password
; from Windows Credential Manager. This lets you automate password
; entry using Autohotkey without having your password sitting around
; unencrypted for people to snoop.
;
; I created this because I found it overly burdensome to type a
; reasonably secure password and enter a one-time code every single
; time I wanted to launch the game. I wouldn't necessarily recommend
; doing this if you're not using two-step authentication with the SQEX
; Token smartphone app.
;
; Here are three reasonable ways to store your password in the Windows
; Credential Manager so that it can be used by this function:
;
;   ## Using the command line
;   cmdkey /generic:ffxiv /user:ffxiv /pass
;   (enter your password at the prompt)
;
;   ## Using the legacy Win2k UI
;   1. Run "rundll32.exe keymgr.dll, KRShowKeyMgr"
;   2. Choose "Add..."
;   3. Enter "ffxiv" for "Log on to" and "User name"
;   4. Enter your password in the password field
;   5. Choose "A Web site or program credential"
;
;   ## Using the Windows 10 Credential Manager UI
;   1. Search for "Credential Manager" from start menu
;   2. Choose "Windows Credentials"
;   3. Choose "Add a generic credential"
;   4. Enter "ffxiv" for "Internet or network address" and "User name"
;   5. Enter your password in the password field
;
; To use from your main autohotkey script, include this file the top:
;
;   #Include FFPassword.ahk
;
; Then you can use the FFPassword() function to get your password.
;
; Here's a full example. When the FFXIV Launcher is open, pressing `
; (same key as ~) will quickly enter the password and then tab to the
; next field. The idea is you can just hit `, enter your 6-digit
; one-time code, and hit enter.
;
;   #If WinActive( "ahk_exe ffxivlauncher.exe" )
;     `::
;       SetKeyDelay 0
;       SendRaw % FFPassword()
;       Send {Tab}
;       Return
;   #If
;
; I have only tested this on 64-bit Windows 10, but if I did it
; correctly it should work on any modern Windows.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DllCall is used to invoke the CredRead API, defined in WinCred.h:
;
; BOOL CredReadW(
;   _In_  LPCWSTR     TargetName,
;   _In_  DWORD       Type,
;   _In_  DWORD       Flags,
;   _Out_ PCREDENTIAL *Credential
; );
;
; VOID CredFree(
;   _In_ PVOID Buffer
; );
;
; typedef struct _CREDENTIALW {
;  0       DWORD                 Flags;
;  4       DWORD                 Type;
;  8       LPWSTR                TargetName;
;  8 + 1*p LPWSTR                Comment;
;  8 + 2*p FILETIME              LastWritten; { 8+2p DWORD dwLowDateTime; 12+2p DWORD dwHighDateTime; }
; 16 + 2*p DWORD                 CredentialBlobSize;
;(20 + 2*p DWORD padding on 64-bit)
; 16 + 3*p LPBYTE                CredentialBlob;
; 16 + 4*p DWORD                 Persist;
; 20 + 4*p DWORD                 AttributeCount;
; 24 + 4*p PCREDENTIAL_ATTRIBUTE Attributes;
; 24 + 5*p LPWSTR                TargetAlias;
; 24 + 6*p LPWSTR                UserName;
; } CREDENTIAL, *PCREDENTIAL;
;
; #define CRED_TYPE_GENERIC               1

FFPassword() {
    local static password := ""
    if ( "" != password ) {
        return password
    }

    local pCred := 0
    local ret := DllCall( "ADVAPI32\CredReadW", "WStr", "ffxiv", "UInt", 1, "UInt", 0, "Ptr*", pCred, "Int" )
    if ( 0 != ErrorLevel ) {
        MsgBox % "DllCall error invoking CredReadW: " . ErrorLevel
        return
    }
    if ( 1 != ret ) {
        MsgBox % "Error from CredRead: " . A_LastError
        return
    }

    local credentialBlobSizeOffset := 16 + 2*A_PtrSize
    local pCredentialBlobOffset    := 16 + 3*A_PtrSize

    local credentialBlobSize := NumGet( pCred + credentialBlobSizeOffset, "UInt" )
    local pCredentialBlob    := NumGet( pCred + pCredentialBlobOffset,    "Ptr" )

    password := StrGet( pCredentialBlob, credentialBlobSize / 2, "UTF-16" )

    DllCall( "ADVAPI32\CredFree", "Ptr", pCred )
    if ( 0 != ErrorLevel ) {
        MsgBox % "DllCall error invoking CredFree: " . ErrorLevel
        return
    }

    return password
}

FFCode() {
    clipboard := ""
    run % comspec " /c c:\Users\ryan\projects\totp\totp\bin\Debug\totp.exe | clip",,hide
    ClipWait
    code := Trim(clipboard, "`r`n`t ")
    clipboard := ""
    return code
}    
