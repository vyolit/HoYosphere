//
//  Time.m
//  HoYosphere
//
//  Created by Alexandra Aurora Göttlicher (hello@traurige.dev)
//

#import "Time.h"

#pragma mark - SBFLockScreenDateView class hooks

static UIFont* (* orig_SBFLockScreenDateView_timeFont)(SBFLockScreenDateView* self, SEL _cmd);
static UIFont* override_SBFLockScreenDateView_timeFont(SBFLockScreenDateView* self, SEL _cmd) {
    return [UIFont fontWithName:fontName size:[orig_SBFLockScreenDateView_timeFont(self, _cmd) pointSize]];
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

    NSData* fontData;
    if ([pfStyle isEqualToString:kPreferenceKeyStyleGenshinImpact]) {
        fontData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[kDocumentPath stringByAppendingString:@"/Genshin Impact/Time/HYWenHei.ttf"]]];
        fontName = @"HYWenHei 85W";
    } else {
        fontData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[kDocumentPath stringByAppendingString:@"/HSR/Time/DIN.ttf"]]];
        fontName = @"DIN";
    }

    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);

    MSHookMessageEx(object_getClass(objc_getClass("SBFLockScreenDateView")), @selector(timeFont), (IMP)&override_SBFLockScreenDateView_timeFont, (IMP *)&orig_SBFLockScreenDateView_timeFont);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
