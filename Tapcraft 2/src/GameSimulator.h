/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Object.h"

// defs

typedef NS_ENUM(NSInteger, SimManifoldType) {
    SimManifoldTypeCircles,
    SimManifoldTypeFaceA,
    SimManifoldTypeFaceB
};

@interface SimManifold : NSObject 

@property (nonatomic) SimManifoldType type;

@end

@interface SimBody : NSObject

- (id)getUserData;
- (CGPoint)getLinearVelocity;
- (void)applyForceToCenter:(CGPoint*)force;

@end

@interface SimFixture : NSObject

- (SimBody*)getBody;

@end

@interface SimContact : NSObject

- (SimManifold*)getManifold;
- (BOOL)isTouching;
- (void)setEnabled:(BOOL)enable;
- (BOOL)isEnabled;
- (SimFixture*)getFixtureA;
- (NSInteger)getChildAtIndexA;
- (SimFixture*)getFixtureB;
- (NSInteger)getChildAtIndexB;
//- (void)setFriction:(CGFloat)friction;
//- (CGFloat)getFriction;

@end

@interface SimContactImpulse : NSObject

@end

typedef BOOL(^SimQueryCallback)(SimFixture *fixture);

@protocol SimContactDelegate <NSObject>

- (void)beginContact:(SimContact*)contact;
- (void)endContact:(SimContact*)contact;
- (void)preSolve:(SimContact*)contact oldManifold:(SimManifold*)oldManifold;
- (void)postSolve:(SimContact*)contact impulse:(SimContactImpulse*)impulse;

@end

// sim interfaces

@interface GameSimulatorConfig : NSObject

@property CGPoint gravity;
@property NSTimeInterval timeStep;
@property NSInteger velocityIterations;
@property NSInteger positionIterations;

- (id)copyWithZone:(NSZone *)zone;

@end

@interface GameSimulator : NSObject

@property NSInteger simulationStep;
@property NSTimeInterval timeStep;
@property NSInteger velocityIterations;
@property NSInteger positionIterations;
@property (nonatomic,weak) id<SimContactDelegate> contactDelegate;

- (instancetype)initWithConfig:(GameSimulatorConfig*)config;
- (SimBody*)addObject:(Object*)object;
- (void)removeBody:(SimBody*)object;
- (void)step;
- (void)queryForBound:(Bound*)bound callback:(SimQueryCallback)callback;

- (void)updateObject:(Object*)object withBody:(SimBody*)body;

@end
