//
//  MenuViewController.h
//  FlashRunner
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
@interface MenuViewController : UIViewController < GKGameCenterControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *soundONOFF;
@property (weak, nonatomic) IBOutlet UILabel *score;
- (IBAction)soundCheckAction;
- (IBAction)openGameCenter;
- (IBAction)openTwitter;
- (IBAction)openFacebook;
- (IBAction)gopro;

@end
