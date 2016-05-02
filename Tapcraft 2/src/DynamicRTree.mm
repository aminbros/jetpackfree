/*
 * Author: Hossein Amin, aminbros.com
 */

#import "DynamicRTree.h"
#include <Box2D/Collision/b2DynamicTree.h>
#include "Box2DConv.h"

class QueryCallbackClass
{
 public:
    bool QueryCallback(int32 nodeId);
    void *block;
};

bool QueryCallbackClass::QueryCallback(int32 nodeId) {
    DynamicRTreeQueryCallback callback = (__bridge DynamicRTreeQueryCallback)block;
    return (bool)callback(nodeId);
}
void *userData;

@interface DynamicRTree()

@property b2DynamicTree *b2DTree;

@end

@implementation DynamicRTree

- (instancetype)init {
    self = [super init];
    if(self != nil) {
        _b2DTree = new b2DynamicTree();
    }
    return self;
}

- (void)dealloc {
    delete _b2DTree;
}

- (NSInteger)createProxyWithBound:(Bound*)bound userData:(void*)userData {
    b2AABB aabb;
    write_Bound_to_b2AABB(*bound, aabb);
    return (NSInteger)_b2DTree->CreateProxy(aabb, userData);
}

- (void)destroyProxyWithId:(NSInteger)proxyId {
	_b2DTree->DestroyProxy((int32)proxyId);
}

- (BOOL)moveProxyWithId:(NSInteger)proxyId bound:(Bound*)bound displacement:(CGPoint*)displacement {
    b2AABB aabb;
    b2Vec2 dispVec;
    write_Bound_to_b2AABB(*bound, aabb);
    write_CGPoint_to_b2Vec2(*displacement, dispVec);
	return _b2DTree->MoveProxy((int32)proxyId, aabb, dispVec);
}

- (void*)getUserDataWithProxyId:(NSInteger)proxyId {
	return _b2DTree->GetUserData((int32)proxyId);
}

- (void)queryForBound:(Bound*)bound callback:(DynamicRTreeQueryCallback)callback {
    b2AABB aabb;
	QueryCallbackClass qcb;
    qcb.block = (__bridge void*)callback;
    write_Bound_to_b2AABB(*bound, aabb);
    _b2DTree->Query(&qcb, aabb);
}


@end
