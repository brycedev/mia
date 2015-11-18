#import "Global.h"
#include "MiaHeaderCell.h"

@implementation MiaHeaderCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
        if (self) {

            CGFloat width = [[UIScreen mainScreen] bounds].size.width;

            NSBundle *bundle = [[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/com.brycedev.mia.bundle"] autorelease];
            NSString *path = [bundle pathForResource:@"header" ofType:@"jpg"];
            UIImage *image = [UIImage imageWithContentsOfFile:path];

            UIImageView *iv = [[UIImageView alloc] initWithFrame: CGRectMake(0,0, width, 150)];
            [iv setContentMode: UIViewContentModeScaleAspectFill];
            [iv setImage: image];

            [self addSubview: iv];
        }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    return 150.0f;
}

@end
