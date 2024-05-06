ARCHS = armv7 arm64
include $(THEOS)/makefiles/common.mk

TOOL_NAME = prerm
prerm_FILES = Remover.mm
prerm_FRAMEWORKS = UIKit Foundation
prerm_INSTALL_PATH = /DEBIAN/
prerm_CODESIGN_FLAGS=-SEnt.plist

include $(THEOS_MAKE_PATH)/tool.mk
