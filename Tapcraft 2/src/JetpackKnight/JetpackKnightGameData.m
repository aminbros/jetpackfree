/*
 * Author: Hossein Amin, aminbros.com
 */

#import "JetpackKnightGameData.h"
#import "Character.h"
#import "GameDataGenerator.h"

#define RASTER_SCALE (1/320.0)

const NSString *JetpackKnightDiamondTag = @"diamond";
const NSString *JetpackKnightRocketTag = @"rocket";
const NSString *JetpackKnightObstacleTag = @"obstacle";

@implementation JetpackKnightGameData

+ (GameDataGeneratorConfig*)createGeneratorConfigWithGameData:(JetpackKnightGameData*)gd landStart:(CGFloat)landStart landEnd:(CGFloat)landEnd
{
    GameDataGeneratorConfig *c = [[GameDataGeneratorConfig alloc] init];
    c.landStart = landStart;
    c.landEnd = landEnd;

    CGFloat freeArea = gd.gameBound.upperBound.y - gd.groundY;
    // diamonds
    GenerateObjectInfo *goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.diamondsObjectTemplate
                                   position:CGPointMake(0, gd.groundY + freeArea / 2.0)
                           positionYVariant:freeArea / 2.0 - 0.1
                               scaleVaraint:0];
    goi.every = 5;
    goi.amount = 9;
    goi.protectOverlap = YES;
    goi.pickTemplateRandom = YES;
    c.genDiamondInfo = goi;

    
    // rocket
    goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.rocketsObjectTemplate
                                   position:CGPointMake(0, gd.groundY + freeArea / 2.0)
                           positionYVariant:freeArea / 2.0 - 0.1
                               scaleVaraint:0];
    goi.every = 5;
    goi.amount = 2;
    goi.protectOverlap = YES;
    goi.pickTemplateRandom = YES;
    c.genRocketInfo = goi;

    
    // obstacle
    goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.obstaclesObjectTemplate
                           positionYVariant:0
                               scaleVaraint:0.0];
    goi.every = 10;
    goi.amount = 4;
    goi.protectOverlap = YES;
    goi.pickTemplateRandom = YES;
    c.genObstacleInfo = goi;

    NSMutableArray *genTilesInfo = [NSMutableArray new];
    CGFloat maxWidth;
    // trees
    goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.treesObjectTemplate
                           positionYVariant:0
                               scaleVaraint:0];
    maxWidth = 1;
    for(Object *object in gd.treesObjectTemplate) {
        if(object.size.width > maxWidth)
            maxWidth = object.size.width;
    }
    goi.every = maxWidth + 3;
    goi.amount = 1;
    goi.pickTemplateRandom = YES;
    [genTilesInfo addObject:goi];

    // buildings
    goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.buildingsObjectTemplate
                           positionYVariant:0
                               scaleVaraint:0];
    maxWidth = 1;
    for(Object *object in gd.buildingsObjectTemplate) {
        if(object.size.width > maxWidth)
            maxWidth = object.size.width;
    }
    goi.every = maxWidth + 5;
    goi.amount = 1;
    goi.pickTemplateRandom = YES;
    [genTilesInfo addObject:goi];

    // clouds
    goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.cloudsObjectTemplate
                                   position:CGPointMake(0, 0.8)
                           positionYVariant:0.1
                               scaleVaraint:0.1];
    goi.every = 10;
    goi.amount = 1;
    goi.pickTemplateRandom = YES;
    [genTilesInfo addObject:goi];

    c.genTilesInfo = [genTilesInfo copy];

    // ground
    c.groundY = gd.groundY;
    c.groundHeight = gd.groundSize.height;
    c.groundPieceWidth = gd.groundSize.width - (1 * RASTER_SCALE);
    c.groundDrawable = gd.groundDrawable;

    return c;
}

+ (JetpackKnightGameData*)createInitialGameData
{
    JetpackKnightGameData *gd = [[JetpackKnightGameData alloc] init];
    gd.runningSpeed = 1.0;
    gd.runningSpeedUpStep = 0.05;
    gd.runningSpeedUpEvery = 1;
    gd.gameBound = BoundMakeWS(0, 0, 0, 1.0);
    gd.initialCamera = CameraMakeA(CameraFOVDirectionVertical, 1.0, CGPointMake(1.0, 0.5));
    gd.positionZs = @[@1, @1.7, @3, @10];
    NSMutableArray *characters = [NSMutableArray new];

    gd.groundDrawable = [self objectImageDrawableWithName:@"ground.png"];
    gd.groundSize = gd.groundDrawable.imageRect.size;
    gd.groundY = gd.groundDrawable.imageRect.size.height;
     
    // add game data resources and drawables
    [characters addObject:[self mkCharacterA:gd]];
    gd.treesObjectTemplate = [self mkTreesTemplate:gd];
    gd.buildingsObjectTemplate = [self mkBuildingsTemplate:gd];
    gd.cloudsObjectTemplate = [self mkCloudsTemplate:gd];
    
    gd.diamondsObjectTemplate = [self mkDiamondsTemplate:gd];
    gd.rocketsObjectTemplate = [self mkRocketsTemplate:gd];
    gd.obstaclesObjectTemplate = [self mkObstaclesTemplate:gd];

    gd.backgroundImage = [UIImage imageNamed:@"blueBackgroundSky.png"];
    
    gd.objects = [NSArray new];
    gd.characters = [characters copy];

    // decrease drawn objects for testing
    // gd.positionZs = @[@1,@1.7,@3,@10];

    return gd;
}

+ (NSArray*)mkTreesTemplate:(JetpackKnightGameData*)gd {   
    Object *o = [[Object alloc] init];
    o.position = CGPointMake(0, gd.groundY);
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"land1.png"] origin:@"bottom"];
    o.zIndex = -2;
    o.positionZIndex = 1;
    // scale up to get the same size
    CGFloat scale = [[gd.positionZs objectAtIndex:o.positionZIndex] doubleValue];
    o.scale = CGPointMake(scale, scale);
    return @[o];
}

+ (NSArray*)mkBuildingsTemplate:(JetpackKnightGameData*)gd {   
    Object *o = [[Object alloc] init];
    o.position = CGPointMake(0, gd.groundY);
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"mountain.png"] origin:@"bottom"];
    o.zIndex = -3;
    o.positionZIndex = 2;
    // scale up to get the same size
    CGFloat scale = [[gd.positionZs objectAtIndex:o.positionZIndex] doubleValue];
    o.scale = CGPointMake(scale, scale);
    return @[o];
}

+ (NSArray*)mkCloudsTemplate:(JetpackKnightGameData*)gd {
    
    Object *o = [[Object alloc] init];
    o.position = CGPointMake(0, 0.8);
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"cloud.png"] origin:@"center"];
    o.zIndex = -4;
    o.positionZIndex = 3;
    // scale up to get the same size
    CGFloat scale = [[gd.positionZs objectAtIndex:o.positionZIndex] doubleValue];
    o.scale = CGPointMake(scale, scale);
    return @[o];
}

+ (NSArray*)mkDiamondsTemplate:(JetpackKnightGameData*)gd {
    Object *o = [[Object alloc] init];
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"diamond.png"] origin:@"center"];
    o.zIndex = 1;
    o.bodyType = BodyTypeStatic;
    o.physicsActive = YES;
    o.tag = JetpackKnightDiamondTag;
    return @[o];
}


+ (NSArray*)mkRocketsTemplate:(JetpackKnightGameData*)gd {
    Object *o = [[Object alloc] init];
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"rocket.png"] origin:@"center"];
    o.zIndex = 1;
    o.bodyType = BodyTypeStatic;
    o.physicsActive = YES;
    o.tag = JetpackKnightRocketTag;
    return @[o];
}

+ (NSArray*)mkObstaclesTemplate:(JetpackKnightGameData*)gd {
    NSMutableArray *ret = [NSMutableArray new];
    for(NSInteger i = 1; i <= 2; ++i) { 
        Object *o = [[Object alloc] init];
        o.position = CGPointMake(0, gd.groundY);
        [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:[NSString stringWithFormat:@"block%zd.png", i]] origin:@"bottom"];
        o.zIndex = 1;
        o.bodyType = BodyTypeStatic;
        o.physicsActive = YES;
        o.tag = JetpackKnightObstacleTag;
        [ret addObject:o];
    }         
    return [ret copy];
}

+ (Character*)mkCharacterA:(JetpackKnightGameData*)gd
{
    Character *c = [[Character alloc] init];
    
    c.standDrawable = [self objectImageDrawableWithName:@"character1.png"];
    // initialize character size and origin according to "character1.png"
    [self defineObjectDimeAndDrawable:c withObjectImageDrawable:c.standDrawable origin:@"bottom"];
    c.zIndex = 2;
    c.bodyType = BodyTypeKinematic;
    c.physicsActive = YES;
    
    // running drawable
    NSArray *tweenPropsInfo =
        @[
          @{
              @"property": @"runningDrawable",
              @"fps": @15,
              @"loop": @(ObjectImageDrawableInfinite),
              @"nameFormat": @"character%@.png",
              @"framesNameArg1": @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"7",@"6",@"5",@"4",@"3",@"2",@"1"],
              @"origin": @"bottom"
          },
          @{
              @"property": @"flyingDrawable",
              @"fps": @15,
              @"loop": @(ObjectImageDrawableInfinite),
              @"nameFormat": @"rocket%@.png",
              @"framesNameArg1": @[@"0",@"1",@"2",@"3",@"4",@"5",@"4",@"3",@"2",@"1",@"0"],
              @"origin": @"bottom"
          },
          @{
              @"property": @"explosionDrawable",
              @"fps": @15,
              @"loop": @0,
              @"nameFormat": @"fire%@.png",
              @"framesNameArg1": @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"],
              @"origin": @"bottom"
          },
          ];
    for(NSDictionary *tweenPropInfo in tweenPropsInfo) {
        [c setValue:[self objectTweenDrawableWithDef1:tweenPropInfo]
             forKey:[tweenPropInfo objectForKey:@"property"]];
    }
    return c;
}

+ (ObjectImageDrawable*)objectImageDrawableWithName:(NSString*)name
{
    ObjectImageDrawable *oid = [[ObjectImageDrawable alloc] init];
    oid.image = [UIImage imageNamed:name];
    CGRect rect;
    rect.size = CGSizeMul(oid.image.size, RASTER_SCALE);
    rect.origin = CGPointZero;
    oid.imageRect = rect;
    return oid;
}

+ (ObjectTweenDrawable*)objectTweenDrawableWithDef1:(NSDictionary*)def
{
    ObjectTweenDrawable *otd = [[ObjectTweenDrawable alloc] init];
    NSMutableArray *otd_drawables = [NSMutableArray new];
    NSString *nameFormat = [def objectForKey:@"nameFormat"];
    NSString *origin = [def objectForKey:@"origin"];
    otd.fps = [[def objectForKey:@"fps"] integerValue];
    otd.loop = [[def objectForKey:@"loop"] integerValue];
    otd.pause = NO;
    for(NSString *nameArg1 in [def objectForKey:@"framesNameArg1"]) { 
        ObjectImageDrawable *oid = [[ObjectImageDrawable alloc] init];
        oid.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:nameFormat, nameArg1]];
        CGRect rect;
        rect.size = CGSizeMul(oid.image.size, RASTER_SCALE);
        if([origin isEqual:@"top"])
            rect.origin = CGPointMake(0, rect.size.height);
        oid.imageRect = rect;
        [otd_drawables addObject:oid];
    }
    otd.drawables = [otd_drawables copy];
    return otd;
}

+ (void)defineObjectDimeAndDrawable:(Object*)object withObjectImageDrawable:(ObjectImageDrawable*)oid origin:(NSString*)origin
{
    object.size = oid.imageRect.size;
    object.drawable = oid;
    if([origin isEqual:@"top"])
        object.origin = CGPointMake(0, object.size.height);
    else if([origin isEqual:@"center"])
        object.origin = CGPointMake(object.size.width/2.0, object.size.height/2.0);
    else
        object.origin = CGPointMake(0, 0);
    object.position = CGPointMake(object.position.x + object.origin.x, object.position.y + object.origin.y);
}

+ (NSArray*)objectTemplatesInfoForObjects:(NSArray*)objects
                                 position:(CGPoint)position
                         positionYVariant:(CGFloat)positionYVariant
                             scaleVaraint:(CGFloat)scaleVariant
{
    NSMutableArray *ret = [NSMutableArray new];
    for(Object *object in objects) {
        ObjectTemplateInfo *ti = [[ObjectTemplateInfo alloc] init];
        Object *objectCpy = [object copy];
        objectCpy.position = position;
        ti.object = objectCpy;
        ti.positionYVariant = positionYVariant;
        ti.scaleVariant = scaleVariant;
        [ret addObject:ti];
    }
    return [ret copy];
}
 
+ (NSArray*)objectTemplatesInfoForObjects:(NSArray*)objects
                         positionYVariant:(CGFloat)positionYVariant
                             scaleVaraint:(CGFloat)scaleVariant
{
    NSMutableArray *ret = [NSMutableArray new];
    for(Object *object in objects) {
        ObjectTemplateInfo *ti = [[ObjectTemplateInfo alloc] init];
        ti.object = object;
        ti.positionYVariant = positionYVariant;
        ti.scaleVariant = scaleVariant;
        [ret addObject:ti];
    }
    return [ret copy];
}

-(id)copyWithZone:(NSZone *)zone
{
    JetpackKnightGameData *gd = [super copyWithZone:zone];
    gd.diamondsObjectTemplate = _diamondsObjectTemplate;
    gd.rocketsObjectTemplate = _rocketsObjectTemplate;
    gd.obstaclesObjectTemplate = _obstaclesObjectTemplate;
    gd.treesObjectTemplate = _treesObjectTemplate;
    gd.cloudsObjectTemplate = _cloudsObjectTemplate;
    gd.buildingsObjectTemplate = _buildingsObjectTemplate;
    gd.groundY = _groundY;
    gd.groundSize = _groundSize;
    gd.groundDrawable = [_groundDrawable copy];
    return gd;
}

@end
