/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameData.h"
#import "Camera.h"

@interface Game : NSObject

@property (readonly) GameData *gameData;

@property NSDate *startDate;

@property (readonly) Camera camera;
@property (nonatomic, assign) CGSize viewSize;

- (instancetype)initWithGameData:(GameData*)gameData;
- (NSArray*)objectsToDrawOrdered;
- (void)update;
- (void)start;

@end
