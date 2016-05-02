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

@interface JetpackKnightController : NSObject

@property (weak) JetpackKnightGame *game;

@property NSMutableSet *postStepDestorySet;

- (instancetype)initWithViewController:(JetpackKnightViewController*)viewController;

@property (weak)JetpackKnightViewController *viewController;
@property NSInteger playerIndex;


@end
