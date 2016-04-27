/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "Object.h"
#import "ObjectDrawable.h"

#define ObjectImageDrawableInfinite -1

@interface ObjectTweenDrawable : NSObject<ObjectDrawable>

@property NSArray *drawables; // array of ObjectDrawable
@property NSTimeInterval interval;
@property NSInteger frame; // current fame index
@property CGFloat fps; // frame per second
@property NSInteger loop; // -1 equals to endless loop
@property BOOL pause;

@end
