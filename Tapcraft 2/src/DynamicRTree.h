/*
 * Author: Hossein Amin, aminbros.com
 */

#import <UIKit/UIKit.h>
#import "Bound.h"
typedef BOOL(^DynamicRTreeQueryCallback)(NSInteger proxyId);

@interface DynamicRTree : NSObject

- (NSInteger)createProxyWithBound:(Bound*)bound userData:(void*)userData;
- (void)destroyProxyWithId:(NSInteger)proxyId;
- (BOOL)moveProxyWithId:(NSInteger)proxyId bound:(Bound*)bound displacement:(CGPoint*)displacement;
- (void*)getUserDataWithProxyId:(NSInteger)proxyId;
- (void)queryForBound:(Bound*)bound callback:(DynamicRTreeQueryCallback)callback;

@end
