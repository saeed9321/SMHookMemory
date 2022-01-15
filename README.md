# SMHookMemory
iOS Easy Hooking Library for arm64/arm64e devices

### How to Install:
1. Install the deb file.
2. Copy ```libSMHookMemory.dylib``` to your ```theos/lib``` folder.

### How to Include to your project:
1. Include the header file ```SMHookMemory.h``` to your project
2. Add SMHookMemory to your MakeFile:
         ```$(TWEAK_NAME)_LIBRARIES = SMHookMemory```

### How to Use:

#### ```bool SMHookMemory(char *imageName, uint64_t addr, const char* inst);```
* **imageName**: dylib image name you would like to patch.
* **addr**     : address (from Ghidra/IDA/Hopper without ASLR).
* **inst**     : ARM instruction.

### Examples:
* ```SMHookMemory("sampleApp", 0x100005c44, "ret");```
* ```SMHookMemory("sampleApp", 0x100005c54, "mov x0, 0x1");```

Twitter: https://twitter.com/Saeed97271
