/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Game.h"
#import "GameDataGenerator.h"
#import "DynamicRTree.h"
#import "RandomGenerator.h"
#include <stdlib.h>

@implementation ObjectTemplateInfo
@end

@implementation GenerateObjectInfo
@end

@implementation GameDataGeneratorConfig
@end

@implementation GameDataGenerator

+ (void)generateObjectsIn:(NSMutableArray*)objects
       generateObjectInfo:(GenerateObjectInfo*)genObjInfo
                landStart:(CGFloat)landStart
                landEnd:(CGFloat)landEnd
               gameBound:(Bound)gameBound
{
    BOOL protectOverlap = genObjInfo.protectOverlap;
    BOOL protectOverlapY = genObjInfo.protectOverlapY;
    
    __block BOOL overlap;
    DynamicRTreeQueryCallback overlapTestCallback = ^BOOL (NSInteger proxyId) {
        overlap = YES;
        return NO;
    };
    CGFloat x = landStart;
    while(x < landEnd) {

        DynamicRTree *rTree = [[DynamicRTree alloc] init];

        for(NSInteger i = 0; i < genObjInfo.amount; ++i) {
            // pick a template
            ObjectTemplateInfo *templateInfo;
            if(genObjInfo.pickTemplateRandom)
                templateInfo = genObjInfo.templatesInfo[[RandomGenerator intRandomWithOffset:0 limit:genObjInfo.templatesInfo.count]];
            else
                templateInfo = genObjInfo.templatesInfo[i % genObjInfo.templatesInfo.count];

            GObject *object = [templateInfo.object copy];
            // set position and apply variants by
            // trying to find the right position
            NSInteger maxTry = 4;
            NSInteger tryLen = 0;
            while(tryLen < maxTry) {
                CGFloat scaleAdd = [RandomGenerator floatRandomWithMax:templateInfo.scaleVariant * 2] - templateInfo.scaleVariant;
                object.scale = CGPointMake(object.scale.x + scaleAdd, object.scale.y + scaleAdd);
                Bound relBound = [object computeBoundRelativeToPosition];
                CGFloat newX = x + [RandomGenerator floatRandomWithMax:genObjInfo.every - relBound.upperBound.x] - relBound.lowerBound.x;
                object.position = CGPointMake(newX, object.position.y + [RandomGenerator floatRandomWithMax:templateInfo.positionYVariant] - templateInfo.positionYVariant / 2.0);
                if(protectOverlap || protectOverlapY) {
                    Bound objBound = [object computeBound];
                    Bound bound = BoundExtend(&objBound, genObjInfo.overlapCheckExtend);
                    overlap = NO;
                    if(protectOverlapY) {
                        Bound boundForY = BoundMake(CGPointMake(bound.lowerBound.x, gameBound.lowerBound.y),
                                                    CGPointMake(bound.upperBound.x, gameBound.upperBound.y));
                        [rTree queryForBound:&boundForY callback:overlapTestCallback];
                    }
                    if(!overlap && protectOverlap) {
                        [rTree queryForBound:&bound callback:overlapTestCallback];
                    }
                    if(overlap) {
                        tryLen++;
                        continue;
                    }
                    [rTree createProxyWithBound:&bound userData:(__bridge void *)(object)];
                }
                break;
            }
            if(overlap)
                continue;
            [objects addObject:object];
        }
        
        x += genObjInfo.every;
    }
}
    

+ (GameData*)generateGameDataWithConfig:(GameDataGeneratorConfig*)config initialGameData:(GameData*)initialGameData;
{
    GameData *gd = [initialGameData copy];
    NSMutableArray *objects = [gd.objects mutableCopy];

    CGFloat groundEnd = config.groundEnd;
    // build ground
    CGFloat x = config.groundStart;
    NSString  *groundTag = config.groundTag;
    CGFloat groundY = config.groundY;
    CGFloat groundHeight = config.groundHeight;
    CGFloat groundPieceWidth = config.groundPieceWidth;
    id <ObjectDrawable>groundDrawable = config.groundDrawable;
    while(x < groundEnd) {
        GObject *groundPiece = [[GObject alloc] init];
        groundPiece.tag = groundTag;
        groundPiece.position = CGPointMake(x, groundY);
        groundPiece.origin = CGPointMake(0, groundHeight); // at top of ground
        groundPiece.size = CGSizeMake(groundPieceWidth, groundHeight);
        groundPiece.drawable = groundDrawable;
        groundPiece.bodyType = BodyTypeStatic;
        groundPiece.shapeType = GObjectShapeTypeTopEdge;
        groundPiece.physicsActive = YES;
        [objects addObject:groundPiece];
        x += groundPieceWidth;
    }

    // generate objects
    NSArray *genObjInfoList = [@[ config.genDiamondInfo, config.genObstacleInfo, config.genRocketInfo ] arrayByAddingObjectsFromArray:config.genTilesInfo];

    for(GenerateObjectInfo *genObjInfo in genObjInfoList) {
        [self generateObjectsIn:objects
             generateObjectInfo:genObjInfo
                      landStart:config.landStart
                      landEnd:config.landEnd
                      gameBound:gd.gameBound];
    }
    gd.objects = [objects copy];
    return gd;
}

@end
