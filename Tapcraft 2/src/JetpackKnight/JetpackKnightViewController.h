/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameViewController.h"
#import "JetpackKnightGame.h"
#import <GameKit/GameKit.h>

// network debug features
// #define GAME_INITIATOR_PLAYER_ID @"G:518307141" // AB iPad
// #define GAME_INITIATOR_PLAYER_ID @"G:1829098565" // simulator


@protocol JetpackKnightViewControllerDelegate;

@interface JetpackKnightViewController : GameViewController

@property (nonatomic) GKMatch *match;

@property (nonatomic,weak) JetpackKnightGame *jGame;
@property (nonatomic,weak) JetpackKnightGameData *jGameData;

@property (nonatomic,weak) id<JetpackKnightViewControllerDelegate> delegate;

- (void)sendDataToAll:(NSData*)data;
- (void)gameDidEnd;

@property (weak, nonatomic) IBOutlet UIButton *leftShootButton;
@property (weak, nonatomic) IBOutlet UIButton *rightShootButton;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UIButton *gameOverMenuButton;

@property NSInteger lastSentCommitTimeStep;


@end


@protocol JetpackKnightViewControllerDelegate<NSObject>

- (void)jetpackKnightGameOverBackToMenu:(JetpackKnightViewController*)vc;

@end