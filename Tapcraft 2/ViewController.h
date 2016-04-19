//
//  ViewController.h
//  Tapcraft 2
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
//#import <iAd/iAd.h>

@interface ViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UIButton *menuButtonForPause;
@property ( nonatomic , weak ) IBOutlet UIView *topView;
@property ( nonatomic , weak ) IBOutlet UIImageView *BG1;
@property ( nonatomic , weak ) IBOutlet UIImageView *BG2;
@property ( nonatomic , weak ) IBOutlet UIImageView *Character;
@property (weak, nonatomic) IBOutlet UIImageView *c1;
@property (weak, nonatomic) IBOutlet UIImageView *c2;
@property (weak, nonatomic) IBOutlet UIImageView *c3;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UIImageView *bgp;
@property (weak, nonatomic) IBOutlet UIImageView *bgp2;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
- (IBAction)pauseLoop;
- (IBAction)resumeToGame:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *PlayButtonFromTheScene;
@property (weak, nonatomic) IBOutlet UIImageView *pauseText;
- (IBAction)menuButton;
- (IBAction)playTheGame;
- (IBAction)shareScore;

@property ( nonatomic , strong )   AVAudioPlayer  *flying;
@property ( nonatomic , strong )   AVAudioPlayer  *blowUp;


@property (weak, nonatomic) IBOutlet UIImageView *explosion;
@end
