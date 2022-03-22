
[BITS 64]

extern printf
extern puts
extern putchar

global main

section .text
main:


    ; mov qword[ans_switch + rax * 8], 10
    ; push msg
    ; call _puts
    ; add rsp, 8
    
    ; mov
    push password
    push 4
    call puts
    add rsp, 8
    mov word [buff_len__], buff_len_const
    ret
    .retry:
    

; 

    test rax, rax
    je .correct
    jne .incorrect


    .incorrect:


    jmp .retry
    .correct:

    ; call _puts

    
    
    
    ret



;==========================================================
; using last value of rdi from printf as pos to be set \0
; prints string
;==========================================================



section .data
; buff_len          dw 17    
password           db'abcd', 0
buff_len_const    equ 17
ans_switch:
                        dq main.retry
                        dq main.incorrect
                        dq main.correct

section .bss
buff                    resb buff_len_const
buff_len__              resw 1



