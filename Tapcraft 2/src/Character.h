/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Object.h"
#import "ObjectImageDrawable.h"
#import "ObjectTweenDrawable.h"

@interface Character : GObject

@property ObjectImageDrawable *standDrawable;
@property ObjectTweenDrawable *runningDrawable;
@property ObjectTweenDrawable *flyingDrawable;
@property ObjectTweenDrawable *explosionDrawable;

@property CGFloat runningMaxVelocity;
@property CGFloat runningMaxForce;
@property CGPoint rocketMaxVelocity;
@property CGPoint rocketMaxForce;
@property NSTimeInterval rocketFirstJumpForceTime;
@property CGFloat rocketFirstJumpForce;
@property NSTimeInterval jumpForceTime;
@property CGFloat jumpForce;
@property NSTimeInterval jumpOnAirForceTime;
@property CGFloat jumpOnAirForce;

@property NSInteger numberOfAllowedJumpsOnAir;

- (CGPoint)applicableForceWithVelocity:(CGPoint*)velocity maxForce:(CGPoint*)maxForce maxVelocity:(CGPoint*)maxVelocity;

@end
