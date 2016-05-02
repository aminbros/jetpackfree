//
//  JetpackKnightPlayer.h
//  JetpackKnight
//
//  Created by Hossein Amin on 5/2/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Character.h"

@interface JetpackKnightPlayer : NSObject

@property Character *character;

// simulation variables
@property BOOL hasRocket;
@property BOOL rocketEngineOn;
@property BOOL touchedGround;
@property NSMutableArray *touchedGrounds;
@property NSInteger numberOfJumpOnAir;
@property NSInteger collectedGems;
@property CGFloat jumpForce;
@property NSTimeInterval jumpForceTime;

@end
