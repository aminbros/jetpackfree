/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "Object.h"
#import "ObjectDrawable.h"

@interface ObjectImageDrawable : NSObject<ObjectDrawable>

@property UIImage *image;
@property CGRect imageRect;

@end
