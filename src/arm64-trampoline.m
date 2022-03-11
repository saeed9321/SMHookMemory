#include "arm64-trampoline.h"


struct _Registers ctx;

int trampoline_counter;
uint64_t trampoline_list[100];
uint32_t trampoline_orig_instr[100];
uint32_t trampoline_orig_instr_force[100][3];
uint64_t lr = 0;


// Trampoline wrappers - loading all registers after handler
__attribute__((naked)) void loadRegisters()
{        
    __asm__("mov x30, %0" :: "r" (ctx.lr));
    __asm__("mov x29, %0" :: "r" (ctx.fp));
    __asm__("mov x28, %0" :: "r" (ctx.x28));
    __asm__("mov x27, %0" :: "r" (ctx.x27));
    __asm__("mov x26, %0" :: "r" (ctx.x26));
    __asm__("mov x25, %0" :: "r" (ctx.x25));
    __asm__("mov x24, %0" :: "r" (ctx.x24));
    __asm__("mov x23, %0" :: "r" (ctx.x23));
    __asm__("mov x22, %0" :: "r" (ctx.x22));
    __asm__("mov x21, %0" :: "r" (ctx.x21));
    __asm__("mov x20, %0" :: "r" (ctx.x20));
    __asm__("mov x19, %0" :: "r" (ctx.x19));
    __asm__("mov x18, %0" :: "r" (ctx.x18));
    __asm__("mov x17, %0" :: "r" (ctx.x17));
    __asm__("mov x16, %0" :: "r" (ctx.x16));
    __asm__("mov x15, %0" :: "r" (ctx.x15));
    __asm__("mov x14, %0" :: "r" (ctx.x14));
    __asm__("mov x13, %0" :: "r" (ctx.x13));
    __asm__("mov x12, %0" :: "r" (ctx.x12));
    __asm__("mov x11, %0" :: "r" (ctx.x11));
    __asm__("mov x10, %0" :: "r" (ctx.x10));
    
    __asm__("mov x7, %0"  :: "r" (ctx.x7));
    __asm__("mov x6, %0"  :: "r" (ctx.x6));
    __asm__("mov x5, %0"  :: "r" (ctx.x5));
    __asm__("mov x4, %0"  :: "r" (ctx.x4));
    __asm__("mov x3, %0"  :: "r" (ctx.x3));
    __asm__("mov x2, %0"  :: "r" (ctx.x2));
    __asm__("mov x1, %0"  :: "r" (ctx.x1));
    __asm__("mov x0, %0"  :: "r" (ctx.x0));
    
    __asm__("mov x9, %0"  :: "r" (ctx.x9));
    __asm__("mov x8, %0"  :: "r" (ctx.x8));
    
    
    __asm__("nop"); // Original instruction will be written here
    __asm__("nop"); // Original instruction will be written here
    __asm__("nop"); // Original instruction will be written here
    
    __asm__("ret"); // This branch to trampoline start + 0x4
}

// Trampoline wrappers - save from stack to ctx 
__attribute__((naked)) void saveRegisters()
{
    __asm__("ldp x9, x10, [sp, 30 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.fp));
    __asm__("mov %0, x10"  : "=r" (ctx.lr));
    
    __asm__("ldp x9, x10, [sp, 28 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x27));
    __asm__("mov %0, x10"  : "=r" (ctx.x28));
    
    __asm__("ldp x9, x10, [sp, 26 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x25));
    __asm__("mov %0, x10"  : "=r" (ctx.x26));
    
    __asm__("ldp x9, x10, [sp, 24 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x23));
    __asm__("mov %0, x10"  : "=r" (ctx.x24));
    
    __asm__("ldp x9, x10, [sp, 22 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x21));
    __asm__("mov %0, x10"  : "=r" (ctx.x22));
    
    __asm__("ldp x9, x10, [sp, 20 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x19));
    __asm__("mov %0, x10"  : "=r" (ctx.x20));
    
    __asm__("ldp x9, x10, [sp, 18 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x17));
    __asm__("mov %0, x10"  : "=r" (ctx.x18));
    
    __asm__("ldp x9, x10, [sp, 16 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x15));
    __asm__("mov %0, x10"  : "=r" (ctx.x16));
    
    __asm__("ldp x9, x10, [sp, 14 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x13));
    __asm__("mov %0, x10"  : "=r" (ctx.x14));
    
    __asm__("ldp x9, x10, [sp, 12 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x11));
    __asm__("mov %0, x10"  : "=r" (ctx.x12));
    
    __asm__("ldp x9, x10, [sp, 10 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x9));
    __asm__("mov %0, x10"  : "=r" (ctx.x10));
    
    __asm__("ldp x9, x10, [sp, 8 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x7));
    __asm__("mov %0, x10"  : "=r" (ctx.x8));
    
    __asm__("ldp x9, x10, [sp, 6 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x5));
    __asm__("mov %0, x10"  : "=r" (ctx.x6));
    
    __asm__("ldp x9, x10, [sp, 4 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x3));
    __asm__("mov %0, x10"  : "=r" (ctx.x4));
    
    __asm__("ldp x9, x10, [sp, 2 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x1));
    __asm__("mov %0, x10"  : "=r" (ctx.x2));
    
    __asm__("ldr x9, [sp, 1 * 8]");
    __asm__("mov %0, x9"  : "=r" (ctx.x0));
    
    __asm__("add sp, sp, 32 * 8");
    __asm__("ret");
}

// Trampoline wrappers - storing to the stack
__attribute__((naked)) void storeRegisters()
{
    
    __asm__("sub sp, sp, 32 * 8");
    __asm__("stp x29, x30, [sp, 30 * 8]");
    __asm__("stp x27, x28, [sp, 28 * 8]");
    __asm__("stp x25, x26, [sp, 26 * 8]");
    __asm__("stp x23, x24, [sp, 24 * 8]");
    __asm__("stp x21, x22, [sp, 22 * 8]");
    __asm__("stp x19, x20, [sp, 20 * 8]");
    __asm__("stp x17, x18, [sp, 18 * 8]");
    __asm__("stp x15, x16, [sp, 16 * 8]");
    __asm__("stp x13, x14, [sp, 14 * 8]");
    __asm__("stp x11, x12, [sp, 12 * 8]");
    __asm__("stp x9,  x10, [sp, 10 * 8]");
    __asm__("stp x7,  x8,  [sp, 8 * 8]");
    __asm__("stp x5,  x6,  [sp, 6 * 8]");
    __asm__("stp x3,  x4,  [sp, 4 * 8]");
    __asm__("stp x1,  x2,  [sp, 2 * 8]");
    __asm__("str x0,       [sp, 1 * 8]");
    
    __asm__("mov %0, lr" : "=r" (lr));

    __asm__("bl _saveRegisters");
    __asm__("bl _prepareOrigInstr");
    __asm__("nop"); // this to be over-written to jump to handler
    __asm__("b _loadRegisters");
}


