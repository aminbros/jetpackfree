/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Object.h"

#define AVG_SCALE(s) (((s).x + (s).y) / 2.0)

@implementation GObject

- (instancetype)init {
    self = [super init];
    if(self != nil) {
        _density = 0;
        _friction = 0.2;
        _scale.x = 1.0;
        _scale.y = 1.0;
#ifdef DEBUG
        _renderOutlineColor = [UIColor redColor];
#endif
        
        _collisionCategoryBits = 0x0001;
        _collisionMaskBits = 0xFFFF;
        _collisionGroupIndex = 0;
        
        _shapeType = GObjectShapeTypeBox;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    GObject *copyObj = [[[self class] alloc] init];
    copyObj.position = _position;
    copyObj.origin = _origin;
    copyObj.size = _size;
    copyObj.scale = _scale;
    copyObj.zIndex = _zIndex;
    copyObj.drawable = [_drawable copyWithZone:zone];
    copyObj.positionZIndex = _positionZIndex;
    copyObj.bodyType = _bodyType;
    copyObj.density = _density;
    copyObj.friction = _friction;
    copyObj.physicsActive = _physicsActive;
    copyObj.tag = _tag;
    copyObj.angle = _angle;
    copyObj.bodyFixedRotation = _bodyFixedRotation;
    copyObj.isSensor = _isSensor;
    copyObj.renderOutline = _renderOutline;
    copyObj.renderOutlineColor  = _renderOutlineColor;
    copyObj.collisionGroupIndex = _collisionGroupIndex;
    copyObj.collisionMaskBits = _collisionMaskBits;
    copyObj.collisionCategoryBits = _collisionCategoryBits;
    copyObj.shapeType = _shapeType;
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

- (NSComparisonResult)zIndexCompare:(GObject*)other {
    return _zIndex < other.zIndex ? NSOrderedAscending : NSOrderedDescending;
}

- (NSComparisonResult)zIndexCompareRev:(GObject*)other {
    return _zIndex > other.zIndex ? NSOrderedAscending : NSOrderedDescending;
}

-(BOOL)isEqual:(id)object {
    return self == object;
}

-(NSUInteger)hash {
    return (NSUInteger)self;
}

- (CGFloat)scalarMulAvgScale:(CGFloat)scalar {
    return scalar * AVG_SCALE(self.scale);
}

- (CGPoint)pointMulAvgScale:(CGPoint*)point {
    CGFloat avgs = AVG_SCALE(self.scale);
    return CGPointMul(*point, avgs);
}

@end
