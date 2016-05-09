/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameViewController.h"

#define LEAST_WAIT_FOR_UPDATE (1.0 / 30.0)

@interface GameViewController()

@property NSTimeInterval lastApplyUpdateTime;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameView = [GameView new];
    [self.view addSubview:self.gameView];
    [self.view sendSubviewToBack:self.gameView];
    _gameLoopSelector = @selector(gameLoop);
    _gameLoopTimeInterval = LEAST_WAIT_FOR_UPDATE;
}

- (void)dealloc {
    if(!_gameDestroyed)
        [self destroyGame];
}

- (void)destroyGame {
    _gameDestroyed = YES;
    [_displayLink invalidate];
    [_gameLoopTimer invalidate];
    self.game = nil;
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
    _gameDestroyed = NO;
    [self.game start];
    _lastApplyUpdateTime = 0;
    _pauseSimulation = NO;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLoop:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    NSMethodSignature *sig = [self methodSignatureForSelector:_gameLoopSelector];
    NSAssert(sig != nil, @"method signature not found: %@", NSStringFromSelector(_gameLoopSelector));
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:self];
    [inv setSelector:_gameLoopSelector];
    _gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:_gameLoopTimeInterval invocation:inv repeats:YES];
}

- (NSTimeInterval)frameUpdateIntervalWithInterval:(CFTimeInterval)timeInterval {
    return timeInterval;
}

- (void)displayLoop:(CADisplayLink*)displayLink {
    self.gameView.currentInterval = [self frameUpdateIntervalWithInterval:displayLink.duration];
    [self.gameView setNeedsDisplay];
}

- (void)gameLoop
{
    if(!self.pauseSimulation) {
        NSTimeInterval time = [self.game.startDate timeIntervalSinceNow];
        NSTimeInterval interval = -(time + _lastApplyUpdateTime); // sinceNow is decreasing
        [self.game updateWithInterval:interval];
        _lastApplyUpdateTime += interval;
    }
}

- (Class)gameClass
{
    if(_gameClass == nil)
        _gameClass = [Game class];
    return _gameClass;
}

@end
