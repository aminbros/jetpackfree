/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Camera.h"

Camera CameraMakeA(CameraFOVDirection fovDirection, CGFloat fov, CGPoint center)
{
    Camera camera;
    camera.fovDirection = fovDirection;
    camera.fov = fov;
    camera.center = center;
    camera.screenScale = CGSizeMake(1, 1);
    return camera;
}

Bound CameraBound(Camera *camera)
{
    // ingame size
    CGSize size;
    if(camera->fovDirection == CameraFOVDirectionVertical) {
        size = CGSizeMake(camera->fov * camera->ratio, camera->fov);
    } else {
        size = CGSizeMake(camera->fov * camera->ratio, camera->fov);
    }
    CGFloat hw = size.width / 2.0;
    CGFloat hh = size.height / 2.0;
    return BoundMake(CGPointMake(camera->center.x - hw, camera->center.y - hh),
                     CGPointMake(camera->center.x + hw, camera->center.y + hh));
}

Bound CameraBoundMulScale(Camera *camera, CGFloat mulScale)
{
    // ingame size
    CGSize size;
    if(camera->fovDirection == CameraFOVDirectionVertical) {
        size = CGSizeMake(camera->fov * camera->ratio, camera->fov);
    } else {
        size = CGSizeMake(camera->fov * camera->ratio, camera->fov);
    }
    CGFloat hw = size.width / 2.0 * mulScale;
    CGFloat hh = size.height / 2.0 * mulScale;
    return BoundMake(CGPointMake(camera->center.x - hw, camera->center.y - hh),
                     CGPointMake(camera->center.x + hw, camera->center.y + hh));
}

CGSize CameraSize(Camera *camera) {
    // ingame size
    CGSize size;
    if(camera->fovDirection == CameraFOVDirectionVertical) {
        size = CGSizeMake(camera->fov * camera->ratio, camera->fov);
    } else {
        size = CGSizeMake(camera->fov * camera->ratio, camera->fov);
    }
    return size;
}

CGSize CameraScaleForFitInSize(Camera *camera, CGSize *size) {
    if(camera->fovDirection == CameraFOVDirectionVertical) {
        return CGSizeMake(size->height, size->height);
    } else {
        return CGSizeMake(size->width, size->width);
    }
    
}
