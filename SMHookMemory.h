


/* 
  Purpose:
      You can access all registers values in debug function when trampoline
  Parameters:
      image name
      address from Ghidra/IDA ...
      handle function 
  Return value:
      none
*/
extern struct _Registers ctx;
typedef struct _Registers {
  union {
    uint64_t x[29];
    struct {
      uint64_t x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28;
    } regs;
  } general;

  uint64_t fp;
  uint64_t lr;
} Registers;



/* 
  Purpose:
      Get base address for specified image
  Parameters:
      image name
  Return value:
      image slide
*/
uint64_t image_slide(char *imageName);



/* 
  Purpose:
      Get address+aslr for address in specified image name
  Parameters:
      address from Ghidra/IDA ...
      image name
  Return value:
      real address
*/
uint64_t real_address(char *imageName, uint64_t address);



/* 
  Purpose:
      Generate hex bytes from arm64 instruction
  Parameters:
      arm64 instruction
      size buffer pointer
  Return value:
      hex bytes
      size
*/
unsigned char *get_hex_from_instruction(const char* inst, size_t *size);



/* 
  Purpose:
      Patch arm64 instruction at specified address and image name
  Parameters:
      image name
      address from Ghidra/IDA ...
      arm64 instruction ex: ret OR mov x0, 0x1
  Return value:
      true  : if success
      false : fail, errors will be printed using NSLog
*/
bool SMHookMemory(char *imageName, uint64_t addr, const char* inst);



/* 
  Purpose:
      Dynamic Binary Instrumentation
  Parameters:
      image name
      address from Ghidra/IDA ...
      handle function 
  Return value:
      none
*/
void SMInstrument(char *imageName, uint64_t addr, void* handle);