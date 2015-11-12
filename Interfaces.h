@interface UIApplication (Private)
    - (void)launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end

@interface BBAction : NSObject
    + (id)action;
    + (id)actionWithLaunchURL:(id)url;
    + (id)actionWithLaunchBundleID:(id)bundleID;
@end

@interface BBBulletin
    @property(copy, nonatomic) NSString *sectionID;
    @property(copy, nonatomic) NSString *title;
    @property(copy, nonatomic) NSString *message;
    @property(copy, nonatomic) BBAction *defaultAction;
    @property(retain, nonatomic) NSDate *date;
    @property(copy, nonatomic) NSString *bulletinID;
    @property(retain, nonatomic) NSDate *publicationDate;
    @property(retain, nonatomic) NSDate *lastInterruptDate;
@end

@interface BBBulletinRequest : BBBulletin

@end

@interface SBBannerController : NSObject
    + (id)sharedInstance;
    - (void)_presentBannerView:(id)view;
    - (void)observer:(id)observer addBulletin:(id)bulletin forFeed:(NSInteger)feed;
    - (void)observer:(id)observer addBulletin:(id)bulletin forFeed:(NSInteger)feed playLightsAndSirens:(BOOL)truth withReply:(id)reply;
@end

@interface IMChat : NSObject
    @property (nonatomic, readonly) NSString *chatIdentifier;
@end

@interface CKComposition : NSObject
    - (BOOL)hasNonwhiteSpaceContent;
    @property (nonatomic, copy) NSAttributedString *text;
@end

@interface CKConversation : NSObject
    - (id)name;
    - (IMChat *)chat;
@end

@interface CKMessageEntryView : UIView

@end

@interface CKTranscriptController : UIViewController
    - (BOOL)hasText;
    - (void)clearComposition;
    - (BOOL)isEditable;
    - (CKComposition *)composition;
    - (CKConversation *)conversation;
    - (void)addNewNotification:(NSArray*)array;
    - (void)studyTextExistence;
@end

@interface CKConversationList
    - (void)deleteConversation:(CKConversation *)arg1;
    - (void)deleteConversations:(NSArray*)arg1;
@end

@interface SBBannerContainerViewController : NSObject
    -(BBBulletinRequest*)_bulletin;
@end
