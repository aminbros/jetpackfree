/*
 * Author: Hossein Amin, aminbros.com
 */

#import "ObjectImageDrawable.h"

@implementation ObjectImageDrawable

- (void)drawOnContext:(CGContextRef)context
               object:(Object*)object
           cameraHalfSize:(CGSize*)cameraHalfSize
           cameraCenter:(CGPoint*)cameraCenter
               depth:(CGFloat)depth
    timeInterval:(NSTimeInterval)timeInterval
{
    // CGContextConcatCTM
    CGContextSaveGState(context);
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // translate to originn
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-object.origin.x, -object.origin.y));

    // scale 
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(object.scale.x, object.scale.y));

    // translate to position
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation
                          (object.position.x + cameraHalfSize->width - cameraCenter->x + _imageRect.origin.x,
                           object.position.y + cameraHalfSize->height - cameraCenter->y + _imageRect.origin.y));
    
    
    // depth effect
    //transform2 = CGAffineTransformConcat(transform2, CGAffineTransformMakeScale(1.0/depth, 1.0/depth));
    
    //transform = CGAffineTransformConcat(transform, transform2);
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, _imageRect.size.width, _imageRect.size.height), _image.CGImage);
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
