//
//  AppDelegate.h
//  Tapcraft 2
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

// #define GAME_DEV
// #define APP_WITH_ADS

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property ( strong , nonatomic) GKLocalPlayer *localPlayer;

+ (AppDelegate*)sharedInstance;

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message;
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message completion:(void(^)())completion;
- (void)showRetryAlertWithTitle:(NSString*)title message:(NSString*)message close:(void(^)())close retry:(void(^)())retry;
- (void)presentAlertController:(UIAlertController*)alertController;
- (UIViewController*)activeViewController;

@end
