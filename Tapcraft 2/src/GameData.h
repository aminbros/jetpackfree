/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Object.h"
#import "Bound.h"

@class GameSimulatorConfig;

@interface GameData : NSObject

@property NSArray *objects;
@property NSArray *characters;
@property NSArray *positionZs; // list of positionZ available

@property UIColor *clearRectColor;
@property UIImage *backgroundImage; // backgroud image

@property CGFloat runningSpeed;
@property CGFloat runningSpeedUpStep;
@property CGFloat runningSpeedUpEvery;

@property GameSimulatorConfig *simulatorConfig;

@property Bound gameBound;

@property Camera initialCamera;

-(id)copyWithZone:(NSZone *)zone;

@end
