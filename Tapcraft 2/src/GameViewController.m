/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameViewController.h"

#define LEAST_WAIT_FOR_FRAME_UPDATE (1.0 / 30.0)

@interface GameViewController()

@property NSTimeInterval lastFrameUpdateTimeInterval;
@property NSTimeInterval lastApplyUpdateTime;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameView = [GameView new];
    [self.view addSubview:self.gameView];
    [self.view sendSubviewToBack:self.gameView];
    _gameLoopSelector = @selector(gameLoop:);
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)destroyGame {
    [_displayLink invalidate];
}

- (void)viewWillLayoutSubviews {
    CGSize size = self.view.frame.size;
    self.gameView.frame = CGRectMake(0, 0, size.width, size.height);
    if(self.game)
        self.game.viewSize = size;
    self.gameView.currentInterval = 0;
    [self.gameView setNeedsDisplay];
    [super viewWillLayoutSubviews];
}

- (void)initializeGame {
    if(self.game == nil)
        self.game = [[self.gameClass alloc] initWithGameData:self.gameData];
    self.gameView.game = self.game;
    self.game.viewSize = self.gameView.frame.size;
}

- (void)startGame {
    [self.game start];
    _lastApplyUpdateTime = 0;
    _pauseSimulation = NO;
    _lastFrameUpdateTimeInterval = 0;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:_gameLoopSelector];
   // [_displayLink setFrameInterval:1];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)gameLoop:(CADisplayLink*)displayLink
{
    if(!self.pauseSimulation) {
        NSTimeInterval time = [self.game.startDate timeIntervalSinceNow];
        NSTimeInterval interval = -(time + _lastApplyUpdateTime); // sinceNow is decreasing
        [self.game updateWithInterval:interval];
        _lastApplyUpdateTime += interval;
    }
    NSTimeInterval timeInterval = [self.game.startDate timeIntervalSinceNow] * -1;
    if(timeInterval - _lastFrameUpdateTimeInterval > LEAST_WAIT_FOR_FRAME_UPDATE) {
        self.gameView.currentInterval = timeInterval - _lastFrameUpdateTimeInterval;
        [self.gameView setNeedsDisplay];
        _lastFrameUpdateTimeInterval = timeInterval;
    }
}

- (Class)gameClass
{
    if(_gameClass == nil)
        _gameClass = [Game class];
    return _gameClass;
}

@end
