//
//  JetpackKnightGame.h
//  JetpackKnight
//
//  Created by Hossein Amin on 5/2/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import "Game.h"
#import "JetpackKnightGameData.h"
#import "JetpackKnightPlayer.h"

@interface JetpackKnightGame : Game

@property (nonatomic,weak) JetpackKnightGameData *jGameData;
@property NSArray *players;

@end
