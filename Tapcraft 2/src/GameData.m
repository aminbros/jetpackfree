/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameData.h"
#import "GameSimulator.h"

@implementation GameData


-(id)copyWithZone:(NSZone *)zone
{
    GameData *i = [[[self class] alloc] init];
    i.simulatorConfig = [_simulatorConfig copyWithZone:zone];
    i.objects = _objects;
    i.characters = _characters;
    i.positionZs = _positionZs;
    i.runningSpeed = _runningSpeed;
    i.runningSpeedUpStep = _runningSpeedUpStep;
    i.runningSpeedUpEvery = _runningSpeedUpEvery;
    i.gameBound = _gameBound;
    i.clearRectColor = _clearRectColor;
    i.backgroundImage = _backgroundImage;
    i.initialCamera = _initialCamera;
    return i;
}

@end
