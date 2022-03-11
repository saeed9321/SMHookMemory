#include <stdio.h>
#include <strings.h> 
#include <stdlib.h>
#include <mach-o/dyld.h> 
#include <substrate.h>


// General registers X0-X30 accessbile in handler function
extern struct _Registers ctx;

typedef struct _Registers {
  uint64_t x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, 
           x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27,
           x28, fp, lr;
} Registers;

extern int trampoline_counter;
extern uint64_t trampoline_list[100]; // Count of instrumented address
extern uint32_t trampoline_orig_instr[100]; // Orig overwritten instr - short/long trampoline type 
extern uint32_t trampoline_orig_instr_force[100][3]; // Orig overwritten instr - force trampoline type 
extern uint64_t lr;


// trampolibe wrappers
__attribute__((naked)) void loadRegisters();
__attribute__((naked)) void storeRegisters();
