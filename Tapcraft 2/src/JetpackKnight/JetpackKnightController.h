//
//  JetpackKnightController.h
//  JetpackKnight
//
//  Created by Hossein Amin on 5/2/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JetpackKnightViewController.h"
#import "Game.h"
#import "GameNetworkProtocol.h"

@interface PlayerAction : NSObject

@property GNAction action;
@property JetpackKnightPlayer *player;

@end

@interface ActivityStep : NSObject

@property NSInteger timeStep;
@property NSMutableArray<PlayerAction*> *actions;

@end

@interface JetpackKnightController : NSObject

@property (weak) JetpackKnightGame *game;

@property NSMutableSet *postStepDestorySet;

// sorted with timeStep
@property NSMutableArray<ActivityStep*> *activities;

- (instancetype)initWithViewController:(JetpackKnightViewController*)viewController;

- (void)didReceivedActionMsg:(GNActionMsg*)actionMsg fromRemotePlayer:(GKPlayer*)gkPlayer;
- (void)displayPlayerStatus;

@property (weak)JetpackKnightViewController *viewController;
@property NSInteger playerIndex;
@property NSMutableDictionary<NSString *, JetpackKnightPlayer*> *playersById;


@end
