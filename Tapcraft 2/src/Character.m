/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Character.h"

@implementation Character

- (CGPoint)applicableForceWithVelocity:(CGPoint*)velocity maxForce:(CGPoint*)maxForce maxVelocity:(CGPoint*)maxVelocity
{
    return CGPointMake(maxForce->x * (maxVelocity->x - velocity->x) / maxVelocity->x,
                       maxForce->y * (maxVelocity->y - velocity->y) / maxVelocity->y);
}



- (id)copyWithZone:(NSZone *)zone
{
    Character *i = [super copyWithZone:zone];
    i.standDrawable = [_standDrawable copy];
    i.runningDrawable = [_runningDrawable copy];
    i.flyingDrawable = [_flyingDrawable copy];
    i.explosionDrawable = [_explosionDrawable copy];
    i.runningMaxVelocity = _runningMaxVelocity;
    i.runningMaxForce = _runningMaxForce;
    i.rocketMaxVelocity = _rocketMaxVelocity;
    i.rocketMaxForce = _rocketMaxForce;
    i.rocketFirstJumpForceTime = _rocketFirstJumpForceTime;
    i.rocketFirstJumpForce = _rocketFirstJumpForce;
    i.jumpForceTime = _jumpForceTime;
    i.jumpForce = _jumpForce;
    i.jumpOnAirForceTime = _jumpOnAirForceTime;
    i.jumpOnAirForce = _jumpOnAirForce;
    i.numberOfAllowedJumpsOnAir = _numberOfAllowedJumpsOnAir;
    return i;
}

@end
