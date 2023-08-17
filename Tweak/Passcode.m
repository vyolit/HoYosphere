//
//  Passcode.m
//  HoYosphere
//
//  Created by Alexandra Aurora Göttlicher (hello@traurige.dev)
//

#import "Passcode.h"

#pragma mark - SBUIPasscodeLockNumberPad class hooks

static void (* orig_SBUIPasscodeLockNumberPad_didMoveToWindow)(SBUIPasscodeLockNumberPad* self, SEL _cmd);
static void override_SBUIPasscodeLockNumberPad_didMoveToWindow(SBUIPasscodeLockNumberPad* self, SEL _cmd) {
    orig_SBUIPasscodeLockNumberPad_didMoveToWindow(self, _cmd);

    for (SBPasscodeNumberPadButton* button in [self buttons]) {
        if ([button character] < 0 || [button character] > 10) {
            continue;
        }

        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/Passcode/%lld.png", kDocumentPath, pfStyle, [button character]]]];
        [imageView setFrame:[[button circleView] frame]];
        [[[button circleView] superview] addSubview:imageView];
    }
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

    MSHookMessageEx(objc_getClass("SBUIPasscodeLockNumberPad"), @selector(didMoveToWindow), (IMP)override_SBUIPasscodeLockNumberPad_didMoveToWindow, (IMP *)&orig_SBUIPasscodeLockNumberPad_didMoveToWindow);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
