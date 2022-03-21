; nasm + link + LibC

; nasm "2-Nasm+Link.asm" -f win64 -l "2-Nasm+Link.lst"
; link "2-Nasm+Link.obj" libcmt.lib kernel32.lib /subsystem:console


; bits 32
[BITS 64]

NULL              EQU 0                         ; Constants
STD_OUTPUT_HANDLE EQU -11

extern GetStdHandle                             ; Import external symbols
extern WriteFile                                ; Windows API functions, not decorated
extern ExitProcess   
extern lstrlen 
extern WriteConsoleA

global _printf_caller
; extern _printf
; extern __cputs
; extern _putchar

section .text

; _main:          
;                 ; sub   RSP, 8                                   ; Align the stack to a multiple of 16 bytes

;                 ; sub   RSP, 32                                  ; 32 bytes of shadow space
;                 ; mov   ECX, STD_OUTPUT_HANDLE
;                 ; call  GetStdHandle
;                 ; mov   qword [REL StandardHandle], RAX
;                 ; add   RSP, 32                                  ; Remove the 32 bytes

;                 ; sub   RSP, 32 + 8 + 8                          ; Shadow space + 5th parameter + align stack
;                 ;                                                 ; to a multiple of 16 bytes
;                 ; mov rcx, Message
;                 ; call lstrlen
;                 ; mov   r8, RAX
;                 ; mov   RCX, qword [REL StandardHandle]          ; 1st parameter
;                 ; lea   RDX, [REL Message]                       ; 2nd parameter
;                 ; ; mov   R8, MessageLength                        ; 3rd parameter
;                 ; lea   R9, [REL Written]                        ; 4th parameter
;                 ; mov   qword [RSP + 4 * 8], NULL                ; 5th parameter
;                 ; call  WriteFile                                ; Output can be redirect to a file using >
;                 ; add   RSP, 48                                  ; Remove the 48 bytes

;                 ; xor   ECX, ECX
;                 ; call  ExitProcess

;                 ; push 123
;                 ; mov rdi, buff
;                 ; call itoad
;                 ; add rsp, 4
;                 ; call dropbuff
                
;                 ; push qword msg
;                 ; push qword 'p'
;                 ; push qword 'b'
;                 ; push qword 'c'
;                 ; push qword 'd'
;                 ; push qword octm
;                 ; push qword 4294967295 
;                 ; push qword 'e'
;                 ; push qword 15314323
;                 ; push qword 4294967295
;                 ; push qword 'a'
;                 ; push qword hexm
;                 push qword 0FBh
;                 push qword hexm
;                 push qword 4294967295
;                 push qword hexm
;                 push qword msg
;                 call printf
;                 add rsp, 8 * 5
                
;                 ; pop rdx
;                 ; push buff
;                 ; call _printf
                
;                 ret


_printf_caller:
        pop r10
        mov qword [printfSaveBp], r10
        pop r10
        mov qword [printfRetAddr], r10

        push r8
        push rdi
        push rcx
        push rdx
        push rsi
        push rax

        call printf

        pop rax
        pop rsi
        pop rdx
        pop rcx
        pop rdi
        pop r8

        push [printfRetAddr]
        push [printfSaveBp]

        ret


printf:
                sub   RSP, 32                                  ; 32 bytes of shadow space
                mov   ECX, STD_OUTPUT_HANDLE
                call  GetStdHandle
                mov   qword [REL StandardHandle], RAX
                add   RSP, 32 
                
                
                push rbp                ;making stack frame
                mov rbp, rsp
                add rbp, 16              

                xor rdx, rdx            
                mov rdi, buff           ;init buff
                mov rsi, [rbp]          ;init format string
                add rbp, byte 8
                mov rdx, 0
                
                ; mov rsi, msg
                ; mov rdi, buff
                
                ; mov cs, 

    .loop:      
                xor rdx, rdx
                lodsb
                cmp al, 0
                je .endloop
                cmp al, '%'
                jne .standart
                ; je .endloop
                ; xor ecx, ecx
                ; call ExitProcess
                lodsb                
                
                ;do some switch shit
                cmp rax, 'b'            ;if less than b
                jl .standart
                ; je .endloop
                cmp rax, 's'            ;if grtr than s
                jg .standart
                ; jg .endloop

                sub rax, 'b'            ;middle part
                ; xor ecx, ecx
                ; call ExitProcess
                jmp [printf_switch + rax * 8]

        .char
                mov rdx, [rbp]
                add rbp, 8
                stosb
                ; xor ecx, ecx
                ; call ExitProcess
                jmp .end_choice

        .bin
                push rdx
                push rsi
                mov rdx, bin_mask
                mov rcx, 1
                jmp .print_b

        .decimal
                push rdx
                push rsi
                mov rbx, 10
                mov rax, [rbp]
                call itoad
                pop rsi
                pop rdx
                add rbp, 8

                ; jmp .end_choice
                jmp .end_choice

        .hex
                push rdx
                push rsi
                mov rdx, hex_mask ;mask
                mov rcx, 4      ;shift offs
                jmp .print_b

        .oct
                push rdx
                push rsi
                mov rdx, oct_mask ;mask
                mov rcx, 3      ;shift offs
                jmp .print_b

        .print_b        
                
                mov rbx, [rbp]
                call itoaBin
                add rbp, 8
                pop rsi
                pop rdx
                jmp .end_choice

        .string
                call dropbuff
                
                mov rcx, [rbp]
                call lstrlen
                mov r8, RAX
                mov rcx, qword [REL StandardHandle]
                sub rsp, 40
                mov r9, char_written

                ; mov rax, qword 0                  
                mov rdx, [rbp]
                mov qword [rsp+0x20], 0

                call WriteConsoleA
                add rsp, 40 
                ;==========================================================
                        ; call __cputs
                ; add rsp, byte 8
                add rbp, byte 8
                mov rdi, buff
                xor rdx, rdx
                jmp .end_choice
                ; call dropbuff                


                
                je .endloop
    .standart:
                ; xor ecx, ecx
                ; call ExitProcess
                stosb
                inc rdx

    .end_choice:

                cmp rdx, buff_len
                jne .buff_undrop
                call dropbuff
    .buff_undrop:
                jmp .loop



    .endloop: 

                call dropbuff

                ; pop rbp
                pop rbp
                ; call ExitProcess
    ret

;==========================================================
; using last value of rdi from printf as pos to be set \0
; prints string
;==========================================================
dropbuff:
                mov byte [rdi], 0
                mov rcx, buff
                call lstrlen
                mov r8, RAX
                mov rcx, qword [REL StandardHandle]
                ; mov rdx, buff
                ; call

                
                sub rsp, 40

                ; mov rcx, 

                mov r9, char_written

                ; mov rax, qword 0                  
                mov rdx, buff
                mov qword [rsp+0x20], 0

                call WriteConsoleA
                add rsp, 40 
                ; push qword buff
                ; ;==========================================================
                ; push STD_OUTPUT_HANDLE
                ; call GetStdHandle


                ; push 0
                ; push 
                ; mov rcx, rdx
                ; sub rsp, 40
                
                ; call __cputs
                ; add rsp, byte 8
                mov rdi, buff
                xor rdx, rdx
                
                
                ; push qword Text
                ; call _printf            ; printf (MsgText)
                ; add rsp, 8
                ret


;==========================================================
; using last value of rdi from printf as pos to be set \0
; prints string
;==========================================================
itoaBin:
                ; push rdx
                push rsi
                ; xor rdx, rdx

                xor rax, rax
                .extract_sym:
                mov rsi, rbx
                and rsi, rdx ;rdx
                push qword rsi ; push sym
                shr rbx, cl
                inc rax                     ; cnt of syms               
                test rbx, rbx
                jnz .extract_sym            ; end of number 

                .write_sym:
                pop qword rbx
                mov bl, [itoa_symbols_table + rbx]

                mov [rdi], bl
                inc rdi
                dec rax
                test rax, rax
                jnz .write_sym
                pop rsi

                ret


delim:

itoad
                push rdx
                
                xor rcx, rcx


                .extract_sym:
                xor rdx, rdx
                div rbx
                inc rcx                         ; cnt of syms
                push rdx                        ; push sym
                test rax, rax
                jnz .extract_sym                ; end of number 

                .write_sym:
                pop qword rbx
                mov bl, [itoa_symbols_table + rbx]       ;load char from table
                mov [rdi], bl                           ;mov char to memory
                inc rdi                                 ;inc buff ptr
                dec rcx                                 ;now need to print 1 less sym
                test rcx, rcx                           ;test if we dont need print anymore
                jnz .write_sym

                pop rdx
                ret


section .data
itoa_symbols_table   db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
decm                db "/decm/", 0
hexm                db "hexm", 0
charm               db "charm", 0ah, 0
stringm             db "string", 0ah, 0
octm                db "oct", 0ah, 0
Text                db "", 0
; msg                 db "%s | %% %d %b %c", 0
msg                 db "%s %d %s %o  lol   ", 0
len             	equ $-msg	
Message        db "Console Message 64", 0Dh, 0Ah
MessageLength  EQU $-Message   


section .const
buff_len        equ 120
buff_lenend     equ 120 + 33                        ; max len of base output type
                                                ; + 1 for \0
bin_mask        equ 0001h 
oct_mask        equ 0007h 
hex_mask        equ 000fh 

STD_OUTPUT_HANDLE   equ -11
STD_INPUT_HANDLE    equ -10

printf_switch: 
                            dq printf.bin
                            dq printf.char
                            dq printf.decimal
                times 3d    dq printf.standart
                            dq printf.hex
                times 6d    dq printf.standart
                            dq printf.oct
                times 3d    dq printf.standart
                            dq printf.string

section .bss
printfRetAddr resq 1
printfSaveBp resq 1

buff                    resb buff_lenend
StandardHandle          resq 1
char_written            resb    4
chars                   resb 4 