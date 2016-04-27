
/*
 * Author: Hossein Amin, aminbros.com
 */

#import "JetpackKnightViewController.h"
#import "JetpackKnightGameData.h"
#import "GameDataGenerator.h"

@interface JetpackKnightViewController()

@property JetpackKnightGameData *jgameData;

@end

@implementation JetpackKnightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self newGameData];
            self.gameData = _jgameData;
            [self initializeGame];
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
    CGFloat landEnd = 100;
    
    JetpackKnightGameData *initialGameData = [JetpackKnightGameData createInitialGameData];
    GameDataGeneratorConfig *genConfig = [JetpackKnightGameData createGeneratorConfigWithGameData:initialGameData landStart:landStart landEnd:landEnd];
    initialGameData.gameBound = BoundMake(CGPointMake(landStart, initialGameData.gameBound.lowerBound.y),
                                          CGPointMake(landEnd, initialGameData.gameBound.upperBound.y));
    _jgameData = (id)[GameDataGenerator generateGameDataWithConfig:genConfig initialGameData:initialGameData];
    
}

@end
