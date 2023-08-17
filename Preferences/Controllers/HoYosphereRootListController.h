//
//  HoYosphereRootListController.h
//  HoYosphere
//
//  Created by Alexandra Aurora Göttlicher (hello@traurige.dev)
//

#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <rootless.h>
#import "../PreferenceKeys.h"
#import "../NotificationKeys.h"

@interface HoYosphereRootListController : PSListController
@end

@interface NSTask : NSObject
@property(copy)NSArray* arguments;
@property(copy)NSString* launchPath;
- (void)launch;
@end
