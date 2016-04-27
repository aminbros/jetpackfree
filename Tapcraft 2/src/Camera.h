/*
 * Author: Hossein Amin, aminbros.com
 */

#import <Foundation/Foundation.h>
#import "Bound.h"

typedef NS_ENUM(NSInteger, CameraFOVDirection) {
    CameraFOVDirectionVertical,
    CameraFOVDirectionHorizontal
};

typedef struct Camera {
    CGPoint center;
    CGSize screenScale;
    CGFloat ratio;
    CGFloat fov;
    CameraFOVDirection fovDirection;
} Camera;

Camera CameraMakeA(CameraFOVDirection fovDirection, CGFloat fov, CGPoint center);
Bound CameraBound(Camera *camera);
Bound CameraBoundMulScale(Camera *camera, CGFloat mulScale);
CGSize CameraScaleForFitInSize(Camera *camera, CGSize *size);
CGSize CameraSize(Camera *camera);
