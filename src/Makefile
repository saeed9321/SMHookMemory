ARCHS := arm64 arm64e
TARGET = iphone::14.4:14.4
THEOS_DEVICE_IP = 127.0.0.1 
THEOS_DEVICE_PORT = 2222
GO_EASY_ON_ME = 1
FINALPACKAGE = 1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SMHookMemory

$(LIBRARY_NAME)_FILES = SMHookMemory.m
$(LIBRARY_NAME)_FILES += arm64-trampoline.m
$(LIBRARY_NAME)_FILES += arm64-instruction.m

$(LIBRARY_NAME)_CFLAGS = -fobjc-arc
$(LIBRARY_NAME)_INSTALL_PATH = /usr/lib
$(LIBRARY_NAME)_LDFLAGS = -lkeystone -lsubstrate

include $(THEOS_MAKE_PATH)/library.mk
