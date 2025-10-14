section .data
msg db "Hello, NASM world!", 10
len equ $ - msg
section .text
global _start
_start:
mov eax, 4 ; sys_write
mov ebx, 1 ; file descriptor 1 = stdout
mov ecx, msg ; address of string
mov edx, len ; length of string
int 0x80 ; kernel interrupt
mov eax, 1 ; sys_exit
xor ebx, ebx
int 0x80
