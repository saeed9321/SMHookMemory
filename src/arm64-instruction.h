#include <UIKit/UIKit.h>
#include <substrate.h>
#include <keystone/keystone.h>


unsigned char *get_hex_from_instruction(const char* inst, size_t *size);

void b(uint64_t orig, uint64_t dist);
void bl(uint64_t orig, uint64_t dist);
void adrp(uint64_t addr, uint64_t page_shift);
void add(uint64_t addr, uint64_t value);
void br(uint64_t addr);
void blr(uint64_t addr);


