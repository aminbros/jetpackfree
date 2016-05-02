/*
 * Author: Hossein Amin, aminbros.com
 */

#import "ObjectImageDrawable.h"

@implementation ObjectImageDrawable

- (void)drawOnContext:(CGContextRef)context
               object:(Object*)object
           cameraHalfSize:(CGSize*)cameraHalfSize
           cameraCenter:(CGPoint*)cameraCenter
            cameraFOV:(CGFloat)cameraFOV
                depth:(CGFloat)depth
    timeInterval:(NSTimeInterval)timeInterval
{
    // CGContextConcatCTM
    CGContextSaveGState(context);
    
    // translate to origin
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeTranslation(-object.origin.x, -object.origin.y));
    
    // scale 
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(object.scale.x, object.scale.y));
    // rotate
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(object.angle));
    
    // correct y position to fit in place
    CGPoint position = CGPointMake(object.position.x,
                                   object.position.y * depth + (1-depth) * cameraCenter->y);
    
    // translate to position
    CGAffineTransform transform2 = CGAffineTransformMakeTranslation
                          (position.x - cameraCenter->x,
                           position.y - cameraCenter->y);
    // depth effect
    transform2 = CGAffineTransformConcat(transform2, CGAffineTransformMakeScale(1.0/depth/cameraFOV, 1.0/depth/cameraFOV));
    
    
    transform2 =  CGAffineTransformConcat(transform2, CGAffineTransformMakeTranslation
                                         (cameraHalfSize->width/cameraFOV, cameraHalfSize->height/cameraFOV));
    
    // combine transforms
    transform = CGAffineTransformConcat(transform, transform2);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, _imageRect, _image.CGImage);
#ifdef DEBUG
    if(object.renderOutline) {
        CGContextSetStrokeColorWithColor(context, object.renderOutlineColor.CGColor);
        CGContextStrokeRectWithWidth(context, CGRectMake(0, 0, object.size.width, object.size.height), 1.0 / 70.0);
    }
#endif
    CGContextRestoreGState(context);
}

-(id)copyWithZone:(NSZone *)zone
{
    ObjectImageDrawable *i = [[[self class] alloc] init];
    i.image = _image;
    i.imageRect = _imageRect;
    return i;
}

@end
