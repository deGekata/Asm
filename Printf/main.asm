; nasm + link + LibC

; nasm "2-Nasm+Link.asm" -f win32 -l "2-Nasm+Link.lst"
; link "2-Nasm+Link.obj" libcmt.lib kernel32.lib /subsystem:console


; bits 32

global _main
extern _printf
extern __cputs
extern _putchar


section .text

_main:          

                ; push 123
                ; mov edi, buff
                ; call itoad
                ; add esp, 4
                ; call dropbuff
                
                ; push dword msg
                ; push dword 'p'
                ; push dword 'b'
                ; push dword 'c'
                ; push dword 'd'
                push dword octm
                push dword 4294967295 
                ; push dword 'e'
                ; push dword 15314323
                push dword 4294967295
                ; push dword 'a'
                push dword 4294967295
                push dword 4294967295
                ; push dword hexm
                push dword msg
                call printf
                add esp, 4 * 6
                
                ; pop eax
                ; push buff
                ; call _printf
                
                ret




printf:
                push ebp                ;making stack frame
                mov ebp, esp
                add ebp, 8              

                xor eax, eax            
                mov edi, buff           ;init buff
                mov esi, [ebp]          ;init format string
                add ebp, byte 4
                mov edx, 0
                
                ; mov esi, msg
                ; mov edi, buff
                
                ; mov cs, 

    .loop:      
                				xor eax, eax
                lodsb
                cmp al, 0
                je .endloop
                cmp al, '%'
                jne .standart
                
                lodsb                
                
                ;do some switch shit
                cmp eax, 'b'            ;if less than b
                jl .standart

                cmp eax, 's'            ;if grtr than s
                jg .standart

                sub eax, 'b'            ;middle part
                jmp [printf_switch + eax * 4]

        .char
                mov eax, [ebp]
                add ebp, 4
                stosb
                jmp .end_choice

        .bin
                push edx
                mov eax, bin_mask
                mov ecx, 1
                jmp .print_b

        .decimal
                push dword 10
                push dword [ebp]
                call itoad
                add esp, 8
                add ebp, 4

                jmp .end_choice

        .hex
                push edx
                mov eax, hex_mask ;mask
                mov ecx, 4      ;shift offs
                jmp .print_b

        .oct
                push edx
                mov eax, oct_mask ;mask
                mov ecx, 3      ;shift offs
                jmp .print_b

        .print_b        
                mov ebx, [ebp]
                call itoaBin
                add ebp, 4
                pop edx
                jmp .end_choice

        .string
                call dropbuff
                
                push dword [ebp]
                call __cputs
                add esp, byte 4
                add ebp, byte 4
                jmp .end_choice
                ; call dropbuff                


                
                je .endloop
    .standart:
                stosb
                inc edx

    .end_choice:

                cmp edx, buff_len
                jne .buff_undrop
                call dropbuff
    .buff_undrop:
                jmp .loop



    .endloop: 

                call dropbuff

                pop ebp
    ret

;==========================================================
; using last value of edi from printf as pos to be set \0
; prints string
;==========================================================
dropbuff:
                mov byte [edi], 0
                push dword buff
                call __cputs
                add esp, byte 4
                mov edi, buff
                xor edx, edx
                
                
                push dword Text
                call _printf            ; printf (MsgText)
                add esp, 4
                ret


;==========================================================
; using last value of edi from printf as pos to be set \0
; prints string
;==========================================================
itoaBin:
                ; push edx
                push esi
                xor edx, edx


                .extract_sym:
                mov esi, ebx
                and esi, eax ;edx
                push esi ; push sym
                shr ebx, cl
                inc edx                     ; cnt of syms               
                test ebx, ebx
                jnz .extract_sym            ; end of number 

                .write_sym:
                pop dword ebx
                mov bl, [table_hex_symbols + ebx]

                mov [edi], bl
                inc edi
                dec edx
                test edx, edx
                jnz .write_sym
                pop esi

                ret


delim:

itoad

                mov ebx, [esp + 8]              ;base of system
                mov eax, [esp + 4]              ;number
                push edx
                
                xor ecx, ecx


                .extract_sym:
                xor edx, edx
                div ebx
                inc ecx                         ; cnt of syms
                push edx                        ; push sym
                test eax, eax
                jnz .extract_sym                ; end of number 

                .write_sym:
                pop dword ebx
                mov bl, [table_hex_symbols + ebx]       ;load char from table
                mov [edi], bl                           ;mov char to memory
                inc edi                                 ;inc buff ptr
                dec ecx                                 ;now need to print 1 less sym
                test ecx, ecx                           ;test if we dont need print anymore
                jnz .write_sym

                pop edx
                ret


section .data use32
table_hex_symbols   db "0123456789ABCDEF"
decm                db "/decm/", 0
hexm                db "hexm", 0
charm               db "charm", 0ah, 0
stringm             db "string", 0ah, 0
octm                db "oct", 0ah, 0
Text                db "", 0
; msg                 db "%s | %% %d %b %c", 0
msg                 db "%h", 0
len             	equ $-msg	




section .const
buff_len        equ 120
buff_lenend     equ 120 + 33                        ; max len of base output type
                                                ; + 1 for \0
bin_mask        equ 0001h 
oct_mask        equ 0007h 
hex_mask        equ 000fh 

printf_switch: 
                            dd printf.bin
                            dd printf.char
                            dd printf.decimal
                times 3d    dd printf.standart
                            dd printf.hex
                times 6d    dd printf.standart
                            dd printf.oct
                times 3d    dd printf.standart
                            dd printf.string

section .bss
buff                resb buff_lenend
