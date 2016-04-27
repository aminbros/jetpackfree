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

- (void)initializeGame;
- (void)startGame;

@end
