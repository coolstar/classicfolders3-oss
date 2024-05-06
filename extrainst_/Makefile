GO_EASY_ON_ME=1
ARCHS = armv7 arm64
include $(THEOS)/makefiles/common.mk

TOOL_NAME = extrainst_
extrainst__FILES = Installer.mm partial.c
extrainst__CFLAGS = -I.
extrainst__OBJ_FILES = libcurl.a
extrainst__LDFLAGS = -lz
extrainst__FRAMEWORKS = UIKit Security
extrainst__INSTALL_PATH = /DEBIAN/
extrainst__CODESIGN_FLAGS=-SEnt.plist

include $(THEOS_MAKE_PATH)/tool.mk
