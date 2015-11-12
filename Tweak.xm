#import "Interfaces.h"
#import "BDSettingsManager.h"

%hook SMSApplication

- (void)systemApplicationDidSuspend {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.brycedev.mia.center.appsuspend"), nil, nil, YES);
    return %orig;
}

%end

%hook CKTranscriptController

- (void)viewDidLoad {
	%orig;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(studyTextExistence)
                                          name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)messageEntryViewDidBeginEditing:(CKMessageEntryView *)view {
    CKConversation *convo = [self conversation];
    IMChat *chat = [convo chat];

    NSMutableDictionary *notesDict = [[BDSettingsManager sharedManager] notifications];

    if (!([notesDict count] == 0)) {
        if ([notesDict objectForKey:chat.chatIdentifier]) {
            [notesDict removeObjectForKey:chat.chatIdentifier];
            [[BDSettingsManager sharedManager] setNotifications: notesDict];
        }
    }
    %orig;
}

- (void)viewDidDisappear:(BOOL)truth {
    [self studyTextExistence];
	%orig;
}

%new
- (void)studyTextExistence {
    CKComposition *comp = [self composition];
    CKConversation *convo = [self conversation];
    IMChat *chat = [convo chat];

    if([comp hasNonwhiteSpaceContent]){
        NSArray *convoInfo = @[convo.name, chat.chatIdentifier];
        [self addNewNotification: convoInfo];
    }else {
        NSMutableDictionary *notesDict = [[BDSettingsManager sharedManager] notifications];
        if (!([notesDict count] == 0)) {
            if ([notesDict objectForKey: chat.chatIdentifier]) {
                [notesDict removeObjectForKey: chat.chatIdentifier];
                [[BDSettingsManager sharedManager] setNotifications: notesDict];
            }
        }
    }
}

%new
- (void)addNewNotification:(NSArray*)array {
	HBLogInfo(@"adding new notification");
    NSMutableDictionary *notesDict = [[BDSettingsManager sharedManager] notifications];
    [notesDict setObject: [array objectAtIndex:0] forKey: [array objectAtIndex:1]];
    [[BDSettingsManager sharedManager] setNotifications: notesDict];
}

%end

%hook CKConversationList

- (void)deleteConversation:(CKConversation *)conversation {
    IMChat *chat = [conversation chat];

    NSMutableDictionary *notesDict = [[BDSettingsManager sharedManager] notifications];

    if (!([notesDict count] == 0)) {
        if ([notesDict objectForKey: chat.chatIdentifier]) {
            [notesDict removeObjectForKey: chat.chatIdentifier];
            [[BDSettingsManager sharedManager] setNotifications: notesDict];
         }
    }

    %orig;
}

- (void)deleteConversations:(NSArray*)array {
    NSMutableDictionary *notesDict = [[BDSettingsManager sharedManager] notifications];

    for (CKConversation * convo in array){
        if (!([notesDict count] == 0)) {
			IMChat *chat = [convo chat];
            if ([notesDict objectForKey: chat.chatIdentifier]) {
                [notesDict removeObjectForKey: chat.chatIdentifier];
                [[BDSettingsManager sharedManager] setNotifications: notesDict];
            }
        }
    }

    %orig;
}

%end

%hook SBBannerContainerViewController

-(void)_handleBannerTapGesture:(id)gesture withActionContext:(id)context {
	HBLogInfo(@"handling banner tap");
    //Prevents ios9 crash when tapping banner
    //https://github.com/fewjative/PowerBanners
	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
		if( [[[self _bulletin] sectionID] isEqualToString:@"com.brycedev.mia"] ){
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"sms://" stringByAppendingString:user]]];
			HBLogInfo(@"the context : %@", context);
			return;
		}else{
			%orig;
		}
	}
	else{
		%orig;
	}

}

%end

static void cookNotifications(){
	[[BDSettingsManager sharedManager] updateSettings];
	NSMutableDictionary *notesDict = [[BDSettingsManager sharedManager] notifications];
	HBLogInfo(@"getting the notifications : %@", notesDict);
    if ( (!([notesDict count] == 0)) && [[BDSettingsManager sharedManager] enabled]) {
		HBLogInfo(@"cooking notifications");
        id request = [[[%c(BBBulletinRequest) alloc] init] autorelease];
        [request setTitle: @"MiaAssistant"];
        if([notesDict count] == 1){
            [request setMessage:[NSString stringWithFormat:@"You forgot to send your message to %@", [notesDict objectForKey: [[notesDict allKeys] objectAtIndex:0]]]];
            [request setDefaultAction: [%c(BBAction) actionWithLaunchURL: [NSURL URLWithString: [NSString stringWithFormat:@"sms:%@", [[notesDict allKeys] objectAtIndex:0]]]]];
        }else if([notesDict count] == 2){
            NSString * people = [[notesDict allValues] componentsJoinedByString:@" and "];
            [request setMessage:[NSString stringWithFormat:@"You forgot to send your messages to : %@", people]];
            [request setDefaultAction: [%c(BBAction) actionWithLaunchBundleID:@"com.apple.MobileSMS"]];
        }else {
            NSString * people = [[notesDict allValues] componentsJoinedByString:@", "];
            [request setMessage:[NSString stringWithFormat:@"You forgot to send your messages to : %@", people]];
            [request setDefaultAction: [%c(BBAction) actionWithLaunchBundleID:@"com.apple.MobileSMS"]];
        }
		if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
			[request setSectionID: @"com.brycedev.mia"];
		}else{
			[request setSectionID: @"com.apple.MobileSMS"];
		}
        id ctrl = [%c(SBBulletinBannerController) sharedInstance];
        if([ctrl respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
            [ctrl observer:nil addBulletin:request forFeed:2 playLightsAndSirens:YES withReply:nil];
        } else {
            [ctrl observer:nil addBulletin:request forFeed:2];
        }
    }
}


static void testBanner(){
    id request = [[[%c(BBBulletinRequest) alloc] init] autorelease];
    [request setTitle: @"MiaAssistant"];
    NSArray *testNames = [@[ @"Tim Cook", @"Jay Freeman", @"Morgan Freeman", @"Steve Carell", @"Oliver Queen", @"Oprah Winfrey" ] retain];
    [request setMessage:[NSString stringWithFormat: @"You forgot to send your message to %@", [testNames objectAtIndex: arc4random() % [testNames count]]]];
    [request setDefaultAction: [%c(BBAction) actionWithLaunchBundleID: @"com.apple.MobileSMS"]];
	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0){
		[request setSectionID: @"com.brycedev.mia"];
	}else{
		[request setSectionID: @"com.apple.MobileSMS"];
	}
    id ctrl = [%c(SBBulletinBannerController) sharedInstance];
    if([ctrl respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
        [ctrl observer:nil addBulletin:request forFeed:2 playLightsAndSirens:YES withReply:nil];
    } else {
        [ctrl observer:nil addBulletin:request forFeed:2];
    }
}

%ctor{
	[BDSettingsManager sharedManager];
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, (CFNotificationCallback)cookNotifications, CFSTR("com.brycedev.mia.center.appsuspend"), NULL, 0);
    CFNotificationCenterAddObserver(r, NULL, (CFNotificationCallback)testBanner, CFSTR("com.brycedev.mia.testbanner"), NULL, 0);

}
