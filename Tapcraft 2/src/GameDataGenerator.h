/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameData.h"

@interface ObjectTemplateInfo : NSObject

@property Object *object;
@property CGFloat positionYVariant;
@property CGFloat scaleVariant;

@end

@interface GenerateObjectInfo : NSObject

@property NSInteger amount;
@property CGFloat every;
@property BOOL protectOverlapY;
@property BOOL protectOverlap;
@property CGFloat overlapCheckExtend;
@property NSArray *templatesInfo; // count should be bigger than zero
@property BOOL pickTemplateRandom;

@end

@interface GameDataGeneratorConfig : NSObject

@property CGFloat landStart;
@property CGFloat landEnd;

// chance for inserting object on land
@property GenerateObjectInfo *genDiamondInfo;
@property GenerateObjectInfo *genObstacleInfo;
@property GenerateObjectInfo *genRocketInfo;
@property NSArray *genTilesInfo;

// for ground tile & physics
@property CGFloat groundY;
@property CGFloat groundHeight;
@property CGFloat groundPieceWidth;
@property NSString *groundTag;
@property id <ObjectDrawable>groundDrawable;

@end

@interface GameDataGenerator : NSObject

+ (GameData*)generateGameDataWithConfig:(GameDataGeneratorConfig*)config initialGameData:(GameData*)initialGameData;

@end
