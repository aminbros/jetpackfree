/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "GameData.h"
#import "Game.h"
#import "GameView.h"

@interface GameViewController : UIViewController

@property GameData *gameData;
@property Game *game;
@property GameView *gameView;
@property (nonatomic) Class gameClass;

@property BOOL pauseSimulation;

- (void)initializeGame;
- (void)startGame;

@end
