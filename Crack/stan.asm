;----------------------------------------------------------------------------------------
; Goryainov SI
; 14.03.2022 
;
; Task 6:
; 		Write password protected program with a couple
;		of vulnerabilities for opponent to crack
;
; To assemble and run:
; 		nasm crack_me.asm -felf64 -s -o crack_me.o
; 		gcc crack_me.o -no-pie -o crack_me.out
; 		./crack_me.out
;----------------------------------------------------------------------------------------


extern fgets
extern puts
extern strlen
extern stdin
extern stdout


global main


section .consts

STDOUT			equ		1
STDIN			equ		2
BUFFER_SIZE		equ		144


section .text

main:		; first canary
			xor rax, rax
			rdtsc
;----------------------------------------------------------
			mov rcx, qword [not_a_password]
			shl rax, 32
			add rax, 0x00001000
			add rax, qword [not_a_password]
			shl rax, 1
			inc rax
			add eax, 113525
			add rax, 234234
			shr rax, 17						; DOES NOTHING
			inc rax
			sub rax, 2342
			add rax, 17
			shl rax, 4
			add rax, rcx
			inc rax
			add rax, 14314
			inc rax
			add rax, 32
			shr rax, 32
;----------------------------------------------------------
			rdtsc
			mov qword [left_canary],  rax
			push rax

			; second canary
			xor rax, rax
			rdtsc
;----------------------------------------------------------
			and rax, 120
			or rax, 101010
			inc rax
			xor rax, 345					; DOES NOTHING
			dec rax
			add rax, 16
			shl rax, 4
			add rax, 8
;----------------------------------------------------------
			rdtsc
			mov qword [right_canary], rax
			push rax

			mov rdi, entry_password_msg
			call puts

			mov rdi, not_a_buffer
			mov rsi, BUFFER_SIZE
			mov rdx, [stdin]
			call fgets

			; first canary check
			pop rax
			cmp qword [right_canary], rax
			jne .incorrect
			
			; second canary check
			pop rax
			cmp qword [left_canary],  rax 
			jne .incorrect

			xor rax, rax
			mov rdi, not_a_buffer
			call strlen

			mov rcx, rax
			xor rax, rax
			mov rdi	, 0

.hash		crc32 rax, byte [not_a_buffer + rdi]
			inc rdi
			loop .hash

            cmp rax, qword [not_a_password]
            je .correct

.incorrect	mov rdi, negative
            call puts
            jmp .exit

.correct:	mov rdi, affirmative
            call puts

.exit:		mov rax, 0x3C
			xor rdi, rdi
			syscall


section .data

not_a_buffer:		times 128 	db 0x0
left_canary:					dq 0x0
not_a_password:					dq 0x000000008B51A725
right_canary:					dq 0x0

affirmative:					db "You're in... Here's the secret of the Universe: 42", 0x0
negative:						db "Haha ti thought chto you are able to vzlomat my password dumbass", 0x0

entry_password_msg:				db "Enter Password:", 0x0
