#include "arm64-instruction.h"


unsigned char *get_hex_from_instruction(const char* inst, size_t *size)
{
	ks_engine *ks;
	ks_err err = ks_open(KS_ARCH_ARM64, KS_MODE_LITTLE_ENDIAN, &ks);

	if(err != KS_ERR_OK){
		NSLog(@"SMHookMemory:: Failed to init the assembler, check your installation");
		return 0;
	}
	
	size_t count;
    unsigned char *encode;

	int ret = ks_asm(ks, inst, 0, &encode, size, &count);

	if(ret != 0){
		NSLog(@"SMHookMemory:: Invalid ARM64 instruction");
		return 0;
	}

	return encode;
}

void b(uint64_t orig, uint64_t dist)
{
    uint64_t bl_size = dist - orig;
    
    size_t nbytes = snprintf(NULL, 0, "bl %p", (void*)bl_size) + 1;
    char *bl_str = malloc(nbytes);
    snprintf(bl_str, nbytes, "bl %p", (void*)bl_size);
    
    size_t bl_instr_size = 0;
    unsigned char *bl_instr = get_hex_from_instruction(bl_str, &bl_instr_size);
    
    MSHookMemory((void*)orig, bl_instr, bl_instr_size);
}

void bl(uint64_t orig, uint64_t dist)
{
    uint64_t bl_size = dist - orig;
    
    size_t nbytes = snprintf(NULL, 0, "bl %p", (void*)bl_size) + 1;
    char *bl_str = malloc(nbytes);
    snprintf(bl_str, nbytes, "bl %p", (void*)bl_size);
    
    size_t bl_instr_size = 0;
    unsigned char *bl_instr = get_hex_from_instruction(bl_str, &bl_instr_size);
    
    MSHookMemory((void*)orig, bl_instr, bl_instr_size);
}

void adrp(uint64_t addr, uint64_t page_shift)
{
    size_t nbytes = snprintf(NULL, 0, "adrp x17, %p", (void*)page_shift) + 1;
    char *adrp_str = malloc(nbytes);
    snprintf(adrp_str, nbytes, "adrp x17, %p", (void*)page_shift);
    
    size_t adrp_instr_size = 0;
    unsigned char *adrp_instr = get_hex_from_instruction(adrp_str, &adrp_instr_size);
    
    MSHookMemory((void*)addr, adrp_instr, adrp_instr_size);
    
    // NSLog(@"SMInstrument:: write adrp on %llx -> %s (page shift:%llu - data:%x)", addr, adrp_str, page_shift, *(uint32_t*)addr);
}

void add(uint64_t addr, uint64_t value)
{
    size_t nbytes = snprintf(NULL, 0, "add x17, x17, %p", (void*)value) + 1;
    char *add_str = malloc(nbytes);
    snprintf(add_str, nbytes, "add x17, x17, %p", (void*)value);
    
    size_t add_instr_size = 0;
    unsigned char *add_instr = get_hex_from_instruction(add_str, &add_instr_size);
    
    MSHookMemory((void*)addr, add_instr, add_instr_size);
}

void br(uint64_t addr)
{
    size_t nbytes = snprintf(NULL, 0, "br x17") + 1;
    char *br_str = malloc(nbytes);
    snprintf(br_str, nbytes, "br x17");
    
    size_t br_instr_size = 0;
    unsigned char *br_instr = get_hex_from_instruction(br_str, &br_instr_size);
    
    MSHookMemory((void*)addr, br_instr, br_instr_size);
}

void blr(uint64_t addr)
{
    size_t nbytes = snprintf(NULL, 0, "blr x17") + 1;
    char *br_str = malloc(nbytes);
    snprintf(br_str, nbytes, "blr x17");
    
    size_t br_instr_size = 0;
    unsigned char *br_instr = get_hex_from_instruction(br_str, &br_instr_size);
    
    MSHookMemory((void*)addr, br_instr, br_instr_size);
}