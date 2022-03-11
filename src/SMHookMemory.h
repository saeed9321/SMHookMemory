#include <UIKit/UIKit.h>
#include <mach/mach.h> 
#include <sys/syscall.h>
#include <mach-o/dyld.h> 
#include <mach-o/getsect.h> 
#include "arm64-trampoline.h"
#include "arm64-instruction.h"

/* 
  Purpose:
      Get base address for specified image
  Parameters:
      image name or NULL for base image
  Return value:
      image slide
*/
uint64_t image_slide(char *imageName);



/* 
  Purpose:
      Get address+aslr for address in specified image name
  Parameters:
      image name or NULL for base image
      address from Ghidra/IDA ...
  Return value:
      real address
*/
uint64_t real_address(char *imageName, uint64_t address);




/* 
  Purpose:
      Patch arm64 instruction at specified address and image name
  Parameters:
      image name or NULL for base image
      address from Ghidra/IDA ...
      arm64 instruction ex: ret OR mov x0, 0x1
  Return value:
      true  : if success
      false : fail, errors will be printed using NSLog
*/
bool SMHookMemory(char *imageName, uint64_t addr, const char* inst);



/* 
  Purpose:
      DBI handler function to printf registers value
  Parameters:
      none 
  Return value:
      none
*/
void printRegisters(void);



/* 
  Purpose:
      Dynamic Binary Instrumentation
  Parameters:
      image name or NULL for base image
      address from Ghidra/IDA ...
      handle function 
  Return value:
      none
*/
void SMInstrument(char *imageName, uint64_t addr, void* handle);



/* 
  Purpose:
      Dynamic Binary Instrumentation SVC #0x80
  Parameters:
      image name or NULL for base image
      handle function 
  Return value:
      none
*/
void SMInstrumentSVC80(char *imageName, void* handle);
