/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Game.h"
#include "GameSimulator.h"
#import "DynamicRTree.h"

#define LEAST_WAIT_FOR_UPDATE (1.0 / 60.0)

@interface ObjectGameInfo : NSObject
@property NSInteger treeProxyId;
@end
@implementation ObjectGameInfo
@end

@interface Game()

// indexed same as gameData positionZs
// NSNull for zero depth
@property NSArray *depthTrees;

@property NSTimeInterval maxApplyUpdateTime;
@property NSTimeInterval lastApplyUpdateTime;

@end

@implementation Game

- (instancetype)initWithGameData:(GameData*)gameData
{
    self = [super init];
    if(self != nil) {
        _gameData = [gameData copy];
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    _maxApplyUpdateTime = 1; // one second
    
    GameData *gd = _gameData;
    _camera = gd.initialCamera;

    NSMutableArray *dTrees = [NSMutableArray new];
    for(NSNumber *positionZ in gd.positionZs) {
        if(fabs(1.0 - [positionZ doubleValue]) < 0.001 && NO) // TODO:: use physics for depth 0
            [dTrees addObject:[NSNull null]];
        else
            [dTrees addObject:[[DynamicRTree alloc] init]];
    }
    _depthTrees = [dTrees copy];
    NSInteger depthTreesLen = _depthTrees.count;
    for(Object *object in gd.objects) {
        if(object.positionZIndex < 0 || object.positionZIndex >= depthTreesLen)
            continue;
        DynamicRTree *dTree = [_depthTrees objectAtIndex:object.positionZIndex];
        if([dTree isKindOfClass:[NSNull class]]) {
            // add to physics world
            // TODO:: implement
        } else if(dTree != nil) {
            ObjectGameInfo *oGameInfo = [[ObjectGameInfo alloc] init];
            Bound bound = [object computeBound];
            oGameInfo.treeProxyId = [dTree createProxyWithBound:&bound userData:(__bridge void*)object];
            object.objectGameInfo = oGameInfo;
        }
        
    }
}

- (void)start
{
    _startDate = [NSDate date];
    _lastApplyUpdateTime = 0;
}

- (void)update
{
    // move to right
    NSTimeInterval time = [_startDate timeIntervalSinceNow];
    NSTimeInterval interval = -(time + _lastApplyUpdateTime); // sinceNow is decreasing
    if(_maxApplyUpdateTime > 0.0 && interval > _maxApplyUpdateTime) {
        _lastApplyUpdateTime = -time; // skip elapsed time
        return;
    }
    NSInteger numInterval = 0;
    while (interval > LEAST_WAIT_FOR_UPDATE) {
        
        // move camera to right
        if(_camera.center.x < _gameData.gameBound.upperBound.x)
            _camera.center.x += 0.01;
        
        interval -= LEAST_WAIT_FOR_UPDATE;
        numInterval++;
    }
    _lastApplyUpdateTime += LEAST_WAIT_FOR_UPDATE * numInterval;
}

- (NSArray *)objectsToDrawOrdered
{
    NSMutableArray *vObjects = [NSMutableArray new];
    for(NSInteger i = 0, len = _depthTrees.count; i < len; ++i) {
        DynamicRTree *dTree = [_depthTrees objectAtIndex:i];
        CGFloat positionZ = [[_gameData.positionZs objectAtIndex:i] doubleValue];
        if([dTree isKindOfClass:[NSNull class]]) {
            // TODO::add physics objects in view
        } else {
            // scale for objects size at positionZ
            Bound viewBound = CameraBoundMulScale(&_camera, positionZ);
            [dTree queryForBound:&viewBound callback:^BOOL(NSInteger proxyId) {
                    [vObjects addObject:(__bridge Object*)[dTree getUserDataWithProxyId:proxyId]];
                    return YES;
                }];
        }
        
    }
    return [vObjects sortedArrayUsingSelector:@selector(zIndexCompare:)];
}

- (void)setViewSize:(CGSize)viewSize
{
    _viewSize = viewSize;
    _camera.ratio = viewSize.width / viewSize.height; // update camera as well
    _camera.screenScale = CameraScaleForFitInSize(&_camera, &viewSize);
}

@end
