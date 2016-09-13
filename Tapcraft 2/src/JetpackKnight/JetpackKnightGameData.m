/*
 * Author: Hossein Amin, aminbros.com
 */

#import "JetpackKnightGameData.h"
#import "Character.h"
#import "GameDataGenerator.h"
#import "GameSimulator.h"

#define GAME_SCALAR 5.0
#define RASTER_SCALE (1/320.0*GAME_SCALAR)

NSString * const JetpackKnightDiamondTag = @"diamond";
NSString * const JetpackKnightRocketTag = @"rocket";
NSString * const JetpackKnightObstacleTag = @"obstacle";
NSString * const JetpackKnightGroundTag = @"ground";


@implementation JetpackKnightGameData

+ (CGFloat)initialSpacing {
    return 2 * GAME_SCALAR;
}

+ (GameDataGeneratorConfig*)createGeneratorConfigWithGameData:(JetpackKnightGameData*)gd
{
    GameDataGeneratorConfig *c = [[GameDataGeneratorConfig alloc] init];

    CGFloat freeArea = gd.gameBound.upperBound.y - gd.groundY;
    // diamonds
    GenerateObjectInfo *goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.diamondsObjectTemplate
                                   position:CGPointMake(0, gd.groundY + freeArea / 2.0)
                           positionYVariant:freeArea / 2.0 - 0.1
                               scaleVaraint:0];
    goi.every = 5 * GAME_SCALAR;
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
    goi.every = 5 * GAME_SCALAR;
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
    goi.every = 10 * GAME_SCALAR;
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
    for(GObject *object in gd.treesObjectTemplate) {
        if(object.size.width > maxWidth)
            maxWidth = object.size.width;
    }
    goi.every = (maxWidth + 3) * GAME_SCALAR;
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
    for(GObject *object in gd.buildingsObjectTemplate) {
        if(object.size.width > maxWidth)
            maxWidth = object.size.width;
    }
    goi.every = (maxWidth + 5) * GAME_SCALAR;
    goi.amount = 1;
    goi.pickTemplateRandom = YES;
    [genTilesInfo addObject:goi];

    // clouds
    goi = [[GenerateObjectInfo alloc] init];
    goi.templatesInfo =
        [self objectTemplatesInfoForObjects:gd.cloudsObjectTemplate
                                   position:CGPointMake(0, 0.8 * GAME_SCALAR)
                           positionYVariant:0.1 * GAME_SCALAR
                               scaleVaraint:0.1];
    goi.every = 10 * GAME_SCALAR;
    goi.amount = 1;
    goi.pickTemplateRandom = YES;
    [genTilesInfo addObject:goi];

    c.genTilesInfo = [genTilesInfo copy];

    // ground
    c.groundY = gd.groundY;
    c.groundHeight = gd.groundSize.height;
    c.groundPieceWidth = gd.groundSize.width - (1 * RASTER_SCALE);
    c.groundTag = gd.groundTag;
    c.groundDrawable = gd.groundDrawable;

    return c;
}

+ (JetpackKnightGameData*)createInitialGameData
{
    JetpackKnightGameData *gd = [[JetpackKnightGameData alloc] init];
    gd.runningSpeed = 1.0;
    gd.runningSpeedUpStep = 0.05;
    gd.runningSpeedUpEvery = 1;
    gd.gameBound = BoundMakeWS(0, 0, 0, 1.0 * GAME_SCALAR);
    gd.initialCamera = CameraMakeA(CameraFOVDirectionVertical, 1.0 * GAME_SCALAR, CGPointMake(1.0 * GAME_SCALAR, 0.5 * GAME_SCALAR));
    gd.positionZs = @[@1, @1.7, @3, @10];
    NSMutableArray *characters = [NSMutableArray new];

    ObjectImageDrawable *groundOID = [self objectImageDrawableWithName:@"ground.png"];
    gd.groundDrawable = groundOID;
    gd.groundSize = gd.groundDrawable.imageRect.size;
    CGFloat groundYDiff = -0.2;
    gd.distantGroundY = groundOID.imageRect.size.height;
    gd.groundY = groundOID.imageRect.size.height + groundYDiff;
    groundOID.imageRect = CGRectMake(groundOID.imageRect.origin.x,
                                     groundOID.imageRect.origin.y +0.2,
                                     groundOID.imageRect.size.width,
                                     groundOID.imageRect.size.height);
    gd.groundTag = JetpackKnightGroundTag;
     
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
    
    gd.characterPinOffset = CGPointMake(0.4 * GAME_SCALAR, 0);

    // decrease drawn objects for testing
    // gd.positionZs = @[@1,@1.7,@3,@10];
    
    gd.simulatorConfig = [[GameSimulatorConfig alloc] init];
    gd.simulatorConfig.gravity = CGPointMake(0, -10.0);
    gd.simulatorConfig.timeStep = 1.0 / 30.0; // 30 step per second
    gd.simulatorConfig.velocityIterations = 6;
    gd.simulatorConfig.positionIterations = 2;
    

    return gd;
}

- (void)setCharacter:(Character*)character atPositionIndex:(NSInteger)index {
    character.position = CGPointMake(index * (character.size.width + .1 * GAME_SCALAR), self.groundY + 0.01);
}

+ (NSArray*)mkTreesTemplate:(JetpackKnightGameData*)gd {   
    GObject *o = [[GObject alloc] init];
    o.position = CGPointMake(0, gd.distantGroundY);
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"land1.png"] origin:@"bottom"];
    o.zIndex = -2;
    o.positionZIndex = 1;
    // scale up to get the same size
    CGFloat scale = [[gd.positionZs objectAtIndex:o.positionZIndex] doubleValue];
    o.scale = CGPointMake(scale, scale);
    return @[o];
}

+ (NSArray*)mkBuildingsTemplate:(JetpackKnightGameData*)gd {   
    GObject *o = [[GObject alloc] init];
    o.position = CGPointMake(0, gd.distantGroundY);
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"mountain.png"] origin:@"bottom"];
    o.zIndex = -3;
    o.positionZIndex = 2;
    // scale up to get the same size
    CGFloat scale = [[gd.positionZs objectAtIndex:o.positionZIndex] doubleValue];
    o.scale = CGPointMake(scale, scale);
    return @[o];
}

+ (NSArray*)mkCloudsTemplate:(JetpackKnightGameData*)gd {
    
    GObject *o = [[GObject alloc] init];
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
    GObject *o = [[GObject alloc] init];
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"diamond.png"] size:CGSizeMake(0.08 * GAME_SCALAR, 0.08 * GAME_SCALAR) origin:@"center"];
    //o.renderOutline = YES;
    o.scale = CGPointMake(0.8, 0.8);
    o.zIndex = 1;
    o.bodyType = BodyTypeStatic;
    o.physicsActive = YES;
    o.isSensor = YES;
    o.tag = JetpackKnightDiamondTag;
    return @[o];
}


+ (NSArray*)mkRocketsTemplate:(JetpackKnightGameData*)gd {
    GObject *o = [[GObject alloc] init];
    [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:@"rocket.png"] size:CGSizeMake(0.1 * GAME_SCALAR, 0.1 * GAME_SCALAR) origin:@"center"];
    //o.renderOutline = YES;
    o.scale = CGPointMake(0.7, 0.7);
    o.zIndex = 1;
    o.bodyType = BodyTypeStatic;
    o.physicsActive = YES;
    o.isSensor = YES;
    o.tag = JetpackKnightRocketTag;
    return @[o];
}

+ (NSArray*)mkObstaclesTemplate:(JetpackKnightGameData*)gd {
    NSMutableArray *ret = [NSMutableArray new];
    for(NSInteger i = 1; i <= 2; ++i) { 
        GObject *o = [[GObject alloc] init];
        o.position = CGPointMake(0, gd.groundY);
        [self defineObjectDimeAndDrawable:o withObjectImageDrawable:[self objectImageDrawableWithName:[NSString stringWithFormat:@"block%zd.png", i]] size:CGSizeMake(0.18 * GAME_SCALAR, 0.18 * GAME_SCALAR) origin:@"bottom"];
        //o.renderOutline = YES;
        o.scale = CGPointMake(0.8, 0.8);
        o.zIndex = 1;
        o.bodyType = BodyTypeStatic;
        o.physicsActive = YES;
        o.isSensor = YES;
        o.tag = JetpackKnightObstacleTag;
        [ret addObject:o];
    }         
    return [ret copy];
}

+ (Character*)mkCharacterA:(JetpackKnightGameData*)gd
{
    Character *c = [[Character alloc] init];
    
    c.collisionCategoryBits = 0x0002;
    c.collisionMaskBits = 0xFFFD;
    
    c.standDrawable = [self objectImageDrawableWithName:@"character1.png"];
    // initialize character size and origin according to "character1.png"
    [self defineObjectDimeAndDrawable:c withObjectImageDrawable:c.standDrawable origin:@"bottom"];
    // character images have extra width
    c.size = CGSizeMake(0.13 * GAME_SCALAR, c.size.height);
    c.scale = CGPointMake(1.2, 1.2);
    c.origin = CGPointMake(c.size.width / 2.0, 0.0);
    //c.renderOutline = YES;
    c.zIndex = 2;
    c.bodyType = BodyTypeDynamic;
    c.density = 1.0;
    c.physicsActive = YES;
    c.bodyFixedRotation = YES;
    CGFloat hwDiff = (c.standDrawable.imageRect.size.width - c.size.width) / 2.0;
    
    // character data
    c.jumpForce = 40.0;
    c.jumpForceTime = 0.1;
    c.jumpOnAirForce = 40.0;
    c.jumpOnAirForceTime = 0.1;
    c.numberOfAllowedJumpsOnAir = 1;
    
    c.runningMaxForce = 20.0;
    c.runningMaxVelocity = 4;
    
    c.rocketMaxForce = CGPointMake(10.0, 40);
    c.rocketMaxVelocity = CGPointMake(7, 4);
    c.rocketFirstJumpForce = 40;
    c.rocketFirstJumpForceTime = 0.1;
    
    ObjectImageDrawable *oid = c.standDrawable;
    oid.imageRect = CGRectMake(oid.imageRect.origin.x - hwDiff, oid.imageRect.origin.y, oid.imageRect.size.width, oid.imageRect.size.height);

    // running drawable
    NSArray *tweenPropsInfo =
        @[
          @{
              @"property": @"runningDrawable",
              @"fps": @30,
              @"loop": @(ObjectImageDrawableInfinite),
              @"nameFormat": @"character%@.png",
              @"framesNameArg1": @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"7",@"6",@"5",@"4",@"3",@"2"],
              @"origin": @"bottom"
          },
          @{
              @"property": @"flyingDrawable",
              @"fps": @30,
              @"loop": @(ObjectImageDrawableInfinite),
              @"nameFormat": @"rocket%@.png",
              @"framesNameArg1": @[@"0",@"1",@"2",@"3",@"4",@"5",@"4",@"3",@"2",@"1"],
              @"origin": @"bottom"
          },
          @{
              @"property": @"explosionDrawable",
              @"fps": @30,
              @"loop": @0,
              @"nameFormat": @"fire%@.png",
              @"framesNameArg1": @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"0"],
              @"origin": @"bottom"
          },
          ];
    for(NSDictionary *tweenPropInfo in tweenPropsInfo) {
        [c setValue:[self objectTweenDrawableWithDef1:tweenPropInfo]
             forKey:[tweenPropInfo objectForKey:@"property"]];
    }
    
    NSArray *tweenDrawables = @[@"runningDrawable",@"flyingDrawable",@"explosionDrawable"];
    for(NSString *key in tweenDrawables) {
        ObjectTweenDrawable *tweenD = [c valueForKey:key];
        for(ObjectImageDrawable *oid in tweenD.drawables) {
            oid.imageRect = CGRectMake(oid.imageRect.origin.x - hwDiff, oid.imageRect.origin.y, oid.imageRect.size.width, oid.imageRect.size.height);
        }
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
        else
            rect.origin = CGPointMake(0, 0);
        oid.imageRect = rect;
        [otd_drawables addObject:oid];
    }
    otd.drawables = [otd_drawables copy];
    return otd;
}

+ (void)defineObjectDimeAndDrawable:(GObject*)object withObjectImageDrawable:(ObjectImageDrawable*)oid size:(CGSize)size origin:(NSString*)origin
{
    [self defineObjectDimeAndDrawable:object withObjectImageDrawable:oid origin:origin];
    object.size = size;
    CGFloat hwDiff = (oid.imageRect.size.width - object.size.width) / 2.0;
    CGFloat hhDiff = (oid.imageRect.size.height - object.size.height) / 2.0;
    oid.imageRect = CGRectMake(oid.imageRect.origin.x - hwDiff, oid.imageRect.origin.y - hhDiff, oid.imageRect.size.width, oid.imageRect.size.height);
}

+ (void)defineObjectDimeAndDrawable:(GObject*)object withObjectImageDrawable:(ObjectImageDrawable*)oid origin:(NSString*)origin
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
    for(GObject *object in objects) {
        ObjectTemplateInfo *ti = [[ObjectTemplateInfo alloc] init];
        GObject *objectCpy = [object copy];
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
    for(GObject *object in objects) {
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
    gd.distantGroundY = _distantGroundY;
    gd.groundSize = _groundSize;
    gd.groundDrawable = [_groundDrawable copy];
    gd.players = _players;
    gd.characterPinOffset = _characterPinOffset;
    return gd;
}

@end
