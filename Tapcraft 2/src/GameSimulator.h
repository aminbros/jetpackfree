/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Object.h"

@interface GameSimulatorConfig : NSObject

@property CGPoint gravity;
@property CGFloat timeStep;
@property NSInteger velocityIterations;
@property NSInteger positionIterations;

@end

@interface GameSimulator : NSObject

@property GameSimulatorConfig *config;

- (void)initWithConfig:(GameSimulatorConfig*)config;
- (void)addObject:(Object*)object;
- (CGFloat)step;

@end
