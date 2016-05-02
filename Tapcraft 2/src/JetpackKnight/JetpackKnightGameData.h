/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameData.h"
#import "GameDataGenerator.h"
#import "ObjectImageDrawable.h"

extern NSString * const JetpackKnightDiamondTag;
extern NSString * const JetpackKnightRocketTag;
extern NSString * const JetpackKnightObstacleTag;
extern NSString * const JetpackKnightGroundTag;


@interface JetpackKnightGameData : GameData

@property NSArray *diamondsObjectTemplate;
@property NSArray *rocketsObjectTemplate;
@property NSArray *obstaclesObjectTemplate;
@property NSArray *treesObjectTemplate;
@property NSArray *cloudsObjectTemplate;
@property NSArray *buildingsObjectTemplate;

@property CGFloat groundY;
@property CGSize groundSize;
@property NSString *groundTag;
@property ObjectImageDrawable *groundDrawable;

@property NSArray *players;

+ (GameDataGeneratorConfig*)createGeneratorConfigWithGameData:(JetpackKnightGameData*)gd landStart:(CGFloat)landStart landEnd:(CGFloat)landEnd;
+ (JetpackKnightGameData*)createInitialGameData;

@end
