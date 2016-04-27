/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameData.h"
#import "GameDataGenerator.h"
#import "ObjectImageDrawable.h"

extern const NSString *JetpackKnightDiamondTag;
extern const NSString *JetpackKnightRocketTag;
extern const NSString *JetpackKnightObstacleTag;

@interface JetpackKnightGameData : GameData

@property NSArray *diamondsObjectTemplate;
@property NSArray *rocketsObjectTemplate;
@property NSArray *obstaclesObjectTemplate;
@property NSArray *treesObjectTemplate;
@property NSArray *cloudsObjectTemplate;
@property NSArray *buildingsObjectTemplate;

@property CGFloat groundY;
@property CGSize groundSize;
@property ObjectImageDrawable *groundDrawable;

+ (GameDataGeneratorConfig*)createGeneratorConfigWithGameData:(JetpackKnightGameData*)gd landStart:(CGFloat)landStart landEnd:(CGFloat)landEnd;
+ (JetpackKnightGameData*)createInitialGameData;

@end
