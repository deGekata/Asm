
; [BITS 64]

; extern printf
; extern _cputs
; extern putchar

; global main

; section .text
; main:


;     ; mov qword[ans_switch + rax * 8], 10
;     ; push msg
;     ; call _puts
;     ; add rsp, 8
    
;     ; mov
;     ; mov rax, password
;     mov rdi, negative
;     push rdi
;     call _cputs
;     add rsp, 8
;     ; mov word [buff_len__], buff_len_const
;     ret
;     .retry:
    

; ; 

;     test rax, rax
;     je .correct
;     jne .incorrect


;     .incorrect:


;     jmp .retry
;     .correct:

;     ; call _puts

    
    
    
;     ret



; ;==========================================================
; ; using last value of rdi from printf as pos to be set \0
; ; prints string
; ;==========================================================



; section .data
; ; buff_len          dw 17    
; password           db'abcd', 0
; negative:						db "Haha ti thought chto you are able to vzlomat my password dumbass", 0x0
; buff_len_const    equ 17
; ans_switch:
;                         dq main.retry
;                         dq main.incorrect
;                         dq main.correct

; section .bss
; buff                    resb buff_len_const
; buff_len__              resw 1




section .text
    global main   ; Tell the linker to globally 'broadcast' this
    extern printf ; Tell the linker to link this externally
 
main:
    ; printf("Wootland %d", 1337);
    push 1337    ; Push the last parameter to stack
    mov rsi, wootland
    push rsi
    mov rdi, wootland

    ; push wootland ; Push the next parameter to stack
    call printf  ; Call printf
    add  rsp, 8   ; Reset the stack (in this case, we put 8 bytes on the stack)
 
    ; return 0
    xor rax, rax
    ret
 
; Our string, null terminated
wootland: db "Wootland %d", 0