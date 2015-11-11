@interface BDSettingsManager : NSObject

@property (nonatomic, copy) NSDictionary *settings;

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, copy) NSMutableDictionary *notifications;

+ (instancetype)sharedManager;
- (void)updateSettings;

@end
