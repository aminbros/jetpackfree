//
//  JetpackKnightController.m
//  JetpackKnight
//
//  Created by Hossein Amin on 5/2/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import "JetpackKnightController.h"

#pragma mark - player contact events

typedef void(*PlayerContactFunc)(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, Object *otherObject);


static void playerEndContactWithGround(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, Object *otherObject)
{
    [player.touchedGrounds removeObject:otherObject];
    player.touchedGround = player.touchedGrounds.count > 0;
}

static void playerBeginContactWithGround(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, Object *otherObject)
{
    if([player.touchedGrounds indexOfObject:otherObject] == NSNotFound) {
        [player.touchedGrounds addObject:otherObject];
    }
    player.touchedGround = YES;
    
    // remove rocket
    if(player.hasRocket) {
        player.hasRocket = NO;
        player.character.drawable = [player.character.runningDrawable copy];
    }
}

static void playerBeginContactWithObstacle(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, Object *otherObject)
{
    player.character.drawable = [player.character.explosionDrawable copy];
    // end game if not having rocket
    if(player.hasRocket) {
        player.hasRocket = NO;
        player.rocketEngineOn = NO;
    } else {
        ctr.viewController.pauseSimulation = YES;
        // present gameover
    }
}

static void playerBeginContactWithDiamond(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, Object *otherObject)
{
    [ctr.postStepDestorySet addObject:otherObject];
    player.collectedGems++;
}

static void playerBeginContactWithRocket(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, Object *otherObject)
{
    [ctr.postStepDestorySet addObject:otherObject];
    player.hasRocket = YES;
    player.character.drawable = [player.character.flyingDrawable copy];
    player.jumpForceTime = player.character.rocketFirstJumpForceTime;
    player.jumpForce = player.character.rocketFirstJumpForce;
}

#pragma mark - jetpack knight controller

@interface JetpackKnightController()<GameDelegate,GameViewTouchDelegate>


@end

@implementation JetpackKnightController

- (instancetype)initWithViewController:(JetpackKnightViewController*)viewController
{
    self = [super init];
    if(self != nil) {
        _postStepDestorySet = [NSMutableSet new];
        
        _viewController = viewController;
        _game = _viewController.jGame;
        _game.delegate = self;
        _viewController.gameView.touchDelegate = self;
        
        // initialize players
        for(JetpackKnightPlayer *player in self.viewController.jGame.players) {
            Character *character = player.character;
            character.drawable = [character.runningDrawable copy];
        }
    }
    return self;
}

#pragma mark - GameViewTouchDelegate

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // when flying start jet
    JetpackKnightPlayer *player = [self.game.players objectAtIndex:self.playerIndex];
    if(player.hasRocket) {
        player.rocketEngineOn = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // listen on tap to perform jump on tap
    // when flying stop jet
    JetpackKnightPlayer *player = [self.game.players objectAtIndex:self.playerIndex];
    if(player.hasRocket) {
        player.rocketEngineOn = NO;
    } else if(player.jumpForce <= 0.0) {
        // jump
        if(player.touchedGround) {
            player.jumpForceTime = player.character.jumpForceTime;
            player.jumpForce = player.character.jumpForce;
            player.numberOfJumpOnAir = 0;
        } else if(player.numberOfJumpOnAir < player.character.numberOfAllowedJumpsOnAir) {
            player.jumpForceTime = player.character.jumpForceTime;
            player.jumpForce = player.character.jumpOnAirForce;
            player.numberOfJumpOnAir++;
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - GameDelegate

- (void)gamePreStep
{
    // update game before step
    for(JetpackKnightPlayer *player in self.viewController.jGame.players) {
        Character *character = player.character;
        ObjectGameInfo *oGInfo = character.objectGameInfo;
        SimBody *body = oGInfo.body;
        CGPoint vel = [body getLinearVelocity];
        CGPoint maxForce,maxVel;
        CGPoint applyForce;
        BOOL hasApplyForce = NO;
        if(player.jumpForce > 0.0 && player.jumpForceTime > 0.0) {
            hasApplyForce = YES;
            applyForce = CGPointMake(0, player.jumpForce*(player.jumpForceTime / self.game.gameSimulator.timeStep));
            player.jumpForce -= applyForce.y;
        }
        if(!hasApplyForce) {
            if(player.hasRocket) {
                if(player.rocketEngineOn) {
                    hasApplyForce = YES;
                    maxForce = character.rocketMaxForce;
                    maxVel = character.rocketMaxVelocity;
                    applyForce = [character applicableForceWithVelocity:&vel maxForce:&maxForce maxVelocity:&maxVel];
                }
            } else {
                // run
                if(player.touchedGround) {
                    hasApplyForce = YES;
                    // no effect on y axis
                    maxForce = CGPointMake(character.runningMaxForce, 0.0);
                    maxVel = CGPointMake(character.runningMaxVelocity, 1.0);
                    applyForce = [character applicableForceWithVelocity:&vel maxForce:&maxForce maxVelocity:&maxVel];
                }
            }
        }
        if(hasApplyForce) {
            [body applyForceToCenter:&applyForce];
        }
    }
}

- (void)gamePostStep
{
    GameSimulator *gameSimulator = self.game.gameSimulator;
    if(_postStepDestorySet.count > 0) {
        for(Object *object in _postStepDestorySet) {
            ObjectGameInfo *oGInfo = object.objectGameInfo;
            [gameSimulator removeBody:oGInfo.body];
        }
        _postStepDestorySet = [NSMutableSet new];
    }
    
    
    
    // update players
    for(JetpackKnightPlayer *player in self.viewController.jGame.players) {
        Character *character = player.character;
        ObjectGameInfo *oGInfo = character.objectGameInfo;
        [gameSimulator updateObject:character withBody:oGInfo.body];
    }
    
    // follow character after step
    JetpackKnightPlayer *player = [_viewController.jGame.players objectAtIndex:self.playerIndex];
    Character *character = player.character;
    [_viewController.game setCameraCenter:CGPointMake(character.position.x + 5, _viewController.game.camera.center.y)];
}


- (void)playerBeginContactTouch:(SimContact*)contact player:(JetpackKnightPlayer*)player playerIndex:(NSInteger)playerIndex otherFixture:(SimFixture*)otherFixture
{
    SimBody *otherBody = [otherFixture getBody];
    Object *otherObject = [otherBody getUserData];
    PlayerContactFunc contactWithFunc = otherObject.tag != nil ? [self playerContactFunc:@"begin" withTag:otherObject.tag] : NULL;
    if(contactWithFunc != NULL)
        contactWithFunc(self, contact, player, playerIndex, otherObject);
}

- (void)playerEndContactTouch:(SimContact*)contact player:(JetpackKnightPlayer*)player playerIndex:(NSInteger)playerIndex otherFixture:(SimFixture*)otherFixture
{
    SimBody *otherBody = [otherFixture getBody];
    Object *otherObject = [otherBody getUserData];
    PlayerContactFunc contactWithFunc = otherObject.tag != nil ? [self playerContactFunc:@"end" withTag:otherObject.tag] : NULL;
    if(contactWithFunc != NULL)
        contactWithFunc(self, contact, player, playerIndex, otherObject);
}

#define contactOtherFixture(fi,fixtures) [fixtures objectAtIndex:(fi + ((fi) > 0 ? - 1 : 1))]

- (void)gameBeginContact:(SimContact *)contact
{
    NSArray *fixtures = @[[contact getFixtureA], [contact getFixtureB]];
    for(NSInteger fi = 0,filen = fixtures.count; fi < filen; ++fi) {
        SimFixture *fixture = [fixtures objectAtIndex:fi];
        SimBody *body = [fixture getBody];
        Object *object = [body getUserData];
        
        // check for player contact
        if([object isKindOfClass:[Character class]]) {
            for(NSInteger pi = 0, pilen = self.game.players.count; pi < pilen; ++pi) {
                JetpackKnightPlayer *player = [self.game.players objectAtIndex:pi];
                if(player.character == (Character*)object) {
                    [self playerBeginContactTouch:contact player:player playerIndex:pi otherFixture:contactOtherFixture(fi, fixtures)];
                }
            }
        }
    }
}

- (void)gameEndContact:(SimContact *)contact
{
    NSArray *fixtures = @[[contact getFixtureA], [contact getFixtureB]];
    for(NSInteger fi = 0,filen = fixtures.count; fi < filen; ++fi) {
        SimFixture *fixture = [fixtures objectAtIndex:fi];
        SimBody *body = [fixture getBody];
        Object *object = [body getUserData];
        
        // check for player contact
        if([object isKindOfClass:[Character class]]) {
            for(NSInteger pi = 0, pilen = self.game.players.count; pi < pilen; ++pi) {
                JetpackKnightPlayer *player = [self.game.players objectAtIndex:pi];
                if(player.character == (Character*)object) {
                    [self playerEndContactTouch:contact player:player playerIndex:pi otherFixture:contactOtherFixture(fi, fixtures)];
                }
            }
        }
    }
}

- (void)gamePreSolve:(SimContact *)contact oldManifold:(SimManifold *)oldManifold
{
    
}

- (void)gamePostSolve:(SimContact *)contact impulse:(SimContactImpulse *)impulse
{
    
}

- (PlayerContactFunc)playerContactFunc:(NSString*)action withTag:(NSString*)tag {
    static NSDictionary *s_playerBeginContactWith;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_playerBeginContactWith =
            @{
              [NSString stringWithFormat:@"end_%@", JetpackKnightGroundTag]: [NSValue valueWithPointer:playerEndContactWithGround],
              [NSString stringWithFormat:@"begin_%@", JetpackKnightGroundTag]: [NSValue valueWithPointer:playerBeginContactWithGround],
              [NSString stringWithFormat:@"begin_%@", JetpackKnightDiamondTag]: [NSValue valueWithPointer:playerBeginContactWithDiamond],
              [NSString stringWithFormat:@"begin_%@", JetpackKnightObstacleTag]: [NSValue valueWithPointer:playerBeginContactWithObstacle],
              [NSString stringWithFormat:@"begin_%@", JetpackKnightRocketTag]: [NSValue valueWithPointer:playerBeginContactWithRocket],
              };
    });
    id v = [s_playerBeginContactWith objectForKey:[NSString stringWithFormat:@"%@_%@", action, tag]];
    return v ? [v pointerValue] : NULL;
}

@end
