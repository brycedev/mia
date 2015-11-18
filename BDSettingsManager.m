#import "BDSettingsManager.h"

@implementation BDSettingsManager

+ (instancetype)sharedManager {
    static dispatch_once_t p = 0;
    __strong static id _sharedSelf = nil;
    dispatch_once(&p, ^{
        _sharedSelf = [[self alloc] init];
    });
    return _sharedSelf;
}

void prefschanged(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    [[BDSettingsManager sharedManager] updateSettings];
}

- (id)init {
    if (self = [super init]) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, prefschanged, CFSTR("com.brycedev.mia.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        [self updateSettings];
    }
    return self;
}

- (void)updateSettings {
    self.settings = nil;
    CFPreferencesAppSynchronize(CFSTR("com.brycedev.mia"));
    CFStringRef appID = CFSTR("com.brycedev.mia");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
    self.settings = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFRelease(keyList);
    //HBLogInfo(@"the settings for mia are : %@", self.settings);
}

- (BOOL)enabled {
    return self.settings[@"enabled"] ? [self.settings[@"enabled"] boolValue] : YES;
}

- (NSMutableDictionary *)notifications {
    return self.settings[@"notifications"] ? [self.settings[@"notifications"] mutableCopy] : [NSMutableDictionary new];
}

- (void)setNotifications:(NSMutableDictionary*)notifications {
    CFStringRef appID = CFSTR("com.brycedev.mia");
    CFPreferencesSetValue(CFSTR("notifications"), (CFPropertyListRef *)notifications, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    [self updateSettings];
}

@end
