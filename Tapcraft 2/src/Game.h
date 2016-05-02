/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameData.h"
#import "GameSimulator.h"
#import "Camera.h"

/*
extern NSString * const GamePreStep;
extern NSString * const GamePostStep;
extern NSString * const GameContactBegin;
extern NSString * const GameContactPreSolve;
extern NSString * const GameContactPostSolve;
extern NSString * const GameContactEnd;
*/

@interface ObjectGameInfo : NSObject
@property NSInteger treeProxyId;
@property SimBody *body;
@end

@protocol GameDelegate;

@interface Game : NSObject

// indexed same as gameData positionZs
// NSNull for zero depth
@property NSArray *depthTrees;
@property GameSimulator *gameSimulator;
@property NSTimeInterval maxApplyUpdateTime;

@property id<GameDelegate> delegate;
@property (readonly) GameData *gameData;

@property NSDate *startDate;

@property (readonly) Camera camera;
@property (nonatomic, assign) CGSize viewSize;

- (instancetype)initWithGameData:(GameData*)gameData;
- (NSArray*)objectsToDrawOrdered;
- (void)update;
- (void)start;
- (void)setCameraCenter:(CGPoint)center;
- (void)initialize;
- (void)setObjectPhysicsNeedsUpdate:(Object*)object;

@end

@protocol GameDelegate <NSObject>

- (void)gamePreStep;
- (void)gamePostStep;
- (void)gameBeginContact:(SimContact *)contact;
- (void)gameEndContact:(SimContact *)contact;
- (void)gamePreSolve:(SimContact *)contact oldManifold:(SimManifold *)oldManifold;
- (void)gamePostSolve:(SimContact *)contact impulse:(SimContactImpulse *)impulse;

@end