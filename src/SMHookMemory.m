#include "SMHookMemory.h"

uint64_t trampoline_empty_temp_space = 0;

// Get ASLR for specified image
uint64_t image_slide(char *imageName)
{
    if(imageName == NULL){
        return (uint64_t)_dyld_get_image_vmaddr_slide(0);
    }
    
    for(int i=0; i< _dyld_image_count(); i++){
		if(strstr(_dyld_get_image_name(i), imageName) != NULL){
			return (uint64_t)_dyld_get_image_vmaddr_slide(i);
		}
	}
	printf("SMHookMemory:: Failed to find the base address of the specified image");
	return 0;
}


// Get read address from a specified image and address -> addr + ASLR
uint64_t real_address(char *imageName, uint64_t address) 
{
    if(imageName == NULL){
        return (uint64_t)_dyld_get_image_vmaddr_slide(0) + address;
    }
    
	for(int i=0; i< _dyld_image_count(); i++){
		if(strstr(_dyld_get_image_name(i), imageName) != NULL){
			return (uint64_t)_dyld_get_image_vmaddr_slide(i) + address;
		}
	}
	NSLog(@"SMHookMemory:: Failed to find the address in the specified image");
	return 0;
}


// Hook an image at certain address with arm64 instruction
bool SMHookMemory(char *imageName, uint64_t addr, const char* inst)
{
	size_t size;
	unsigned char *patch = get_hex_from_instruction(inst, &size);
	if(patch == 0){
		NSLog(@"SMHookMemory:: Failed generating ARM64 instruction bytes");
		return false;
	}

	uint64_t address = real_address(imageName, addr);
	if(address == 0){
		return false;
	}

	MSHookMemory((void*)address, patch, size);

	return true;
}


// Testing only
void printRegisters(void)
{
    NSLog(@"[SMHookMemory] ctx x0  0x%llx", ctx.x0);
    NSLog(@"[SMHookMemory] ctx x1  0x%llx", ctx.x1);
    NSLog(@"[SMHookMemory] ctx x2  0x%llx", ctx.x2);
    NSLog(@"[SMHookMemory] ctx x3  0x%llx", ctx.x3);
    NSLog(@"[SMHookMemory] ctx x4  0x%llx", ctx.x4);
    NSLog(@"[SMHookMemory] ctx x5  0x%llx", ctx.x5);
    NSLog(@"[SMHookMemory] ctx x6  0x%llx", ctx.x6);
    NSLog(@"[SMHookMemory] ctx x7  0x%llx", ctx.x7);
    NSLog(@"[SMHookMemory] ctx x8  0x%llx", ctx.x8);
    NSLog(@"[SMHookMemory] ctx x9  0x%llx", ctx.x9);
    NSLog(@"[SMHookMemory] ctx x10 0x%llx", ctx.x10);
    NSLog(@"[SMHookMemory] ctx x11 0x%llx", ctx.x11);
    NSLog(@"[SMHookMemory] ctx x12 0x%llx", ctx.x12);
    NSLog(@"[SMHookMemory] ctx x13 0x%llx", ctx.x13);
    NSLog(@"[SMHookMemory] ctx x14 0x%llx", ctx.x14);
    NSLog(@"[SMHookMemory] ctx x15 0x%llx", ctx.x15);
    NSLog(@"[SMHookMemory] ctx x16 0x%llx", ctx.x16);
    NSLog(@"[SMHookMemory] ctx x17 0x%llx", ctx.x17);
    NSLog(@"[SMHookMemory] ctx x18 0x%llx", ctx.x18);
    NSLog(@"[SMHookMemory] ctx x19 0x%llx", ctx.x19);
    NSLog(@"[SMHookMemory] ctx x20 0x%llx", ctx.x20);
    NSLog(@"[SMHookMemory] ctx x21 0x%llx", ctx.x21);
    NSLog(@"[SMHookMemory] ctx x22 0x%llx", ctx.x22);
    NSLog(@"[SMHookMemory] ctx x23 0x%llx", ctx.x23);
    NSLog(@"[SMHookMemory] ctx x24 0x%llx", ctx.x24);
    NSLog(@"[SMHookMemory] ctx x25 0x%llx", ctx.x25);
    NSLog(@"[SMHookMemory] ctx x26 0x%llx", ctx.x26);
    NSLog(@"[SMHookMemory] ctx x27 0x%llx", ctx.x27);
    NSLog(@"[SMHookMemory] ctx x28 0x%llx", ctx.x28);
    NSLog(@"[SMHookMemory] ctx xlr 0x%llx", ctx.lr);
    NSLog(@"[SMHookMemory] ctx xfp 0x%llx", ctx.fp);
    return;
}



// Write the original instruction before the end of loadRegisters()
void prepareOrigInstr()
{
    uint64_t orig_instr_new_addr = (uint64_t)&loadRegisters + 0xFC;
    
    for(int i=0; i<trampoline_counter; i++){
        if(trampoline_list[i] == lr-4 || trampoline_list[i] == lr-12){
            
            uint32_t orig_instr = trampoline_orig_instr[i];
            
            uint8_t nop[] = {0x1F, 0x20, 0x03, 0xD5};
            
            if(orig_instr != 0){
                // long trampoline
                MSHookMemory((void*)orig_instr_new_addr, &orig_instr, sizeof(orig_instr));
                MSHookMemory((void*)orig_instr_new_addr+4, nop, sizeof(nop));
                MSHookMemory((void*)orig_instr_new_addr+8, nop, sizeof(nop));

            }else{
                // force trampoline
                uint32_t *orig_instr_force = (uint32_t*)trampoline_orig_instr_force[i];

                uint32_t patch1 = *(orig_instr_force+0);
                uint32_t patch2 = *(orig_instr_force+1);
                uint32_t patch3 = *(orig_instr_force+2);
                
                MSHookMemory((void*)orig_instr_new_addr, &patch1, sizeof(patch1));
                MSHookMemory((void*)orig_instr_new_addr+4, &patch2, sizeof(patch2));
                MSHookMemory((void*)orig_instr_new_addr+8, &patch3, sizeof(patch3));
            }
            return;
        }
    }
    __asm__("brk #0x1"); // fail
}

void build_long_trampoline(uint64_t orig, uint64_t dist)
{
    // NSLog(@"long trampoline from 0x%llx to 0x%llx", orig, dist);
    uint64_t target = dist;
    uint64_t pc = orig+8;
    
    uint64_t target_page   = (target & 0xFFFFF000);
    uint64_t pc_page       = (pc & 0xFFFFF000);
    uint64_t page_shift    = target_page - pc_page;
    uint64_t shift_remainder = target & 0x000000FFF;


    adrp(orig, page_shift);
    add(orig+4, shift_remainder);
    br(orig+8);
}

void build_long_trampoline_and_link(uint64_t orig, uint64_t dist)
{
    // NSLog(@"long trampoline from 0x%llx to 0x%llx", orig, dist);
    uint64_t target = dist;
    uint64_t pc = orig+8;
    
    // uint64_t addr_shift      = target - pc;
    // uint64_t page_shift      = addr_shift & 0xFFFFF000;
    // uint64_t shift_remainder = target & 0x00000FFF;
    
    uint64_t target_page   = (target & 0xFFFFF000);
    uint64_t pc_page       = (pc & 0xFFFFF000);
    uint64_t page_shift    = target_page - pc_page;
    uint64_t shift_remainder = target & 0x000000FFF;


    adrp(orig, page_shift);
    add(orig+4, shift_remainder);
    blr(orig+8);
}

uint64_t search_nearby_free_area(uint64_t addr)
{
    const struct mach_header_64 *mh = (const struct mach_header_64*)_dyld_get_image_header(0);
    const struct section_64 *text_section = getsectbynamefromheader_64(mh, "__TEXT", "__text");
    
    uint8_t *start_addr = (uint8_t *)((intptr_t)mh + text_section->offset);
    uint8_t *end_addr = (uint8_t *)(start_addr + text_section->size);
        
    uint8_t *current = (uint8_t*)addr;
    uint8_t target[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}; // 12 bytes - 3 arm instructions
    uint32_t target_len = sizeof(target);
    uint32_t index = 0;
    uint8_t current_target = 0;
	uint64_t up_size = 0;
	uint64_t down_size = 0;

	// Search up -- need to fix bl to lower addres 
    while (current > start_addr) {
        current_target = target[index];
        if(current_target == *current--)
		{
            index++;
        }else{
            index = 0;
        }
        if(index == target_len)
		{
            index = 0;
			// up_size = (uint64_t)addr - (uint64_t)current;
            // NSLog(@"found free space up at   0x%llx - distance:0x%llx", (uint64_t)current, up_size);
			break;
        }
	}
	// Search down
	current = (uint8_t*)addr; // reset
    while (current < end_addr) {
        current_target = target[index];
        if(current_target == *current++)
		{
            index++;
        }else{
            index = 0;
        }
        if(index == target_len)
		{
            down_size = ((uint64_t)current-target_len) - addr;
            // NSLog(@"found free space down at 0x%llx - distance:0x%llx", (uint64_t)current-target_len, down_size);
            index = 0;
			break;
        }
	}
    
    
	if(up_size != 0 && down_size != 0){
		if(up_size < down_size){
			return addr-up_size;
		}else{
			return addr+down_size;
		}
	}else if(up_size != 0){
		return addr-up_size;
	}else if(down_size != 0){
		return addr+down_size;
	}
	return 0; // means couldn't find nearby writable free chunk
}

bool is_same_memory_page(uint64_t addr1, uint64_t addr2)
{
    return ((addr1 & 0xfffff000) == (addr2 & 0xfffff000));
}

bool can_use_last_trmapoline_space(uint64_t addr)
{
    if(trampoline_counter < 1){
        return false;
    }
    
    uint64_t last_trampoline = trampoline_list[trampoline_counter-1];
    
    return is_same_memory_page(last_trampoline, addr);
}

void SMInstrument(char *imageName, uint64_t addr, void* handle)
{
    if(!trampoline_counter){
        trampoline_counter = 0;
    }

    uint64_t tramp_start_addr = addr + image_slide(imageName);
    uint64_t store_registers_addr = (uint64_t)&storeRegisters;
    uint32_t orig_instr = *(uint32_t*)tramp_start_addr;
    uint32_t orig_instr_force[3];
    bool isForceType = false;
        
    if((store_registers_addr - tramp_start_addr) < 0x2000000){ // 0x2,000,000 -> 32mb 
        
        bl(tramp_start_addr, store_registers_addr);
        NSLog(@"SMInstrument %d:: short trampoline at address:%p", trampoline_counter, (void*)tramp_start_addr);
    
    }else{
        uint64_t adrp_addr;
        
        if(can_use_last_trmapoline_space(tramp_start_addr)){
            adrp_addr = trampoline_empty_temp_space;
        }else{
            adrp_addr = search_nearby_free_area(tramp_start_addr);
        }
                
        if(adrp_addr != 0){
            trampoline_empty_temp_space = adrp_addr;
            bl(tramp_start_addr, adrp_addr);
            build_long_trampoline(adrp_addr, store_registers_addr);
            NSLog(@"SMInstrument %d:: long trampoline at address:%p", trampoline_counter, (void*)tramp_start_addr);
            
        }else{
            isForceType = true;
            NSLog(@"SMInstrument %d:: force trampoline at address:%p", trampoline_counter, (void*)tramp_start_addr);
            
            for(int i=0; i<3; i++){
                orig_instr_force[i] = *(uint32_t*)(tramp_start_addr+(i*4));
            }
            build_long_trampoline_and_link(tramp_start_addr, store_registers_addr);
        }
    }

    trampoline_list[trampoline_counter] = tramp_start_addr;
    
    if(isForceType == false){
       trampoline_orig_instr[trampoline_counter] = orig_instr;  
    
    }else{
        trampoline_orig_instr[trampoline_counter] = 0;  // assign to 0 and look into the other list
        
        for(int i=0; i<3; i++){
            trampoline_orig_instr_force[trampoline_counter][i] = orig_instr_force[i];
        }
    }
    
    trampoline_counter++;
    
    uint64_t bl_handle_addr = (uint64_t)&storeRegisters + 0x58;
    uint64_t handle_addr = (uint64_t)handle;
    bl(bl_handle_addr, handle_addr);
    
}

void SMInstrumentSVC80(char *imageName, void* handle)
{
    uint32_t image_index = 97271;
    
    if(imageName == NULL){
        image_index = 0;
    }else{
        for(int i=0; i<_dyld_image_count(); i++){
            if(strstr(_dyld_get_image_name(i), imageName) != NULL){
                image_index = i;
            }
        }
        
        if(image_index == 97271){
            NSLog(@"SMInstrumentSVC80:: Couldn't find the image");
            return;
        }
    }
    
    
    const struct mach_header_64 *mh = (const struct mach_header_64*)_dyld_get_image_header(image_index);
    const struct section_64 *text_section = getsectbynamefromheader_64(mh, "__TEXT", "__text");
    
    uint8_t *start_addr = (uint8_t *)((intptr_t)mh + text_section->offset);
    uint8_t *end_addr = (uint8_t *)(start_addr + text_section->size);
    
    
    uint8_t *current = start_addr;
    uint8_t target[] = {0x01, 0x10, 0x00, 0xD4};
    uint32_t target_len = sizeof(target);
    uint32_t index = 0;

    uint8_t current_target = 0;

    while (current < end_addr) {
        current_target = target[index];

        // Allow 0xFF as wildcard.
        if (current_target == *current++ || current_target == 0xFF) {
            index++;
        } else {
            index = 0;
        }

        // Check if match.
        if (index == target_len) {
            index = 0;
            uint64_t svc_addr = ((uint64_t)current - target_len) - image_slide(imageName); // get real address
            SMInstrument(imageName, svc_addr, handle); // SMInstrument Instrument real addresses only 
        }
    }
}

