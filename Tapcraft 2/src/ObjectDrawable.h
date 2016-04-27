/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "Camera.h"

@class Object;

@protocol ObjectDrawable <NSObject>

- (void)drawOnContext:(CGContextRef)context
               object:(Object*)object
           cameraHalfSize:(CGSize*)cameraHalfSize
           cameraCenter:(CGPoint*)cameraCenter
                depth:(CGFloat)depth
        timeInterval:(NSTimeInterval)timeInterval;
- (id)copyWithZone:(NSZone *)zone;

@end
