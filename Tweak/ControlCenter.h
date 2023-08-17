//
//  ControlCenter.h
//  HoYosphere
//
//  Created by Alexandra Aurora Göttlicher (hello@traurige.dev)
//

#import "Common.h"

static UIImage* resizedImageWithName(NSString* name);

NSDictionary* colors;

NSUserDefaults* preferences;
BOOL pfEnabled;
NSString* pfStyle;

@interface CCUIRoundButton : UIControl
@property(nonatomic, retain)UIImage* glyphImage;
@property(nonatomic, retain)UIView* selectedStateBackgroundView;
- (id)_viewControllerForAncestor;
@end

@interface CCUICAPackageDescription : NSObject
@property(nonatomic, copy, readonly)NSURL* packageURL;
+ (id)initWithPackageName:(NSString *)name inBundle:(NSBundle *)bundle;
@end
