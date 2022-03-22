#include "CRC.h" // Only need to include this header file!
                 // No libraries need to be included. No project settings need to be messed with.

// #include <iostream> // Includes ::std::cout
#include <inttypes.h>  // Includes ::std::uint32_t
#include <stdio.h>
#include <stdlib.h>

const size_t message_len  = 3;
int iter = 0;
int generate(uint32_t ref, size_t cur_len, char* buff) {
    if (iter % 100000 == 0) printf("%d iter\n", iter);
    // printf("lol %llu\n", cur_len);
    if (cur_len == message_len) {
        iter++;
        uint32_t hash = CRC::Calculate(buff, message_len, CRC::CRC_32());

        if (hash == ref) {
            // printf("%s\n", buff);
            for (int it = 0; it < message_len; ++it) {
                printf("%u ", int(buff[it]));
            }
            return 1;
        }
        return 0;
    }
    for (unsigned char cur_let = 0; cur_let < 256; ++cur_let) {
        buff[cur_len] = cur_let;
        if (generate(ref, cur_len + 1, buff)) {
            return 1;
        }
    }
    return 0;
}

int main(int argc, char ** argv)
{
	// const char myString[] = { 'h', 'e'};
    // aaaetmtyec
	
	// uint32_t crc = CRC::Calculate(myString, sizeof(myString), CRC::CRC_32());
    uint32_t num = 0xECCE7182;
    printf("%d", int(num));
    uint32_t crc = 2;
    printf("lol1");
    char* buff = (char*) calloc(message_len + 1, sizeof(char));    
    printf("lol2");

	// generate(crc, 0, buff);
	
	return 0;
}
