include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Mia
Mia_FILES = BDSettingsManager.m Tweak.xm
Mia_Frameworks = Foundation UIKit
Mia_PRIVATE_FRAMEWORKS = BulletinBoard ChatKit IMCore

before-stage::
	find . -name ".DS_STORE" -delete

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSMS; killall -9 Preferences; killall -9 SpringBoard;"
SUBPROJECTS += mia
include $(THEOS_MAKE_PATH)/aggregate.mk
