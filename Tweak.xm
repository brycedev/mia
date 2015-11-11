#import "Interfaces.h"
#import "BDSettingsManager.h"

static BOOL enabled = YES;
static NSString *title = @"MiaAssistant";

@interface AppDelegate: UIResponder

@end

%hook Springboard

-(void)_didSuspend {
	HBLogInfo(@"the application is : %@", self);
    %orig;
}

%end
/*
%hook UIApplication

- (void)systemApplicationDidSuspend {
	HBLogInfo(@"application did suspend");
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.brycedev.mia.center.appsuspend"), nil, nil, YES);
    %orig;
}

%end
*/
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

static void cookNotifications(){
	HBLogInfo(@"cooking notifications");
    NSMutableDictionary *notesDict = [[BDSettingsManager sharedManager] notifications];

    if ( (!([notesDict count] == 0)) && enabled) {
        id request = [[[%c(BBBulletinRequest) alloc] init] autorelease];
        [request setTitle: title];
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
        [request setSectionID: @"com.apple.MobileSMS"];
        id ctrl = [%c(SBBulletinBannerController) sharedInstance];
        if([ctrl respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
            [ctrl observer:nil addBulletin:request forFeed:2 playLightsAndSirens:YES withReply:nil];
        } else {
            [ctrl observer:nil addBulletin:request forFeed:2];
        }
    }
}


static void testBanner(){
	HBLogInfo(@"testing banner");
    id request = [[[%c(BBBulletinRequest) alloc] init] autorelease];
    [request setTitle: title];
    NSArray *testNames = [@[ @"Tim Cook", @"Jay Freeman", @"Morgan Freeman", @"Steve Carell", @"Oliver Queen", @"Oprah Winfrey" ] retain];
    [request setMessage:[NSString stringWithFormat: @"You forgot to send your message to %@", [testNames objectAtIndex: arc4random() % [testNames count]]]];
    [request setDefaultAction: [%c(BBAction) actionWithLaunchBundleID: @"com.apple.MobileSMS"]];
    [request setSectionID: @"com.apple.MobileSMS"];
    id ctrl = [%c(SBBulletinBannerController) sharedInstance];
    if([ctrl respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
        [ctrl observer:nil addBulletin:request forFeed:2 playLightsAndSirens:YES withReply:nil];
    } else {
        [ctrl observer:nil addBulletin:request forFeed:2];
    }
}

%ctor{
	system("open /Applications/MobileSMS.app");
	[BDSettingsManager sharedManager];
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, (CFNotificationCallback)cookNotifications, CFSTR("com.brycedev.mia.center.appsuspend"), NULL, 0);
    CFNotificationCenterAddObserver(r, NULL, (CFNotificationCallback)testBanner, CFSTR("com.brycedev.mia.testbanner"), NULL, 0);

}
