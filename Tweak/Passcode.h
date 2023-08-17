//
//  Passcode.h
//  HoYosphere
//
//  Created by Alexandra Aurora Göttlicher (hello@traurige.dev)
//

#import "Common.h"

NSUserDefaults* preferences;
BOOL pfEnabled;
NSString* pfStyle;

@interface SBUIPasscodeLockNumberPad : UIView
@property(nonatomic, readonly)NSArray* buttons;
@end

@interface TPNumberPadButton : UIControl
@property(retain)UIView* circleView;
@property(assign)long long character;
@end

@interface TPNumberPadDarkStyleButton : TPNumberPadButton
@end

@interface SBPasscodeNumberPadButton : TPNumberPadDarkStyleButton
@end
