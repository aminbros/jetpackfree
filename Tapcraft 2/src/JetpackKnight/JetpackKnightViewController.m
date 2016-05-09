
/*
 * Author: Hossein Amin, aminbros.com
 */

#import "JetpackKnightViewController.h"
#import "JetpackKnightGameData.h"
#import "GameDataGenerator.h"
#import "JetpackKnightController.h"
#import "AppDelegate.h"
#import "GameNetworkProtocol.h"
#import "RandomGenerator.h"
#import "ROUSession.h"

@interface JetpackKnightViewController()<GKMatchDelegate,ROUSessionDelegate>

@property JetpackKnightController *gameController;

@property BOOL peersConnected;
@property NSDictionary *playersDataById;
@property NSArray *playersId;
@property GKPlayer *gameInitiatorPlayer;
@property BOOL isGameInitiator;
@property GKLocalPlayer *localPlayer;

@property uint32_t gameRandomSeed;
@property NSArray *gamePlayersId;

@property NSInteger leastCommitTimeStep;
@property NSInteger lastTimeStep;
@property NSTimeInterval lastSendCommitTime;
@property NSTimeInterval sendCommitInterval;

@property NSMutableSet *playersIdConnectedToAll;

@property GameData *gameDataCopy;

@property NSDictionary<NSString*,ROUSession*> *rouSessionForPlayersById;

@end

@implementation JetpackKnightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gameClass = [JetpackKnightGame class];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if(self.match == nil) {// single player
        [self startLoadingGame];
    } else {
        self.gameLoopSelector = @selector(networkGameLoop:);
        self.scoreLabel.text = @"Connecting...";
        self.match.delegate = self;
        _localPlayer = [GKLocalPlayer localPlayer];
        _playersIdConnectedToAll = [NSMutableSet new];
        if(self.match.expectedPlayerCount == 0) {
            [self didConnectedToPeers];
            [_playersIdConnectedToAll addObject:_localPlayer.playerID];
            [self sendDataToAll:[GameNetworkProtocol makePacketWithMessage:GN_PEERS_CONNECTED data:nil]];
            [self checkAllPlayersConnected];
        }
    }
}

- (void)dealloc {
    [self.match disconnect];
}

- (void)destroyGame {
    [super destroyGame];
    if(_rouSessionForPlayersById != nil) {
        for(NSString *playerId in _rouSessionForPlayersById) {
            ROUSession *session = [_rouSessionForPlayersById objectForKey:playerId];
            session.delegate = nil; // remove reference
        }
    }
}

#pragma mark - match delegate

- (void)match:(GKMatch *)match player:(GKPlayer *)player didChangeConnectionState:(GKPlayerConnectionState)state {
    if(state == GKPlayerStateConnected && self.match.expectedPlayerCount == 0 &&
       ![_playersIdConnectedToAll containsObject:_localPlayer.playerID]) {
        [self didConnectedToPeers];
        [_playersIdConnectedToAll addObject:_localPlayer.playerID];
        [self sendDataToAll:[GameNetworkProtocol makePacketWithMessage:GN_PEERS_CONNECTED data:nil]];
        [self checkAllPlayersConnected];
    } else if(state == GKPlayerStateDisconnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.match.delegate = nil;
            [[AppDelegate sharedInstance] showAlertWithTitle:@"Connection disconnected!" message:@"" completion:^{
                [self destroyGame];
                [self.delegate jetpackKnightGameOverBackToMenu:self];
            }];
        });
    }
}

- (void)didConnectedToPeers {
    NSMutableDictionary *sessions = [NSMutableDictionary new];
    for(GKPlayer *player in self.match.players) {
        ROUSession *rouSession = [ROUSession new];
        rouSession.tag = player;
        rouSession.delegate = self;
        [sessions setObject:rouSession forKey:player.playerID];
    }
    self.rouSessionForPlayersById = [sessions copy];
}


#pragma mark - rou session delegate

- (void)session:(ROUSession *)session receivedData:(NSData *)data {
    GKPlayer *player = session.tag;
    
    // read packet
    GNPacket *packet = [GNPacket instanceFromData:data];
    
    // ignore packets before peers connected
    if(!_peersConnected && packet.message != GN_PEERS_CONNECTED) {
        NSLog(@"packet ignored: %@", data);
        [self networkError];
        return;
    }
    
    switch (packet.message) {
        case GN_PEERS_CONNECTED: {
            if(![_playersIdConnectedToAll containsObject:player.playerID]) {
                [_playersIdConnectedToAll addObject:player.playerID];
                [self checkAllPlayersConnected];
            }
            break;
        }
        case GN_RANDOM_SEED_FOR_PICK_GI: {
            // synchronized random selection of game initiator
            // set current player seed
            uint32_t seed = [GameNetworkProtocol readUInt32FromData:packet.data offset:0 endsAt:nil];
            if([self didReceivedPickGIRandomSeed:seed fromRemotePlayer:player] && _isGameInitiator) {
                // players order
                [RandomGenerator setSeed:arc4random()];
                NSArray *playersOrder = [_playersId sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [RandomGenerator intRandomWithOffset:-1 limit:2];
                }];
                
                // send init game to all
                GNInitGameMsg *msg = [GNInitGameMsg new];
                msg.randomSeed = arc4random();
                msg.playersId = playersOrder;
                [self sendDataToAll:[GameNetworkProtocol makePacketWithMessage:GN_GI_INIT_GAME data:[msg dataForPacket]]];
                // init game
                _gameRandomSeed = msg.randomSeed;
                _gamePlayersId = msg.playersId;
                [self startLoadingGame];
            }
            break;
        }
        case GN_GI_INIT_GAME: {
            if([player.playerID isEqual:_gameInitiatorPlayer.playerID]) {
                GNInitGameMsg *msg = [GNInitGameMsg instanceFromData:packet.data];
                // init game
                _gameRandomSeed = msg.randomSeed;
                _gamePlayersId = msg.playersId;
                [self startLoadingGame];
            }
            break;
        }
        case GN_GI_START_GAME: {
            if([player.playerID isEqual:_gameInitiatorPlayer.playerID]) {
                // start game
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startGame];
                });
            }
            break;
        }
        case GN_READY_TO_START: {
            // only game initiator receives this message
            if(_isGameInitiator) {
                NSMutableDictionary *playerData = [_playersDataById objectForKey:player.playerID];
                if([playerData objectForKey:@"ready_to_start"] == nil) {
                    [playerData setObject:[NSNumber numberWithBool:YES] forKey:@"ready_to_start"];
                    [self gameInitiatorCheckForStartingGame];
                }
            }
            break;
        }
        case GN_ACTION: {
            GNActionMsg *actionMsg = [GNActionMsg instanceFromData:packet.data];
            [self.gameController didReceivedActionMsg:actionMsg fromRemotePlayer:player];
            break;
        }
        case GN_COMMIT: {
            uint32_t timeStep = [GameNetworkProtocol readUInt32FromData:packet.data offset:0 endsAt:nil];
            NSMutableDictionary *playerData = [_playersDataById objectForKey:player.playerID];
            [playerData setObject:[NSNumber numberWithInteger:(NSInteger)timeStep] forKey:@"last_commit"];
            [self updateLeastCommitTimeStep];
            break;
        }
        default:
            break;
    }
}

- (void)session:(ROUSession *)session preparedDataForSending:(NSData *)data {
    NSError *error;
    if(![self.match sendData:data toPlayers:@[session.tag] dataMode:GKMatchSendDataUnreliable error:&error]) {
        NSLog(@"sendDataToAll Error: %@", [error localizedDescription]);
        [[AppDelegate sharedInstance] showAlertWithTitle:@"Network error" message:@"" completion:^{
            [self destroyGame];
            [self.delegate jetpackKnightGameOverBackToMenu:self];
        }];
    }
}

#pragma mark - Network Methods

- (void)networkError {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.match.delegate = nil;
        [[AppDelegate sharedInstance] showAlertWithTitle:@"Network error" message:@"" completion:^{
            [self destroyGame];
            [self.delegate jetpackKnightGameOverBackToMenu:self];
        }];
    });
}

- (void)checkAllPlayersConnected {
    if(self.match.expectedPlayerCount == 0 &&
       _playersIdConnectedToAll.count == self.match.players.count + 1) {
        NSLog(@"peersConencted: players count: %zd playersConnected count: %zd", self.match.players.count, _playersIdConnectedToAll.count);
        // next step
        _peersConnected = YES;
        [self didPeersConnected];
    }
}

- (void)didPeersConnected {
    // init players data
    NSMutableArray *playersId = [NSMutableArray new];
    NSMutableDictionary *playersDataById = [NSMutableDictionary new];
    [playersDataById setObject:[NSMutableDictionary dictionaryWithObject:_localPlayer forKey:@"player"] forKey:_localPlayer.playerID];
    [playersId addObject:_localPlayer.playerID];
    for(GKPlayer *player in _match.players) {
        [playersDataById setObject:[NSMutableDictionary dictionaryWithObject:player forKey:@"player"] forKey:player.playerID];
        [playersId addObject:player.playerID];
    }
    _playersDataById = playersDataById;
    _playersId = [playersId sortedArrayUsingSelector:@selector(compare:)];
    
    // send random seed to pick a game initiator
    uint32_t seed = arc4random();
    [self sendDataToAll:[GameNetworkProtocol makePacketWithMessage:GN_RANDOM_SEED_FOR_PICK_GI uint32Data:seed]];
    // set current player seed
    NSMutableDictionary *playerData = [_playersDataById objectForKey:_localPlayer.playerID];
    [playerData setObject:[NSNumber numberWithInteger:(NSInteger)seed] forKey:@"pick_gi_random_seed"];
}

- (BOOL)didReceivedPickGIRandomSeed:(uint32_t)seed fromRemotePlayer:(GKPlayer*)player {
    NSMutableDictionary *playerData = [_playersDataById objectForKey:player.playerID];
    if([playerData objectForKey:@"pick_gi_random_seed"] != nil)
        return NO;
    [playerData setObject:[NSNumber numberWithInteger:(NSInteger)seed] forKey:@"pick_gi_random_seed"];
    
    // get for all seeds
    NSMutableArray *seeds = [NSMutableArray arrayWithCapacity:_playersId.count];
    for(NSString *playerId in _playersId) {
        NSMutableDictionary *playerData = [_playersDataById objectForKey:playerId];
        NSNumber *num = [playerData objectForKey:@"pick_gi_random_seed"];
        if(num != nil)
            [seeds addObject:num];
    }
    // if all seeds available find game initiator
    if(seeds.count == _playersId.count) {
        NSInteger avgSeed = 0;
        for(NSNumber *num in seeds)
            avgSeed += [num integerValue];
        avgSeed = (NSInteger)floor((CGFloat)avgSeed / _playersId.count);
        [RandomGenerator setSeed:avgSeed];
        NSInteger giPlayerIndex = [RandomGenerator intRandomWithOffset:0 limit:_playersId.count];
        NSString *gameInitiatorPlayerId = [_playersId objectAtIndex:giPlayerIndex];
#ifdef GAME_INITIATOR_PLAYER_ID
        gameInitiatorPlayerId = GAME_INITIATOR_PLAYER_ID;
#endif
        NSAssert(gameInitiatorPlayerId != nil, @"No player id!");
        _gameInitiatorPlayer = [[_playersDataById objectForKey:gameInitiatorPlayerId] objectForKey:@"player"];
        _isGameInitiator = [_gameInitiatorPlayer isKindOfClass:[GKLocalPlayer class]];
        return YES;
    }
    return NO;
}

- (void)gameInitiatorCheckForStartingGame {
    // get ready count
    NSInteger readyCount = 0;
    for(NSString *playerId in _playersId) {
        NSMutableDictionary *playerData = [_playersDataById objectForKey:playerId];
        if([playerData objectForKey:@"ready_to_start"] != nil)
            readyCount++;
    }
    if(readyCount == _playersId.count) {
        // send start game
        [self sendDataToAll:[GameNetworkProtocol makePacketWithMessage:GN_GI_START_GAME data:nil]];
        // start game
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startGame];
        });
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromRemotePlayer:(GKPlayer *)player {
    ROUSession *session = [_rouSessionForPlayersById objectForKey:player.playerID];
    [session receiveData:data];
}

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"match:didFailWithError: %@", [error localizedDescription]);
        [[AppDelegate sharedInstance] showAlertWithTitle:@"Network error" message:@"" completion:^{
            [self destroyGame];
            [self.delegate jetpackKnightGameOverBackToMenu:self];
        }];
    });
}

- (void)sendData:(NSData*)data toPlayer:(GKPlayer*)player {
    [self sendData:data toPlayers:@[player]];
}

- (void)sendData:(NSData*)data toPlayers:(NSArray*)players {
    for(GKPlayer *player in players) {
        ROUSession *session = [_rouSessionForPlayersById objectForKey:player.playerID];
        [session sendData:data];
    }
    /*
    NSError *error;
    if(![self.match sendData:data toPlayers:players dataMode:GKMatchSendDataReliable error:&error]) {
        // network error
        dispatch_async(dispatch_get_main_queue(), ^{
            self.match.delegate = nil;
            NSLog(@"sendDataToAll Error: %@", [error localizedDescription]);
            [[AppDelegate sharedInstance] showAlertWithTitle:@"Network error" message:@"" completion:^{
                [self destroyGame];
                [self.delegate jetpackKnightGameOverBackToMenu:self];
            }];
        });
    }*/
}

- (void)sendDataToAll:(NSData*)data {
/* debug code
    GNPacket *packet = [GNPacket instanceFromData:data];
    switch (packet.message) {
        case GN_ACTION: {
            GNActionMsg *actionMsg = [GNActionMsg instanceFromData:packet.data];
            NSString *msg = [NSString stringWithFormat:@"%d %d",actionMsg.timeStep, (int)actionMsg.action];
            NSLog(@"send %@ %@", @"GN_ACTION", msg);
            break;
        }
        case GN_COMMIT: {
            uint32_t timeStep = [GameNetworkProtocol readUInt32FromData:packet.data offset:0 endsAt:nil];
            NSString *msg = [NSString stringWithFormat:@"%d",timeStep];
            NSLog(@"send %@ %@", @"GN_COMMIT", msg);
            break;
        }
        default:
            break;
    }
 */
    for(GKPlayer *player in self.match.players) {
        ROUSession *session = [_rouSessionForPlayersById objectForKey:player.playerID];
        [session sendData:data];
    }
    /*NSError *error;
    if(![self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error]) {
        // network error
        dispatch_async(dispatch_get_main_queue(), ^{
            self.match.delegate = nil;
            NSLog(@"sendDataToAll Error: %@", [error localizedDescription]);
            [[AppDelegate sharedInstance] showAlertWithTitle:@"Network error" message:@"" completion:^{
                [self destroyGame];
                [self.delegate jetpackKnightGameOverBackToMenu:self];
            }];
        });
    }*/
}

- (void)updateLeastCommitTimeStep {
    if(_playersId.count == 0)
        return;
    NSString *playerId = [_playersId objectAtIndex:0];
    NSInteger minTimeStep = [[[_playersDataById objectForKey:playerId] objectForKey:@"last_commit"] integerValue];
    for(NSInteger i = 0, len = _playersId.count; i < len; ++i) {
        NSString *playerId = [_playersId objectAtIndex:i];
        minTimeStep = MIN(minTimeStep, [[[_playersDataById objectForKey:playerId] objectForKey:@"last_commit"] integerValue]);
    }
    _leastCommitTimeStep = minTimeStep;
}

#pragma mark - view controller methods

- (void)startGame {
    if(self.match != nil) {
        for(NSString *playerId in _playersDataById) {
            NSMutableDictionary *playerData = [_playersDataById objectForKey:playerId];
            [playerData removeObjectForKey:@"last_commit"];
        }

        _leastCommitTimeStep = 0;
        _lastTimeStep = -1;
        // lockstep impl
        _sendCommitInterval = self.game.gameSimulator.timeStep;
        _lastSendCommitTime = 0;
        _lastSentCommitTimeStep = -1;
    }
    [super startGame];
}

- (void)networkGameLoop:(CADisplayLink *)displayLink {
    // lock step impl
    
    NSTimeInterval time = -[self.game.startDate timeIntervalSinceNow];
    NSInteger commitTimeStep = self.game.gameSimulator.simulationStep;
    if(time - _lastSendCommitTime > _sendCommitInterval && commitTimeStep > _lastSentCommitTimeStep) {
        // commit action until next step
        [self sendDataToAll:[GameNetworkProtocol makePacketWithMessage:GN_COMMIT uint32Data:(uint32_t)commitTimeStep]];
        
        NSMutableDictionary *playerData = [_playersDataById objectForKey:_localPlayer.playerID];
        [playerData setObject:[NSNumber numberWithInteger:commitTimeStep] forKey:@"last_commit"];
        [self updateLeastCommitTimeStep];
        
        _lastSentCommitTimeStep = commitTimeStep;
        _lastSendCommitTime = time;
    }
    
    NSInteger nextStep = _leastCommitTimeStep;
    if(nextStep > _lastTimeStep) {
        NSTimeInterval interval = self.game.gameSimulator.timeStep * (nextStep - _lastTimeStep);
        if(!self.pauseSimulation) {
            [self.game updateWithInterval:interval];
        }
        self.gameView.currentInterval = interval;
        [self.gameView setNeedsDisplay];
        _lastTimeStep = nextStep;
    }
}

- (void)startLoadingGame {
    self.scoreLabel.text = @"Loading...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [RandomGenerator setSeed:_gameRandomSeed];
        [self newGameData];
        
        // initiate players
        NSAssert(self.gameData.characters.count > 0, @"Not enough characters to start a game!");
        NSInteger playerIndex = -1;
        NSMutableArray *players = [NSMutableArray new];
        if(self.match == nil) {
            playerIndex = 0;
            for(NSInteger i = 0, len = 1; i < len; ++i) {
                JetpackKnightPlayer *player = [[JetpackKnightPlayer alloc] init];
                player.gkPlayer = nil;
                player.playerId = @"1";
                player.character = [[self.gameData.characters objectAtIndex:(i % self.gameData.characters.count)] copy];
                [self.jGameData setCharacter:player.character atPositionIndex:i];
                [players addObject:player];
            }
        } else {
            for(NSInteger i = 0, len = _gamePlayersId.count; i < len; ++i) {
                NSString *playerId = [self.gamePlayersId objectAtIndex:i];
                GKPlayer *gkPlayer = [[self.playersDataById objectForKey:playerId] objectForKey:@"player"];
                if([gkPlayer isKindOfClass:[GKLocalPlayer class]]) {
                    playerIndex = i;
                }
                JetpackKnightPlayer *player = [[JetpackKnightPlayer alloc] init];
                player.gkPlayer = gkPlayer;
                player.playerId = gkPlayer.playerID;
                player.character = [[self.gameData.characters objectAtIndex:(i % self.gameData.characters.count)] copy];
                [self.jGameData setCharacter:player.character atPositionIndex:i];
                [players addObject:player];
            }
        }
        self.jGameData.players = [players copy];
        
        [self initializeGame];
        self.gameController = [[JetpackKnightController alloc] initWithViewController:self];
        self.gameController.playerIndex = playerIndex;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scoreLabel.text = @"";
            [self didLoadGame];
        });
    });
}

- (void)didLoadGame
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(self.match == nil) { // single player
        [self startGame];
    } else {
        if(!_isGameInitiator) {
            [self sendData:[GameNetworkProtocol makePacketWithMessage:GN_READY_TO_START data:nil] toPlayer:_gameInitiatorPlayer];
        } else {
            NSMutableDictionary *playerData = [_playersDataById objectForKey:_localPlayer.playerID];
            [playerData setObject:[NSNumber numberWithBool:YES] forKey:@"ready_to_start"];
            [self gameInitiatorCheckForStartingGame];
        }
    }
}

- (void)newGameData
{
    CGFloat initSpacing = [JetpackKnightGameData initialSpacing];
    CGFloat landEnd = initSpacing + 1000;
    
    JetpackKnightGameData *initialGameData = [JetpackKnightGameData createInitialGameData];
    GameDataGeneratorConfig *genConfig = [JetpackKnightGameData createGeneratorConfigWithGameData:initialGameData];
    genConfig.landStart = initSpacing;
    genConfig.landEnd = landEnd;
    genConfig.groundStart = -initSpacing;
    genConfig.groundEnd = landEnd + initSpacing;
    initialGameData.gameBound = BoundMake(CGPointMake(genConfig.landStart, initialGameData.gameBound.lowerBound.y),
                                          CGPointMake(genConfig.landEnd, initialGameData.gameBound.upperBound.y));
    self.gameData = (id)[GameDataGenerator generateGameDataWithConfig:genConfig initialGameData:initialGameData];
}

- (JetpackKnightGame*)jGame {
    return (JetpackKnightGame*)self.game;
}

- (JetpackKnightGameData*)jGameData {
    return (JetpackKnightGameData*)self.gameData;
}

- (IBAction)didTapMenuButton:(id)sender {
    [_delegate jetpackKnightGameOverBackToMenu:self];
}

- (void)gameDidEnd {
    [self resetGame];
}

- (void)resetGame {
    [self.displayLink invalidate];
    self.game = nil; // remove game
    if(self.match != nil) {
        if(_isGameInitiator) {
            for(NSString *playerId in _playersDataById) {
                NSMutableDictionary *playerData = [_playersDataById objectForKey:playerId];
                [playerData removeObjectForKey:@"ready_to_start"];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startLoadingGame];
    });
}

@end
