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

@property CADisplayLink *displayLink;
@property SEL gameLoopSelector;
@property BOOL pauseSimulation;

- (void)destroyGame;
- (void)initializeGame;
- (void)startGame;

- (void)gameLoop:(CADisplayLink*)displayLink;

@end
