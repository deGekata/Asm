
#include <stdio.h>

extern "C" void std_printf(const char* format_, ...);

int main(void)
{
        
    std_printf("b %s, %d\n", "\n^kekw^\n", 124);
    printf("endgg");
    return 0;
}    

/*
nasm -f elf64 main.asm 
gcc caller.cpp -c -g -o caller.o
gcc caller.o main.o -no-pie
./a.out
*/
/*
40112a
0000000000402004
402011
*/

/*
nasm -f elf64 main.asm 
gcc caller.cpp -c -g -o caller.o
gcc caller.o main.o -no-pie
./rn.out
*/