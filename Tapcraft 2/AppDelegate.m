//
//  AppDelegate.m
//  Tapcraft 2
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#import "AppDelegate.h"
#import <Chartboost/Chartboost.h>
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>
#import "JetpackKnightViewController.h"
#import "MenuViewController.h"
#import "ASScreenRecorder.h"



@interface AppDelegate() <ChartboostDelegate,GKLocalPlayerListener>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // replace view for game dev
#ifdef GAME_DEV
    if(YES) {
        [[ASScreenRecorder sharedInstance] startRecording];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        [_window setRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"JetpackKnightViewController"]];
        return NO;
    }
#endif
    // Override point for customization after application launch.

#ifdef APP_WITH_ADS
    // Initialize the Chartboost library
    [Chartboost startWithAppId:@"5712cd0c43150f3600697abb"
                  appSignature:@"215d36f4b0a3b368323b3e6f6815c23e4d95cad7"
                      delegate:self];
#endif
    
    [self LoginToGameCenter_iOS_7_forth_way];
    return YES;
}

- (void) LoginToGameCenter_iOS_7_forth_way
{
    __weak typeof(self) weakSelf = self; // removes retain cycle error
    
    _localPlayer = [GKLocalPlayer localPlayer]; // localPlayer is the public GKLocalPlayer
    
    [_localPlayer unregisterListener:self];
    [_localPlayer registerListener:self];
    
    __weak GKLocalPlayer *weakPlayer = _localPlayer; // removes retain cycle error
    weakPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if (viewController != nil)
        {
            [weakSelf showAuthenticationDialogWhenReasonable:viewController];
        }
        else if (weakPlayer.isAuthenticated)
        {
            [weakSelf authenticatedPlayer:weakPlayer];
        }
        else
        {
            [weakSelf disableGameCenter];
        }
    };
    
}

- (void)player:(GKPlayer *)player didAcceptInvite:(GKInvite *)invite {
    NSLog(@"player:didAcceptInvite:");
    MenuViewController *menuViewController = (id)[self activeViewController];
    if(![menuViewController isKindOfClass:[menuViewController class]])
        return;
    [menuViewController presentMatchmakerWithInvite:invite];
}

- (void)player:(GKPlayer *)player didRequestMatchWithRecipients:(NSArray<GKPlayer *> *)recipientPlayers {
    NSLog(@"player:didRequestMatchWithRecipients:");
}

-(void)showAuthenticationDialogWhenReasonable:(UIViewController *)controller
{
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:controller animated:YES completion:nil];
}

-(void)authenticatedPlayer:(GKLocalPlayer *)player
{
    // ready to start a match
    MenuViewController *mvc = (MenuViewController*)self.window.rootViewController;
    mvc.matchMakerButton.hidden = NO;
}

-(void)disableGameCenter
{
    // optional!
    // remove match making button
    MenuViewController *mvc = (MenuViewController*)self.window.rootViewController;
    mvc.matchMakerButton.hidden = YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
#ifdef APP_WITH_ADS
    [Chartboost showInterstitial:CBLocationHomeScreen];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (AppDelegate*)sharedInstance {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma - mark helpers

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    [self showAlertWithTitle:title message:message completion:nil];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message completion:(void(^)())completion {
    completion = [completion copy];
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if(completion)
                                       completion();
                               }];
    [alertCtr addAction:okAction];
    [self presentAlertController:alertCtr];
}

- (void)showRetryAlertWithTitle:(NSString*)title message:(NSString*)message close:(void(^)())close retry:(void(^)())retry {
    close = [close copy];
    retry = [retry copy];
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Close", @"Close action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if(close)
                                       close();
                               }];
    [alertCtr addAction:okAction];
    UIAlertAction *retryAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Retry", @"retry action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      if(retry)
                                          retry();
                                  }];
    [alertCtr addAction:retryAction];
    [self presentAlertController:alertCtr];
}

- (void)presentAlertController:(UIAlertController*)alertController
{
    UIViewController *vc = [self activeViewController];
    if([vc isBeingDismissed] || [vc isBeingPresented]) {
        // wait for presenting
        NSMethodSignature *sig = [self methodSignatureForSelector:@selector(presentAlertController:)];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:self];
        [inv setSelector:@selector(presentAlertController:)];
        [inv setArgument:&alertController atIndex:2];
        [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.2 invocation:inv repeats:NO] forMode:NSDefaultRunLoopMode];
        return;
    }
    [vc presentViewController:alertController animated:YES completion:nil];
}

- (UIViewController*)activeViewController {
    UIViewController *viewController = [self.window rootViewController];
    while(viewController.presentedViewController != nil)
        viewController = viewController.presentedViewController;
    return viewController;
}

@end
