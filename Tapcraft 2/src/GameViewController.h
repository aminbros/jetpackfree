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

@property NSTimeInterval gameLoopTimeInterval;
@property NSTimer *gameLoopTimer;

@property BOOL gameDestroyed;

- (void)destroyGame;
- (void)initializeGame;
- (void)startGame;


- (NSTimeInterval)frameUpdateIntervalWithInterval:(CFTimeInterval)timeInterval;
- (void)gameLoop;

@end
