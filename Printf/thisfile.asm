    global subEmP
    ; extern _printf

    section .text
subEmP:
    push rbp
    mov  rbp, rsp
    
    mov  rax, [rbp+16]
    add  rax, [rbp+24]
    add  rax, [rbp+32]
    add  rax, [rbp+40]
    add  rax, [rbp+48]
    add  rax, [rbp+56]
    add  rax, [rbp+64]
    add  rax, [rbp+70]



    ; push rax
    ; mov  rax, .fmt
    ; push rax
    ; call _printf
    ; add  rsp, 16

    pop rbp
    
    ret

    ;section .data
.fmt  db '%i',0x0d,0x0a,0