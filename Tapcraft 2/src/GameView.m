/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameView.h"

@implementation GameView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self != nil) {
        [self _initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize {
    
}

- (void)drawRect:(CGRect)rect {
    if(self.game == nil) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect fullRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    CGContextSaveGState(context);

    // fix coordinate system
    //    |
    // to |___
    CGContextTranslateCTM(context, 0.0f, fullRect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    if(self.game.gameData.clearRectColor != nil) {
        CGContextSetFillColorWithColor(context, self.game.gameData.clearRectColor.CGColor);
        CGContextFillRect(context, fullRect);
    }
    
    UIImage *backgroundImage = self.game.gameData.backgroundImage;
    if(backgroundImage != nil) {
        CGContextDrawImage(context, fullRect, backgroundImage.CGImage);
    }
    Camera camera = self.game.camera;
    CGSize cameraHalfSize = CGSizeMul(CameraSize(&camera), 0.5);
    CGContextScaleCTM(context, camera.screenScale.width, camera.screenScale.height);
    NSArray *objects = [self.game objectsToDrawOrdered];
    NSArray *positionZs = self.game.gameData.positionZs;
    for(Object *object in objects) {
        CGFloat positionZ = [[positionZs objectAtIndex:object.positionZIndex] doubleValue];
        [object.drawable drawOnContext:context
                                object:object
                        cameraHalfSize:&cameraHalfSize
                          cameraCenter:&camera.center
                                 depth:positionZ
                          timeInterval:_currentInterval];
    }
    CGContextRestoreGState(context);
}

@end
