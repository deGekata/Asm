
[BITS 64]

extern fgets
extern puts
extern strlen
extern stdin
extern stdout

global main

section .text
main:


.retry:
        ; mov qword[ans_switch + rax * 8], 10
        ; push msg
        ; call _puts
        ; add rsp, 8
        mov rdi, buff
        mov rsi, buff_len
        mov rdx, [stdin]
        call fgets


        xor rax, rax
		mov rdi, buff
		call strlen


        mov rcx, rax
        dec rcx
        xor rax, rax
        mov rdi	, 0

.hash		crc32 eax, byte [buff + rdi]
			inc rdi
			loop .hash
        mov ebx, dword [my_pass_hash]
        cmp eax, ebx
        je .correct
        jmp .incorrect

        

    ; 
        ; mov rbx, [hash]
        ; test rbx, rax
        ; je .correct
        ; jne .incorrect


.incorrect:
        mov rdi, negative
        call puts

        jmp .retry
.correct:
        mov rdi, positive
        call puts

        ; call _puts        
        ret



;==========================================================
; using last value of rdi from printf as pos to be set \0
; prints string
;==========================================================



section .data
; buff_len          dw 17    
; password            db'', 0
buff                times 15 db 0x0
my_pass_hash                db  0x9d,0x26, 0xc0, 0x55, 0, 0, 0, 0, 0, 0
buff_len     equ    22
negative:						db "Haha ti thought chto you are able to vzlomat my password dumbass", 0x0
positive:						db "So, ur gay...", 0x0
; buff_len_const    equ 17
ans_switch:
                        dq main.retry
                        dq main.incorrect
                        dq main.correct

section .bss
; buff                    resb buff_len_const
; buff_len__              resw 1

; 0xECCE7182
;ur mom is gay

; ÑØ9F
        