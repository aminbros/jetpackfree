//
//  AppDelegate.h
//  Tapcraft 2
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property ( strong , nonatomic) GKLocalPlayer *localPlayer;
@end
