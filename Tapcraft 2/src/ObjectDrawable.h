/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "Camera.h"

@class GObject;

@protocol ObjectDrawable <NSObject>

- (void)drawOnContext:(CGContextRef)context
               object:(GObject*)object
           cameraHalfSize:(CGSize*)cameraHalfSize
           cameraCenter:(CGPoint*)cameraCenter
            cameraFOV:(CGFloat)cameraFOV
                depth:(CGFloat)depth
        timeInterval:(NSTimeInterval)timeInterval;
- (id)copyWithZone:(NSZone *)zone;

@end
