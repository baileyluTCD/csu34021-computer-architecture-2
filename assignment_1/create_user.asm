        SECTION .data

; Messages
invalidArgsMsg:
        db "nok: no identifier provided", 10, 0
        invalidArgsMsgLen equ $ - invalidArgsMsg - 1

userDirAlreadyExistsMsg:
        db "nok: user already exists", 10, 0
        userDirAlreadyExistsMsgLen equ $ - userDirAlreadyExistsMsg - 1

; File descriptors
        stdin equ 0
        stdout equ 1

; Syscall op codes (32 bit)
; See https://syscalls.mebeim.net/?table=x86/32/ia32/latest
        sys_exit equ 1
        sys_write equ 4
        sys_read equ 3
        sys_stat equ 18

; Program constants
        valid_args_number equ 2        ; binary name counts as first arg

; Function style macros
        %macro sys_call 1
        push eax
        mov eax, %1
        int 0x80
        pop eax
        %endmacro

        %macro exit 1
        mov ebx, %1                    ; code to exit with
        sys_call sys_exit              ; invoke SYS_EXIT (kernel opcode 1)
        %endmacro

        SECTION .bss

        statbuf resb 128               ; buffer for the `stat` syscall to place it's output data in

        SECTION .text

        global _start

; Print a string to stdout

; Args:
; - ecx: Memory address of string to write out
; - edx: Length of sequence (bytes) in memory to write
sprint:
        push ebx

        mov ebx, stdout                ; File descriptor to write to
        sys_call sys_write             ; invoke SYS_WRITE (kernel opcode 4)

        pop ebx
        ret

; Throw an error with a string message

; Args:
; - ecx: Memory address of string to write out
; - edx: Length of sequence (bytes) in memory to write
throw:
        call sprint

        exit 1

; Check if a given file exists

; Args:
; - ebx: Memory address of path file name to check

; Return:
; - eax: If the file exists (0 for success, -errno for failiure)
directory_exists:
        push ecx

        mov ecx, statbuf
        sys_call sys_stat

        pop ecx
        ret

_start:
        pop ecx                        ; first value on the stack is the number of arguments

        cmp ecx, valid_args_number
        jz has_valid_number_of_args    ; if (arg_count != valid_args_number)

        mov ecx, invalidArgsMsg
        mov edx, invalidArgsMsgLen
        call throw                     ; throw(invalidArgsMsg, invalidArgsMsgLen);

has_valid_number_of_args:
        pop ebx                        ; pop and ignore first arg (binary name)
        pop ebx                        ; second arg is username
        call directory_exists

        cmp ecx, 0
        jz user_directory_does_not_exist ; if (file_exists(username))

        mov ecx, userDirAlreadyExistsMsg
        mov edx, userDirAlreadyExistsMsgLen
        call throw                     ; throw(userDirAlreadyExistsMsg, userFileAlreadyExistsMsgLen);

user_directory_does_not_exist:

        exit 0
