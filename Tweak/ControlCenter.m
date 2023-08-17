//
//  ControlCenter.m
//  HoYosphere
//
//  Created by Alexandra Aurora Göttlicher (hello@traurige.dev)
//

#import "ControlCenter.h"

#pragma mark - CCUIRoundButton class hooks

static void (* orig_CCUIRoundButton_didMoveToWindow)(CCUIRoundButton* self, SEL _cmd);
static void override_CCUIRoundButton_didMoveToWindow(CCUIRoundButton* self, SEL _cmd) {
    orig_CCUIRoundButton_didMoveToWindow(self, _cmd);

    UIViewController* ancestor = [self _viewControllerForAncestor];
    if ([ancestor isKindOfClass:objc_getClass("CCUIConnectivityAirplaneViewController")]) {
        [self setGlyphImage:resizedImageWithName(@"Airplane")];
        [[self selectedStateBackgroundView] setBackgroundColor:colors[@"Airplane"]];
	} else if ([ancestor isKindOfClass:objc_getClass("CCUIConnectivityCellularDataViewController")]) {
        [self setGlyphImage:resizedImageWithName(@"Cellular")];
        [[self selectedStateBackgroundView] setBackgroundColor:colors[@"Cellular"]];
    } else if ([ancestor isKindOfClass:objc_getClass("CCUIConnectivityWifiViewController")]) {
        [[self selectedStateBackgroundView] setBackgroundColor:colors[@"WiFi"]];
    } else if ([ancestor isKindOfClass:objc_getClass("CCUIConnectivityBluetoothViewController")]) {
        [[self selectedStateBackgroundView] setBackgroundColor:colors[@"Bluetooth"]];
    } else if ([ancestor isKindOfClass:objc_getClass("CCUIConnectivityAirDropViewController")]) {
        [self setGlyphImage:resizedImageWithName(@"AirDrop")];
        [[self selectedStateBackgroundView] setBackgroundColor:colors[@"AirDrop"]];
    } else if ([ancestor isKindOfClass:objc_getClass("CCUIConnectivityHotspotViewController")]) {
        [self setGlyphImage:resizedImageWithName(@"Hotspot")];
        [[self selectedStateBackgroundView] setBackgroundColor:colors[@"Hotspot"]];
    }
}

static UIImage* resizedImageWithName(NSString* name) {
    UIImage* icon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/Control Center/%@.png", kDocumentPath, pfStyle, name]];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0);
    [icon drawInRect:CGRectMake(0, 0, 30, 30)];
    icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return icon;
}

// mildly cursed way to fix the wifi and bluetooth toggle colors after light/dark mode change
// but hey, this whole feature should be banned to the shadow realm anyway
static void (* orig_CCUIRoundButton_traitCollectionDidChange)(CCUIRoundButton* self, SEL _cmd, UITraitCollection* previousTraitCollection);
static void override_CCUIRoundButton_traitCollectionDidChange(CCUIRoundButton* self, SEL _cmd, UITraitCollection* previousTraitCollection) {
    orig_CCUIRoundButton_traitCollectionDidChange(self, _cmd, previousTraitCollection);

    if ([[self traitCollection] userInterfaceStyle] != [previousTraitCollection userInterfaceStyle]) {
        [self didMoveToWindow];
    }
}

// the wifi and bluetooth toggles are turbo ass
static CCUIRoundButton* (* orig_CCUIRoundButton_initWithGlyphPackageDescription_highlightColor_useLightStyle)(CCUIRoundButton* self, SEL _cmd, CCUICAPackageDescription* glyphPackageDescription, UIColor* highlightColor, BOOL useLightStyle);
static CCUIRoundButton* override_CCUIRoundButton_initWithGlyphPackageDescription_highlightColor_useLightStyle(CCUIRoundButton* self, SEL _cmd, CCUICAPackageDescription* glyphPackageDescription, UIColor* highlightColor, BOOL useLightStyle) {
    NSString* name = [[[glyphPackageDescription packageURL] lastPathComponent] stringByDeletingPathExtension];
    if ([@[@"WiFi", @"Bluetooth"] containsObject:name]) {
        glyphPackageDescription = [[objc_getClass("CCUICAPackageDescription") alloc] initWithPackageName:name inBundle:[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@/Control Center/ConnectivityModule.bundle", kDocumentPath, pfStyle]]];
    }
    return orig_CCUIRoundButton_initWithGlyphPackageDescription_highlightColor_useLightStyle(self, _cmd, glyphPackageDescription, highlightColor, useLightStyle);
}

#pragma mark - Preferences

static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue),
        kPreferenceKeyStyle: kPreferenceKeyStyleDefaultValue
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
    pfStyle = [preferences objectForKey:kPreferenceKeyStyle];
}

#pragma mark - Constructor

__attribute((constructor)) static void initialize() {
    load_preferences();

    if (!pfEnabled) {
        return;
    }

    if ([pfStyle isEqualToString:kPreferenceKeyStyleGenshinImpact]) {
        colors = @{
            @"Airplane": [UIColor colorWithRed:0.65 green:0.35 blue:0.78 alpha:1],
            @"Cellular": [UIColor colorWithRed:0.44 green:0.88 blue:0.76 alpha:1],
            @"WiFi": [UIColor colorWithRed:0.88 green:0.7 blue:0.25 alpha:1],
            @"Bluetooth": [UIColor colorWithRed:0.6 green:0.9 blue:0.87 alpha:1],
            @"AirDrop": [UIColor colorWithRed:0.13 green:0.88 blue:0.91 alpha:1],
            @"Hotspot": [UIColor colorWithRed:1 green:0.56 blue:0.36 alpha:1]
        };
    } else {
        colors = @{
            @"Airplane": [UIColor colorWithRed:0.83 green:0.37 blue:0.89 alpha:1],
            @"Cellular": [UIColor colorWithRed:0.57 green:0.57 blue:0.57 alpha:1],
            @"WiFi": [UIColor colorWithRed:0.32 green:0.28 blue:0.76 alpha:1],
            @"Bluetooth": [UIColor colorWithRed:0.02 green:0.58 blue:0.85 alpha:1],
            @"AirDrop": [UIColor colorWithRed:0 green:0.82 blue:0.6 alpha:1],
            @"Hotspot": [UIColor colorWithRed:1 green:0.25 blue:0.21 alpha:1]
        };
    }

    MSHookMessageEx(objc_getClass("CCUIRoundButton"), @selector(didMoveToWindow), (IMP)override_CCUIRoundButton_didMoveToWindow, (IMP *)&orig_CCUIRoundButton_didMoveToWindow);
    MSHookMessageEx(objc_getClass("CCUIRoundButton"), @selector(traitCollectionDidChange:), (IMP)override_CCUIRoundButton_traitCollectionDidChange, (IMP *)&orig_CCUIRoundButton_traitCollectionDidChange);
    MSHookMessageEx(objc_getClass("CCUIRoundButton"), @selector(initWithGlyphPackageDescription:highlightColor:useLightStyle:), (IMP)override_CCUIRoundButton_initWithGlyphPackageDescription_highlightColor_useLightStyle, (IMP *)&orig_CCUIRoundButton_initWithGlyphPackageDescription_highlightColor_useLightStyle);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
