/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Object.h"
#import "ObjectImageDrawable.h"
#import "ObjectTweenDrawable.h"

@interface Character : Object

@property ObjectImageDrawable *standDrawable;
@property ObjectTweenDrawable *runningDrawable;
@property ObjectTweenDrawable *flyingDrawable;
@property ObjectTweenDrawable *explosionDrawable;

@end
