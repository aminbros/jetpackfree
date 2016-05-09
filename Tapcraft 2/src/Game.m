/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Game.h"
#include "GameSimulator.h"
#import "DynamicRTree.h"
#import "Character.h"

#define LEAST_WAIT_FOR_UPDATE (1.0 / 60.0)

NSString * const GamePreStep = @"GamePreStep";
NSString * const GamePostStep = @"GamePostStep";
NSString * const GameContactBegin = @"GameContactBegin";
NSString * const GameContactPreSolve = @"GameContactPreSolve";
NSString * const GameContactPostSolve = @"GameContactPostSolve";
NSString * const GameContactEnd = @"GameContactEnd";

@implementation ObjectGameInfo
@end

@interface Game()<SimContactDelegate>

@property NSTimeInterval totalInterval;

@end

@implementation Game

- (instancetype)initWithGameData:(GameData*)gameData
{
    self = [super init];
    if(self != nil) {
        _gameData = [gameData copy];
        _gameSimulator = [[GameSimulator alloc] initWithConfig:_gameData.simulatorConfig];
        _gameSimulator.contactDelegate = self;
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _maxApplyUpdateTime = 1; // one second
    
    GameData *gd = _gameData;
    _camera = gd.initialCamera;

    NSMutableArray *dTrees = [NSMutableArray new];
    for(NSNumber *positionZ in gd.positionZs) {
        if(fabs(1.0 - [positionZ doubleValue]) < 0.001)
            [dTrees addObject:[NSNull null]];
        else
            [dTrees addObject:[[DynamicRTree alloc] init]];
    }
    _depthTrees = [dTrees copy];
    NSInteger depthTreesLen = _depthTrees.count;
    for(GObject *object in gd.objects) {
        if(object.positionZIndex < 0 || object.positionZIndex >= depthTreesLen)
            continue;
        DynamicRTree *dTree = [_depthTrees objectAtIndex:object.positionZIndex];
        ObjectGameInfo *oGameInfo = [[ObjectGameInfo alloc] init];
        object.objectGameInfo = oGameInfo;
        if([dTree isKindOfClass:[NSNull class]]) {
            oGameInfo.body = [_gameSimulator addObject:object];
        } else if(dTree != nil) {
            Bound bound = [object computeBound];
            oGameInfo.treeProxyId = [dTree createProxyWithBound:&bound userData:(__bridge void*)object];
        }
    }
}

- (void)start
{
    _startDate = [NSDate date];
}

- (void)updateWithInterval:(NSTimeInterval)interval
{
    _totalInterval += interval;
    if(_maxApplyUpdateTime > 0.0 && _totalInterval > _maxApplyUpdateTime) {
        // skip elapsed time
        return;
    }
    NSTimeInterval leastWaitForUpdate = _gameSimulator.timeStep;
    while (_totalInterval >= leastWaitForUpdate) {
        
        [_delegate gamePreStep];
        [_gameSimulator step];
        [_delegate gamePostStep];
        
        _totalInterval -= leastWaitForUpdate;
    }
}

- (NSArray *)objectsToDrawOrdered
{
    NSMutableArray *vObjects = [NSMutableArray new];
    for(NSInteger i = 0, len = _depthTrees.count; i < len; ++i) {
        DynamicRTree *dTree = [_depthTrees objectAtIndex:i];
        CGFloat positionZ = [[_gameData.positionZs objectAtIndex:i] doubleValue];
        // scale for objects size at positionZ
        Bound viewBound = CameraBoundMulScale(&_camera, positionZ);
        if([dTree isKindOfClass:[NSNull class]]) {
            [_gameSimulator queryForBound:&viewBound callback:^BOOL(SimFixture *fixture) {
                SimBody *body = [fixture getBody];
                GObject *object = [body getUserData];
                if(object.physicsActive)
                    [_gameSimulator updateObject:object withBody:body];
                [vObjects addObject:object];
                return YES;
            }];
        } else {
            [dTree queryForBound:&viewBound callback:^BOOL(NSInteger proxyId) {
                    [vObjects addObject:(__bridge GObject*)[dTree getUserDataWithProxyId:proxyId]];
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

- (void)updateObjectPhysics:(GObject*)object {
    if(!object.physicsActive)
        return;
    ObjectGameInfo *oGameInfo = object.objectGameInfo;
    if(oGameInfo.body != nil)
        [_gameSimulator updateObject:object withBody:oGameInfo.body];
}

- (void)setObjectPhysicsNeedsUpdate:(GObject*)object
{
    //TODO:: Implement
}

- (void)setCameraCenter:(CGPoint)center
{
    _camera.center = center;
}

#pragma mark - SimContactDelegate

- (void)beginContact:(SimContact *)contact
{
    [_delegate gameBeginContact:contact];
}

- (void)endContact:(SimContact *)contact
{
    [_delegate gameEndContact:contact];
}

- (void)preSolve:(SimContact *)contact oldManifold:(SimManifold *)oldManifold
{
    [_delegate gamePreSolve:contact oldManifold:oldManifold];
}

- (void)postSolve:(SimContact *)contact impulse:(SimContactImpulse *)impulse
{
    [_delegate gamePostSolve:contact impulse:impulse];
}

@end
