/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "Game.h"

@protocol GameViewTouchDelegate;

@interface GameView : UIView

@property Game *game;
@property (weak) id<GameViewTouchDelegate> touchDelegate;

@property NSTimeInterval currentInterval;

@end


@protocol GameViewTouchDelegate <NSObject>

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end
