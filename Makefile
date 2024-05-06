TARGET = iphone:latest:12.0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ClassicFolders3
ClassicFolders3_FILES = iOS13.x CSClassicFolderView.x UIImage+ClassicFolders.m CSClassicFolderSettingsManager.m CSClassicFolderTextField.m iOS10BlurRemoval.x BackgroundBlur.x RootFolderBugFix.x Icon.x IconListViewBugFix.x 
#ClassicFolders3_FILES += ForceBinds.x
ClassicFolders3_CFLAGS = -Iinclude -include sha1.pch -include DRM.pch
#ClassicFolders3_CFLAGS = -include DRM-dummy.pch
#ClassicFolders3_OBJ_FILES = libcrypto.a
ClassicFolders3_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += classicfolderssettings
include $(THEOS_MAKE_PATH)/aggregate.mk
