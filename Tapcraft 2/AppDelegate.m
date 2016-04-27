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

@interface AppDelegate() <ChartboostDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // replace view for game dev
#ifdef GAME_DEV
    if(YES) {
        [_window setRootViewController:[[JetpackKnightViewController alloc] init]];
        return NO;
    }
#endif
    // Override point for customization after application launch.

    // Initialize the Chartboost library
    [Chartboost startWithAppId:@"5712cd0c43150f3600697abb"
                  appSignature:@"215d36f4b0a3b368323b3e6f6815c23e4d95cad7"
                      delegate:self];
    
    [self LoginToGameCenter_iOS_7_forth_way];
    return YES;
}

- (void) LoginToGameCenter_iOS_7_forth_way
{
    __weak typeof(self) weakSelf = self; // removes retain cycle error
    
    _localPlayer = [GKLocalPlayer localPlayer]; // localPlayer is the public GKLocalPlayer
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

-(void)showAuthenticationDialogWhenReasonable:(UIViewController *)controller
{
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:controller animated:YES completion:nil];
}

-(void)authenticatedPlayer:(GKLocalPlayer *)player
{
    player = _localPlayer;
}

-(void)disableGameCenter
{
    // optional!
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
   
    [Chartboost showInterstitial:CBLocationHomeScreen];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
