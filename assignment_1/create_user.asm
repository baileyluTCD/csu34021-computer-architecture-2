        SECTION .data

regValue:
        dd 0

invalidArgsMsg:
        db "nok: no identifier provided", 10, 0
        invalidArgsMsgLen equ $ - invalidArgsMsg - 1

        stdin equ 0
        stdout equ 1

        sys_write equ 4
        sys_read equ 3

        valid_args_number equ 2        ; binary name counts as first arg

        %macro sys_call 0
        int 0x80
        %endmacro

        %macro exit 1
        mov eax, 1                     ; invoke SYS_EXIT (kernel opcode 1)
        mov ebx, %1                    ; code to exit with
        sys_call
        %endmacro

        SECTION .text

        global _start

        mov ecx, ecx                   ; Memory address to write from
        mov edx, edx                   ; Number of bytes to write

; Print a string to stdout

; Args:
; - ecx: Memory address of string to write out
; - edx: Length of sequence (bytes) in memory to write
sprint:
        push eax
        push ebx

        mov eax, sys_write             ; invoke SYS_WRITE (kernel opcode 4)
        mov ebx, stdout                ; File descriptor to write to
        sys_call

        pop ebx
        pop eax
        ret

; Throw an error with a string message

; Args:
; - ecx: Memory address of string to write out
; - edx: Length of sequence (bytes) in memory to write
throw:
        call sprint

        exit 1

_start:
        pop ecx                        ; first value on the stack is the number of arguments

        cmp ecx, valid_args_number
        jz has_valid_number_of_args    ; if (arg_count != valid_args_number)

        mov ecx, invalidArgsMsg
        mov edx, invalidArgsMsgLen
        call throw                     ; throw(invalidArgsMsg, invalidArgsMsgLen);

has_valid_number_of_args:

        add ecx, '0'                   ; convert number of args to ascii numeral
        mov dword [regValue], ecx      ; put the value of the number of args into the memory at the label regValue

        mov ecx, regValue
        mov edx, 4
        call sprint                    ; sprint(regValue, 4)

        exit 0
