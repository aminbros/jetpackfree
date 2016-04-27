/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameViewController.h"

#define LEAST_WAIT_FOR_FRAME_UPDATE (1.0 / 30.0)

@interface GameViewController()

@property CADisplayLink *displayLink;
@property NSTimeInterval lastFrameUpdateTimeInterval;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameView = [GameView new];
    [self.view addSubview:self.gameView];
}

- (void)dealloc {
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
    self.game = [[Game alloc] initWithGameData:self.gameData];
    self.gameView.game = self.game;
    self.game.viewSize = self.gameView.frame.size;
}

- (void)startGame {
    [self.game start];
    _lastFrameUpdateTimeInterval = 0;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop:)];
   // [_displayLink setFrameInterval:1];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)gameLoop:(CADisplayLink*)displayLink
{
    [self.game update];
    NSTimeInterval timeInterval = [self.game.startDate timeIntervalSinceNow] * -1;
    if(timeInterval - _lastFrameUpdateTimeInterval > LEAST_WAIT_FOR_FRAME_UPDATE) {
        self.gameView.currentInterval = timeInterval - _lastFrameUpdateTimeInterval;
        [self.gameView setNeedsDisplay];
        _lastFrameUpdateTimeInterval = timeInterval;
    }
}

@end
