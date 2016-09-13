/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameData.h"
#import "GameDataGenerator.h"
#import "ObjectImageDrawable.h"
#import "Character.h"

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

@property CGFloat distantGroundY;
@property CGFloat groundY;
@property CGSize groundSize;
@property NSString *groundTag;
@property ObjectImageDrawable *groundDrawable;

@property CGPoint characterPinOffset;
@property NSArray *players;

+ (GameDataGeneratorConfig*)createGeneratorConfigWithGameData:(JetpackKnightGameData*)gd;
+ (JetpackKnightGameData*)createInitialGameData;

+ (CGFloat)initialSpacing;

- (void)setCharacter:(Character*)character atPositionIndex:(NSInteger)index;

@end
