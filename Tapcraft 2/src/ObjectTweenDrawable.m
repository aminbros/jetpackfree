/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "Object.h"
#import "ObjectTweenDrawable.h"

@implementation ObjectTweenDrawable

- (void)drawOnContext:(CGContextRef)context
               object:(GObject*)object
       cameraHalfSize:(CGSize*)cameraHalfSize
         cameraCenter:(CGPoint*)cameraCenter
            cameraFOV:(CGFloat)cameraFOV
                depth:(CGFloat)depth
    timeInterval:(NSTimeInterval)timeInterval
{
    if(!_pause) {
        if(_interval > 1.0 / _fps) {
            NSInteger add = (NSInteger)floor(_interval * _fps);
            _frame += add;
            if(_frame >= _drawables.count) {
                if(_loop != 0) {
                    _frame = _frame % _drawables.count;
                    _loop--;
                } else
                    _frame = _drawables.count - 1;
            }
            _interval -= (CGFloat)add / _fps;
        }
        _interval += timeInterval;
    }
    if(_frame < 0 || _frame >= _drawables.count)
        return;
    id <ObjectDrawable>drawable = _drawables[_frame];
    [drawable drawOnContext:context object:object cameraHalfSize:cameraHalfSize cameraCenter:cameraCenter cameraFOV:cameraFOV depth:depth timeInterval:timeInterval];
}

-(id)copyWithZone:(NSZone *)zone
{
    ObjectTweenDrawable *i = [[[self class] alloc] init];
    i.drawables = _drawables;
    i.interval = _interval;
    i.frame = _frame;
    i.fps = _fps;
    i.loop = _loop;
    i.pause = _pause;
    return i;
}

@end
