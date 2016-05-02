
/*
 * Author: Hossein Amin, aminbros.com
 */

#import "JetpackKnightViewController.h"
#import "JetpackKnightGameData.h"
#import "GameDataGenerator.h"
#import "JetpackKnightController.h"

@interface JetpackKnightViewController()

@property JetpackKnightController *gameController;
           
@end

@implementation JetpackKnightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gameClass = [JetpackKnightGame class];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self newGameData];
        
            // initiate players
            NSMutableArray *players = [NSMutableArray new];
            for(Character *character in self.gameData.characters) {
                JetpackKnightPlayer *player = [[JetpackKnightPlayer alloc] init];
                player.character = [character copy];
                [players addObject:player];
            }
            NSAssert(players.count > 0, @"Not enough characters to start a game!");
            self.jGameData.players = [players copy];
            [self initializeGame];
            self.gameController = [[JetpackKnightController alloc] initWithViewController:self];
            self.gameController.playerIndex = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                    [self didLoadGame];
                });
        });
}

- (void)didLoadGame
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self startGame];
}

- (void)newGameData
{
    CGFloat landStart = 0;
    CGFloat landEnd = 1000;
    
    JetpackKnightGameData *initialGameData = [JetpackKnightGameData createInitialGameData];
    GameDataGeneratorConfig *genConfig = [JetpackKnightGameData createGeneratorConfigWithGameData:initialGameData landStart:landStart landEnd:landEnd];
    initialGameData.gameBound = BoundMake(CGPointMake(landStart, initialGameData.gameBound.lowerBound.y),
                                          CGPointMake(landEnd, initialGameData.gameBound.upperBound.y));
    self.gameData = (id)[GameDataGenerator generateGameDataWithConfig:genConfig initialGameData:initialGameData];
    
}

- (JetpackKnightGame*)jGame {
    return (JetpackKnightGame*)self.game;
}

- (JetpackKnightGameData*)jGameData {
    return (JetpackKnightGameData*)self.gameData;
}

@end
