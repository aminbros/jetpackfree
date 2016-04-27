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
    
    // translate to origin
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeTranslation(-object.origin.x, -object.origin.y));
    
    // scale 
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(object.scale.x, object.scale.y));
    
    // correct y position to fit in place
    CGPoint position = CGPointMake(object.position.x,
                                   object.position.y * depth + (1-depth) * cameraCenter->y);
    
    // translate to position
    CGAffineTransform transform2 = CGAffineTransformMakeTranslation
                          (position.x - cameraCenter->x,
                           position.y - cameraCenter->y);
    // depth effect
    transform2 = CGAffineTransformConcat(transform2, CGAffineTransformMakeScale(1.0/depth, 1.0/depth));
    
    
    transform2 =  CGAffineTransformConcat(transform2, CGAffineTransformMakeTranslation
                                         (cameraHalfSize->width, cameraHalfSize->height));
    
    // combine transforms
    transform = CGAffineTransformConcat(transform, transform2);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(_imageRect.origin.x, _imageRect.origin.y, _imageRect.size.width, _imageRect.size.height), _image.CGImage);
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
