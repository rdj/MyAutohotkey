;; FFPassword.ahk
;
; Provies the FFPassword() function which loads your final fantasy
; password which is securely stored in Windows Credential Manager.
;
; There are a lot of ways to save your password, here are a few:
;
; ## Using the command line
; cmdkey /generic:ffxiv /user:ffxiv /pass
; (enter your password at the prompt)
;
; ## Using the legacy Win2k UI
; 1. Run "rundll32.exe keymgr.dll, KRShowKeyMgr"
; 2. Choose "Add..."
; 3. Enter "ffxiv" for "Log on to" and "User name"
; 4. Enter your password in the password field
; 5. Choose "A Web site or program credential"
;
; ## Using the Windows 10 Credential Manager UI
; 1. Search for "Credential Manager" from start menu
; 2. Choose "Windows Credentials"
; 3. Choose "Add a generic credential"
; 4. Enter "ffxiv" for "Internet or network address" and "User name"
; 5. Enter your password in the password field
;
; To use this from your main autohotkey script, include this near the top:
;
;   #Include FFPassword.ahk
;
; Then you can use the FFPassword() function to get your password and
; type it into the FFXIV launcher.
;
; In this example, focus the password field in the FFXIV launcher and
; press the ` key (same key as ~), it will enter your password quickly
; and then move to the next field (so you can enter the one time code).
;
;   #If WinActive( "ahk_exe ffxivlauncher.exe" )
;     `::
;       SetKeyDelay 0
;       SendRaw % FFPassword()
;       Send {Tab}
;       Return
;   #If

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
