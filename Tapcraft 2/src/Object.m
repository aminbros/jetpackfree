/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Object.h"

@implementation Object

- (instancetype)init {
    self = [super init];
    if(self != nil) {
        _density = 0;
        _friction = 0.2;
        _scale.x = 1.0;
        _scale.y = 1.0;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    Object *copyObj = [[[self class] alloc] init];
    copyObj.position = _position;
    copyObj.origin = _origin;
    copyObj.size = _size;
    copyObj.scale = _scale;
    copyObj.zIndex = _zIndex;
    copyObj.drawable = [_drawable copyWithZone:zone];
    copyObj.positionZIndex = _positionZIndex;
    copyObj.physicsNeedsUpdate = YES;
    copyObj.bodyType = _bodyType;
    copyObj.density = _density;
    copyObj.friction = _friction;
    copyObj.physicsActive = _physicsActive;
    copyObj.tag = _tag;
    return copyObj;
}

- (Bound)computeBound
{
    CGFloat px = _position.x;
    CGFloat py = _position.y;
    return BoundMakeWS(-_origin.x * _scale.x + px, // left
                       -_origin.y * _scale.y + py, // bottom
                       (_size.width - _origin.x) * _scale.x + px, //right
                       (_size.height - _origin.y) * _scale.y + py); // top
}

- (Bound)computeBoundRelativeToPosition
{
    return BoundMakeWS(-_origin.x * _scale.x, // left
                       -_origin.y * _scale.y, // bottom
                       (_size.width - _origin.x) * _scale.x, //right
                       (_size.height - _origin.y) * _scale.y); // top
}

- (NSComparisonResult)zIndexCompare:(Object*)other {
    return _zIndex < other.zIndex ? NSOrderedAscending : NSOrderedDescending;
}

- (NSComparisonResult)zIndexCompareRev:(Object*)other {
    return _zIndex > other.zIndex ? NSOrderedAscending : NSOrderedDescending;
}

@end
