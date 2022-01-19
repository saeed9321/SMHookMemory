# SMHookMemory
### iOS Lightweight Hooking Framework for ARM64
---

## How to Install:
1. Install the deb file.
2. Copy ```libSMHookMemory.dylib``` to your ```theos/lib``` folder.
3. Add SMHookMemory to your MakeFile:
         ```$(TWEAK_NAME)_LIBRARIES = SMHookMemory```
4. Include the header file ```SMHookMemory.h``` to your project

#
## How to Use:

#### ```void SMInstrument(char *imageName, uint64_t addr, void* handle);```
* **imageName**: dylib image name you would like to patch.
* **addr**     : address (from Ghidra/IDA/Hopper without ASLR).
* **handle**     : Pointer to handle function.

### Example:
```
void handle(void){
    uint64_t x0 = ctx.general.regs.x0;
    NSLog("Value @ register X0: %llu", x0);
}

SMHookMemory("sampleApp", 0x100005c44, &handle);
```
#
#### ```bool SMHookMemory(char *imageName, uint64_t addr, const char* inst);```
* **imageName**: dylib image name you would like to patch.
* **addr**     : address (from Ghidra/IDA/Hopper without ASLR).
* **inst**     : ARM instruction.

### Example:
```
SMHookMemory("sampleApp", 0x100005c44, "ret");
SMHookMemory("sampleApp", 0x100005c54, "mov x0, 0x1");
```

Twitter: https://twitter.com/Saeed97271
