/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "ObjectDrawable.h"
#import "Bound.h"

typedef NS_ENUM(NSInteger, BodyType) {
    BodyTypeStatic = 0,
    BodyTypeKinematic,
    BodyTypeDynamic
};

@interface Object : NSObject

@property CGPoint position;
@property CGPoint origin;
@property CGPoint scale;
@property CGSize size;
@property NSInteger zIndex; // helper for drawing in order
@property id<ObjectDrawable> drawable;
@property NSInteger positionZIndex;
@property CGFloat angle;

@property BodyType bodyType;
@property CGFloat density; // The density, usually in kg/m^2.
@property CGFloat friction; // the friction coefficient
@property BOOL bodyFixedRotation;
@property BOOL isSensor;
// Not active object is not simulated and cannot be collided
@property BOOL physicsActive;

@property id tag;

@property id objectGameInfo; // used in Game class

#ifdef DEBUG
// debug properties
@property BOOL renderOutline;
@property UIColor *renderOutlineColor;
#endif

- (Bound)computeBound;
- (Bound)computeBoundRelativeToPosition;

- (NSComparisonResult)zIndexCompare:(Object*)other;
- (NSComparisonResult)zIndexCompareRev:(Object*)other;

-(id)copyWithZone:(NSZone *)zone;

-(BOOL)isEqual:(id)object;
-(NSUInteger)hash;

@end
