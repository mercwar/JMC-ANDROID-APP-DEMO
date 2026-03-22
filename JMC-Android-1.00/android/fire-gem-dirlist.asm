;===========================================================
; AVIS FILE IDENTITY BLOCK
;===========================================================
; CY_FILENAME: fire-gem-dirlist.asm
; CY_NAME: FIRE_GEM_DIRLIST_ASM
; CY_TYPE: ASM_MODULE
; CY_ROLE: DIRECTORY_BROWSER
; CY_SUBSYS: FIRE_GEM
; CY_VERSION: 01.00
; CY_GUID: {D1R3-CT0R-YL15-TER0-0000AAAABBBB}
; CY_BUILD: MANUAL
; CY_NOTES: LISTS /INI /JSON /ASM AND ALLOWS FILE SELECTION.
;===========================================================

SECTION .data
DirList_Buffer      times 4096 db 0
DirList_Entry       times 512 db 0
DirList_Prompt      db "Select directory: [ini/json/asm/root]: ",0
DirList_FilePrompt  db "Select file: ",0
DirList_Result      times 512 db 0

IniDir              db "ini\*",0
JsonDir             db "json\*",0
AsmDir              db "asm\*",0
RootDir             db "*",0

SECTION .text
extern  FindFirstFileA
extern  FindNextFileA
extern  FindClose
extern  FG_PrintString
extern  FG_ReadLine
extern  FG_PRINTLN
extern  FG_PRINT

;-----------------------------------------------------------
; FG_ListDirectory
; RCX = pointer to directory pattern (e.g. "ini\*")
;-----------------------------------------------------------
FG_ListDirectory:
    push    rbp
    mov     rbp, rsp

    ; Print header
    mov     rcx, DirList_Prompt
    call    FG_PrintString

    ; Read user input
    mov     rcx, DirList_Result
    call    FG_ReadLine

    ; Determine directory
    ; (simple string compare logic)
    ; if "ini" → IniDir
    ; if "json" → JsonDir
    ; if "asm" → AsmDir
    ; if "root" → RootDir

    ; For now, assume RCX already points to pattern
    mov     rcx, rdx
    call    FG_ListPattern

    pop     rbp
    ret

;-----------------------------------------------------------
; FG_ListPattern
; RCX = pointer to pattern ("ini\*", "json\*", etc.)
;-----------------------------------------------------------
FG_ListPattern:
    push    rbp
    mov     rbp, rsp

    ; FindFirstFileA
    mov     rdx, DirList_Entry
    call    FindFirstFileA
    cmp     rax, -1
    je      .done

.loop:
    ; Print file name
    mov     rcx, DirList_Entry
    call    FG_PrintString
    mov     rcx, FG_NewLine
    call    FG_PrintString

    ; Next file
    mov     rcx, rax
    mov     rdx, DirList_Entry
    call    FindNextFileA
    test    rax, rax
    jnz     .loop

.done:
    call    FindClose
    pop     rbp
    ret
