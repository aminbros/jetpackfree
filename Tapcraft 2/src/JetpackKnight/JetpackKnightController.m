//
//  JetpackKnightController.m
//  JetpackKnight
//
//  Created by Hossein Amin on 5/2/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import "JetpackKnightController.h"

@implementation PlayerAction

@end

@implementation ActivityStep

- (instancetype)init {
    self = [super init];
    if(self != nil) {
        _actions = [NSMutableArray new];
    }
    return self;
}

@end

#pragma mark - player contact events

typedef void(*PlayerContactFunc)(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, GObject *otherObject);


static void playerEndContactWithGround(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, GObject *otherObject)
{
    [player.touchedGrounds removeObject:otherObject];
    player.touchedGround = player.touchedGrounds.count > 0;
}

static void playerBeginContactWithGround(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, GObject *otherObject)
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

static void playerBeginContactWithObstacle(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, GObject *otherObject)
{
    // end game if not having rocket
    if(player.hasRocket) {
        player.character.drawable = [player.character.runningDrawable copy];
        player.hasRocket = NO;
        player.rocketEngineOn = NO;
    } else {
        player.character.drawable = [player.character.explosionDrawable copy];
        [ctr.viewController gameDidEnd];
    }
}

static void playerBeginContactWithDiamond(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, GObject *otherObject)
{
    [ctr.postStepDestorySet addObject:otherObject];
    player.collectedGems++;
    if(playerIndex == ctr.playerIndex) {
        ctr.viewController.scoreLabel.text = [NSString stringWithFormat:@"%zd", player.collectedGems];
    }
}

static void playerBeginContactWithRocket(JetpackKnightController *ctr, SimContact *contact, JetpackKnightPlayer *player, NSInteger playerIndex, GObject *otherObject)
{
    [ctr.postStepDestorySet addObject:otherObject];
    player.hasRocket = YES;
    player.character.drawable = [player.character.flyingDrawable copy];
    if(player.touchedGround) {
        player.jumpForceTime = player.character.rocketFirstJumpForceTime;
        player.jumpForce = player.character.rocketFirstJumpForce;
    }
}

#pragma mark - jetpack knight controller

@interface JetpackKnightController()<GameDelegate,GameViewTouchDelegate>

@property BOOL connectedToNetwork;

@end

@implementation JetpackKnightController

- (instancetype)initWithViewController:(JetpackKnightViewController*)viewController
{
    self = [super init];
    if(self != nil) {
        _activities = [NSMutableArray new];
        
        _postStepDestorySet = [NSMutableSet new];
        
        _viewController = viewController;
        _game = _viewController.jGame;
        _game.delegate = self;
        _viewController.gameView.touchDelegate = self;

        _connectedToNetwork = _viewController.match;
        
        _playersById = [NSMutableDictionary new];
        // initialize players
        for(JetpackKnightPlayer *player in self.viewController.jGame.players) {
            Character *character = player.character;
            character.drawable = [character.runningDrawable copy];
            [_playersById setObject:player forKey:player.playerId];
        }
        
        // follow character after step
        JetpackKnightPlayer *player = [_viewController.jGame.players objectAtIndex:self.playerIndex];
        Character *character = player.character;
        [_viewController.game setCameraCenter:CGPointMake(character.position.x + _game.jGameData.characterPinOffset.x, _viewController.game.camera.center.y + _game.jGameData.characterPinOffset.y)];
        _viewController.scoreLabel.text = [NSString stringWithFormat:@"%zd", player.collectedGems];
        [self displayPlayersDistanceToOtherPlayer:player];
        
    }
    return self;
}

- (void)displayPlayersDistanceToOtherPlayer:(JetpackKnightPlayer*)player
{
    JetpackKnightPlayer *otherPlayer = nil;
    for(JetpackKnightPlayer *aPlayer in self.game.players) {
        if(aPlayer != player) {
            otherPlayer = aPlayer;
            break;
        }
    }
    if(otherPlayer == nil) {
        self.viewController.distanceLabel.text = @"";
    } else {
        CGFloat distance = fabs(player.character.position.x - otherPlayer.character.position.x);
        self.viewController.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.1f", distance];
    }
}

#pragma mark - GameViewTouchDelegate

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // when flying start jet
    JetpackKnightPlayer *player = [self.game.players objectAtIndex:self.playerIndex];
    if(player.hasRocket) {
        // ACTION
        [self localPlayerPerformAction:GNA_JetpackEngineOn];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // listen on tap to perform jump on tap
    // when flying stop jet
    JetpackKnightPlayer *player = [self.game.players objectAtIndex:self.playerIndex];
    // ACTION
    if(player.hasRocket) {
        [self localPlayerPerformAction:GNA_JetpackEngineOff];
    } else if(player.jumpForce <= 0.0 &&
              (player.touchedGround || player.numberOfJumpOnAir < player.character.numberOfAllowedJumpsOnAir)) {
        [self localPlayerPerformAction:GNA_Jump];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - Network delegate

- (void)performPlayerAction:(PlayerAction*)playerAction {
    JetpackKnightPlayer *player = playerAction.player;
    switch (playerAction.action) {
        case GNA_JetpackEngineOn: {
            if(player.hasRocket) {
                player.rocketEngineOn = YES;
            }
            break;
        }
        case GNA_JetpackEngineOff: {
            if(player.hasRocket) {
                player.rocketEngineOn = NO;
            }
            break;
        }
        case GNA_Jump: {
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
            break;
        }
        case GNA_LeftShoot: {
            
            break;
        }
        case GNA_RightShoot: {
            
            break;
        }
        default:
            break;
    }
}

- (void)performActivityStep:(ActivityStep*)activityStep {
    for(PlayerAction *playerAction in activityStep.actions) {
        [self performPlayerAction:playerAction];
    }
}

- (void)localPlayerPerformAction:(GNAction)action {
    if(_connectedToNetwork) {
        GNActionMsg *msg = [GNActionMsg new];
        msg.action = action;
        // simulationStep is at next simulation step
        msg.timeStep = (uint32_t)MAX(self.viewController.lastSentCommitTimeStep + 1, self.game.gameSimulator.simulationStep);
        [self.viewController sendDataToAll:[GameNetworkProtocol makePacketWithMessage:GN_ACTION data:[msg dataForPacket]]];
        // add to activities
        [self didReceivedActionMsg:msg fromRemotePlayer:((JetpackKnightPlayer*)[self.game.players objectAtIndex:_playerIndex]).gkPlayer];
    } else {
        ActivityStep *activityStep = [self activityStepForTimeStep:self.game.gameSimulator.simulationStep];
        PlayerAction *paction = [PlayerAction new];
        paction.action = action;
        paction.player = [self.game.players objectAtIndex:self.playerIndex];
        [activityStep.actions addObject:paction];
    }
}

- (ActivityStep*)activityStepForTimeStep:(NSInteger)timeStep {
    ActivityStep *newActivityStep = [ActivityStep new];
    newActivityStep.timeStep = timeStep;
    
    NSInteger index = [_activities indexOfObject:newActivityStep inSortedRange:NSMakeRange(0, _activities.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(ActivityStep * _Nonnull obj1, ActivityStep *  _Nonnull obj2) {
        // equal is not allowed
        if(obj1.timeStep < obj2.timeStep)
            return NSOrderedAscending;
        else if(obj1.timeStep > obj2.timeStep)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    ActivityStep *foundActivity = nil;
    NSArray *searchIndices = @[@(index),@(index-1),@(index+1)];
    for(NSNumber *nindex in searchIndices) {
        NSInteger i = [nindex integerValue];
        ActivityStep *a = i >= 0 && i < _activities.count ? [_activities objectAtIndex:i] : nil;
        if(a.timeStep == timeStep) {
            foundActivity = a;
            break;
        }
    }
    
    if(foundActivity == nil) {
        [_activities insertObject:newActivityStep atIndex:index];
        return newActivityStep;
    }
    return foundActivity;
}

- (void)didReceivedActionMsg:(GNActionMsg*)actionMsg fromRemotePlayer:(GKPlayer*)gkPlayer {
    ActivityStep *activityStep = [self activityStepForTimeStep:actionMsg.timeStep];
    JetpackKnightPlayer *player = [_playersById objectForKey:gkPlayer.playerID];
    NSAssert(player != nil, @"Never!");
    PlayerAction *paction = [PlayerAction new];
    paction.action = actionMsg.action;
    paction.player = player;
    [activityStep.actions addObject:paction];
}

#pragma mark - GameDelegate

- (void)gamePreStep
{
    // apply player actions
    NSInteger currentTimeStep = self.game.gameSimulator.simulationStep;
    ActivityStep *activityStep = [_activities firstObject];
    // ignore earlier activities
    // usually first timeStep is later than or equal currentTimeStep
    while(activityStep != nil && activityStep.timeStep < currentTimeStep) {
        NSLog(@"preStepActivityIgnored! : %zd simStep: %zd timeStep: %zd", activityStep.actions.count, currentTimeStep, activityStep.timeStep);
        [_activities removeObjectAtIndex:0];
        activityStep = [_activities firstObject];
    }
    // perform activityStep if exists
    if(activityStep != nil && activityStep.timeStep == currentTimeStep) {
        [self performActivityStep:activityStep];
        [_activities removeObjectAtIndex:0];
    }
    
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
            // multiply force with avg scale to have consistant change
            applyForce = [character pointMulAvgScale:&applyForce];
            [body applyForceToCenter:&applyForce];
        }
    }
}

- (void)gamePostStep
{
    GameSimulator *gameSimulator = self.game.gameSimulator;
    if(_postStepDestorySet.count > 0) {
        for(GObject *object in _postStepDestorySet) {
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
    [_viewController.game setCameraCenter:CGPointMake(character.position.x + _game.jGameData.characterPinOffset.x, _viewController.game.camera.center.y + _game.jGameData.characterPinOffset.y)];
    if(self.game.players.count > 1)
        [self displayPlayersDistanceToOtherPlayer:player];
    
    // check for end game
    for(JetpackKnightPlayer *player in self.viewController.jGame.players) {
        Character *character = player.character;
        if(character.position.x >= self.game.gameData.gameBound.upperBound.x) {
            [self.viewController gameDidEnd];
        }
    }
}


- (void)playerBeginContactTouch:(SimContact*)contact player:(JetpackKnightPlayer*)player playerIndex:(NSInteger)playerIndex otherFixture:(SimFixture*)otherFixture
{
    SimBody *otherBody = [otherFixture getBody];
    GObject *otherObject = [otherBody getUserData];
    PlayerContactFunc contactWithFunc = otherObject.tag != nil ? [self playerContactFunc:@"begin" withTag:otherObject.tag] : NULL;
    if(contactWithFunc != NULL)
        contactWithFunc(self, contact, player, playerIndex, otherObject);
}

- (void)playerEndContactTouch:(SimContact*)contact player:(JetpackKnightPlayer*)player playerIndex:(NSInteger)playerIndex otherFixture:(SimFixture*)otherFixture
{
    SimBody *otherBody = [otherFixture getBody];
    GObject *otherObject = [otherBody getUserData];
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
        GObject *object = [body getUserData];
        
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
        GObject *object = [body getUserData];
        
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
