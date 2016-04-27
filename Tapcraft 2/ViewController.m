//
//  ViewController.m
//  Tapcraft 2
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#define MAIN_WIDTH self.view.frame.size.height
#define MAIN_HEIGHT self.view.frame.size.width


#define WALKING  1
#define FLYING   2
#define PAUSE    3
#define GAMEOVER 4


#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "defined.h"
#import <Chartboost/Chartboost.h>
//#import <RevMobAds/RevMobAds.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *  land; // trees are generated
@property ( nonatomic , strong ) NSMutableArray  *  rectaCollection; // All the objects are added into this value
@property ( nonatomic , strong ) UIImageView     *  TempForObj; // It is a temporary for checking the objects one by one
@property ( nonatomic , strong ) NSArray         *  walkingCharacterAnimationFrames; // Walking animations frames
@property ( nonatomic , strong ) NSArray         *  flyingCharacterAnimationFrames;  // Flying animations frames
@property ( nonatomic , strong ) NSArray         *  ExplosionAnimationFrames;  // Explosion animations frames
@property ( nonatomic , strong ) AVAudioPlayer   *  pop;
@property ( nonatomic , strong ) AVAudioPlayer   *  boob;
@property ( nonatomic , assign ) float  speeder;        // this value is for getting hard the game
@property ( nonatomic , assign ) int    harder;         // getting hard value
@property ( nonatomic , assign ) int    mutliSpeed;     // the position of making objects ( should be more than screenSize )
@property ( nonatomic , assign ) BOOL   letJump;        // let the character jumps
@property ( nonatomic , assign ) bool   mainJumping;    // jump
@property ( nonatomic , assign ) float  jumpSpeedLimit; // jump size
@property ( nonatomic , assign ) float  jumpSpeed;      // speed of jump
@property ( nonatomic , assign ) int    letJumpNum;     // jump function
@property ( nonatomic , assign ) int    scoreValue;     // this is the score
@property ( nonatomic , assign ) BOOL   hasSound;       // for checking sound , ON or OFF
@property ( nonatomic , assign ) BOOL   stopJump;       // stop jumping
@property ( nonatomic , assign ) BOOL   letRocket;      // let the game generates rocket
@property ( nonatomic , assign ) int    speed;          // game's pace ( speed )
@property ( nonatomic , assign ) int    timeToGenerateObstacle; // it is used for maage time to generate obstacles
@property ( nonatomic , assign ) float  vx;
@property ( nonatomic , assign ) float  vy;
@property ( nonatomic , assign ) float  friction;
@property ( nonatomic , assign ) bool   upNow;             // Detects Touch the screen
@property ( nonatomic , assign ) bool   flyingTime;        // is gaming flying??
@property ( nonatomic , assign ) int    flyingTimeToCheck; // for checking the time of flying
@property ( nonatomic , assign ) Byte   GAME_STATE_STATUS;
@property ( nonatomic , assign ) Byte   GAME_STATE_STATUS_TEMP;   // Game status
// Game status
@property ( nonatomic , strong ) id     displayLink; // Timer to call GameLoop functions


@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _score.font = [UIFont fontWithName:@"AngryBirds" size:32];
    [self setupTheFirstSettings];
    [self CreateAnimations];
    [self initScene];
    [self GenerateSounds];
    
}
- (void) setupTheFirstSettings
{
    _mainJumping        = false;    //how quickly should the jump start off
    _jumpSpeedLimit     = 8;    //the current speed of the jump;
    _jumpSpeed          = _jumpSpeedLimit;
    _letJumpNum         = 2;
    _stopJump           = NO;
    _letRocket          = YES;
    _flyingTime         = NO;
    _GAME_STATE_STATUS  = WALKING;
    _vx                 = 0;
    _vy                 = 0;
    _friction           = 0.94;
    _speed              = 5;
    _mutliSpeed         = 600;
    _hasSound           = NO;
}
- (void) GenerateSounds
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"rocketFlying" ofType:@"mp3"];
    _flying =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    [_flying prepareToPlay];
    
    path = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"aiff"];
    
    _blowUp =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    [_blowUp prepareToPlay];
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 0 ){
        
        
        _hasSound = YES;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"boob" ofType:@"mp3"];
        
        _pop =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        [_pop.delegate self];
        [_pop prepareToPlay];
        
        
        path = [[NSBundle mainBundle] pathForResource:@"swoosh" ofType:@"aiff"];
        
        _boob =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        [_boob.delegate self];
        [_boob prepareToPlay];
        
    }


}

- (void) CreateAnimations
{
    _walkingCharacterAnimationFrames  = [[NSArray alloc] initWithObjects:
                                         [UIImage imageNamed:@"character1.png"],
                                         [UIImage imageNamed:@"character2.png"],
                                         [UIImage imageNamed:@"character3.png"],
                                         [UIImage imageNamed:@"character4.png"],
                                         [UIImage imageNamed:@"character5.png"],
                                         [UIImage imageNamed:@"character6.png"],
                                         [UIImage imageNamed:@"character7.png"],
                                         [UIImage imageNamed:@"character8.png"],
                                         [UIImage imageNamed:@"character7.png"],
                                         [UIImage imageNamed:@"character6.png"],
                                         [UIImage imageNamed:@"character5.png"],
                                         [UIImage imageNamed:@"character4.png"],
                                         [UIImage imageNamed:@"character3.png"],
                                         [UIImage imageNamed:@"character2.png"],
                                         [UIImage imageNamed:@"character1.png"],

                                         
                                         nil];
    
    _flyingCharacterAnimationFrames  = [[NSArray alloc] initWithObjects:
                                        [UIImage imageNamed:@"rocket0.png"],
                                        [UIImage imageNamed:@"rocket1.png"],
                                        [UIImage imageNamed:@"rocket2.png"],
                                        [UIImage imageNamed:@"rocket3.png"],
                                        [UIImage imageNamed:@"rocket4.png"],
                                        [UIImage imageNamed:@"rocket5.png"],
                                        [UIImage imageNamed:@"rocket4.png"],
                                        [UIImage imageNamed:@"rocket3.png"],
                                        [UIImage imageNamed:@"rocket2.png"],
                                        [UIImage imageNamed:@"rocket1.png"],
                                        [UIImage imageNamed:@"rocket0.png"],
                                        nil];
    
    _ExplosionAnimationFrames       = [[NSArray alloc] initWithObjects:
                                       [UIImage imageNamed:@"fire0.png"],
                                       [UIImage imageNamed:@"fire1.png"],
                                       [UIImage imageNamed:@"fire2.png"],
                                       [UIImage imageNamed:@"fire3.png"],
                                       [UIImage imageNamed:@"fire4.png"],
                                       [UIImage imageNamed:@"fire5.png"],
                                       [UIImage imageNamed:@"fire6.png"],
                                       [UIImage imageNamed:@"fire7.png"],
                                  
                                       nil];
    
    _explosion.animationImages = _ExplosionAnimationFrames;
	_explosion.animationDuration = .3;
	_explosion.contentMode = UIViewContentModeScaleAspectFit;
    [_explosion setAnimationRepeatCount:1];
    
 	_Character.animationImages = _walkingCharacterAnimationFrames;
	_Character.animationDuration = .4;
	_Character.contentMode = UIViewContentModeScaleAspectFit;
	[_Character startAnimating];
    

    
}

- (void) initScene
{
    _rectaCollection = [[NSMutableArray alloc] init];
     _displayLink    = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop)];
   // [_displayLink setFrameInterval:1];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.view addSubview:_topView];
    
}

- (void) gameLoop
{
    
    _harder++;
    
    if ( _harder == 500 && _speeder < 10)
    {
        _speeder+=.5;
        _harder = 0;
        NSLog(@"Get harder");
    }
    
    switch (_GAME_STATE_STATUS) {
        case WALKING:
        {
            [self jumpAction];

        }
            break;
        case FLYING:
        {
            
            [self flyingAction];
            [self gravity];

        }
            
        break;


        case PAUSE:
        {
            [_displayLink invalidate];
            [_pauseBtn setHidden:YES];
            [_PlayButtonFromTheScene setHidden:NO];
            [_pauseText setHidden:NO];
            [_menuButtonForPause setHidden:NO];
            
            if ( _flying.isPlaying)
            {
                [_flying stop];
            }
            

        }
            
            break;
        case GAMEOVER:
        {
            
        }
            
            break;

       
    }
    
//    // This checks the character is running or flying by rocket.
//    if ( !_stopJump )
//    {
//             [self jumpAction];
//    }
//    else
//    {
//        
//             [self gravity];
//        
//    }
//    // -------------------------------------------------------s-----  END (
    
    
   
    if  ( _letRocket && !_flyingTime &&  [self getRandomNumberBetween:100 maxNumber:300] == 200 ) { // making rockets
        
             [self makeRocket];
             _letRocket = NO;
        }
    

    if  ([self getRandomNumberBetween:1 maxNumber:50] == 1) { // Making diamonds

              [self makeDiamond];
        
        }
    
    if ( [self getRandomNumberBetween:1 maxNumber:100] == 24  ) { // making Obstacles
        
              [self makeObstacle];
    }
    
    
    for ( int i = 0 ; i < [_rectaCollection count] ; i++) // It is the main FOR that checks everything on the stage ( Scene )
    {
        _TempForObj =  [_rectaCollection objectAtIndex:i];
        
        // This IF is for checking GameOver but, It depends on character is walking OR flying , if the character is walking , GameOver Occurs
        // But If the character Is flying , just the rocket disappears and the again starts to walk
        if  ( CGRectIntersectsRect(_Character.frame, CGRectInset([_TempForObj frame], 20, 20))  && _TempForObj.tag == 1)
        {
            [_explosion startAnimating];
            [_Character stopAnimating];
           
            if ( _flyingTime )
            {
                [self removeRocketAndBackToNormalMode];
                
            }
            else
            {
                
                UIImage*death = [UIImage imageNamed:@"death"];
                [_Character setImage:death];
                [_Character setFrame:CGRectMake(_Character.center.x, _Character.center.y, _Character.frame.size.width + 30, _Character.frame.size.height + 10)];
                [self GameOver];
                
            }
        }
        
        
        else if( CGRectIntersectsRect(_Character.frame, [_TempForObj frame])  && _TempForObj.tag == 3) // It occurs when the character hits the rockets
        {
            [self eatenRocket];

        }
        
        else if( CGRectIntersectsRect(_Character.frame, [_TempForObj frame])  && _TempForObj.tag == 2) // It occurs when the character hits the diamonds
        {
            [self eatenDiamond];
        }
        

       [_TempForObj setCenter:CGPointMake([_TempForObj center].x - _speed - _speeder, [_TempForObj center].y)]; // these line moves everything on stages
        
        if ( [_TempForObj center].x < -150 ) // this line checks wheter Diamonds/Obstacles/Rockets have passed or haven't yet
        {
            if ( _TempForObj.tag == 3)
            {
                 _letRocket = YES;
            }
        
            [_rectaCollection removeObjectAtIndex:i];
            [_TempForObj removeFromSuperview];
        }
        
    }
    
      [self moveBackground];
   
}

-(void)removeRocketAndBackToNormalMode
{
    [_flying stop];
    [_flying setCurrentTime:0.0];
    if ( _hasSound) {    [_blowUp play]; }
    
    [self earthquake:_bgp           With:20];
    [self earthquake:_bgp2          With:20];
    [self earthquake:_BG1           With:20];
    [self earthquake:_BG2           With:20];
    [self earthquake:_c1            With:20];
    [self earthquake:_c2            With:20];
    [self earthquake:_Character     With:20];
    
    
    [_TempForObj setFrame:CGRectZero];
    
    [self flyingTimeHitAction];
    [_explosion startAnimating];


}
-(void) flyingAction
{
       _flyingTimeToCheck++;
    
       if  ( _flyingTimeToCheck == 800 )
       {
           [self backToNormalModeFromTheFlying];
           _GAME_STATE_STATUS = WALKING;
           _flyingTimeToCheck = 0;
           
       }
    
       if ( (_flyingTimeToCheck % 5) == 0)
       {
           [self earthquake:_BG1 With:4];
           [self earthquake:_BG2 With:4];
           [self earthquake:_Character With:4];
       }
    
       if ( (CGRectIntersectsRect(_Character.frame, [_BG1 frame]) || CGRectIntersectsRect(_Character.frame, [_BG2 frame]) || _Character.center.y < -_Character.frame.size.height) && _GAME_STATE_STATUS == FLYING)
       {
           [self removeRocketAndBackToNormalMode];
       }
    
}

- (void) flyingTimeHitAction
{
    [_Character setFrame:CGRectMake(47, 179, _Character.frame.size.width - 50, _Character.frame.size.height - 20 )];
    _Character.animationImages   = _walkingCharacterAnimationFrames;
    _Character.animationDuration = .2;
    _Character.contentMode       = UIViewContentModeScaleAspectFit;
    [_Character startAnimating];
    [_pauseBtn setAlpha:1];
    
    _stopJump          = NO;
    _letRocket         = YES;
    _flyingTime        = NO;
    _speed             = 5;
    _GAME_STATE_STATUS = WALKING;
    _flyingTimeToCheck = 0;

}

-(void) eatenRocket
{
    
    [_Character setFrame:CGRectMake(_TempForObj.center.x, _TempForObj.center.y - 30, _Character.frame.size.width + 50, _Character.frame.size.height + 20 )];
    _Character.animationImages = _flyingCharacterAnimationFrames;
    _Character.animationDuration = .2;
    _Character.contentMode = UIViewContentModeScaleAspectFit;
    [_Character startAnimating];
    [_TempForObj setCenter:CGPointMake(0, 0)];
    if( _hasSound) {    [_flying play]; }
    
    _GAME_STATE_STATUS = FLYING;
    _stopJump          = YES;
    _letRocket         = NO;
    _flyingTime        = YES;
    _speed             = 8;

    
    
}

-(void) backToNormalModeFromTheFlying
{
    [_Character setFrame:CGRectMake(47, 179, 47, 66 )];
    _Character.animationImages = _walkingCharacterAnimationFrames;
    _Character.animationDuration = .2;
    _Character.contentMode = UIViewContentModeScaleAspectFit;
    [_Character startAnimating];
    _stopJump   = NO;
    _letRocket  = YES;
    _flyingTime = NO;
    _speed = 5;

}


-(void) makeDiamond
{
    UIImageView *recta = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 26)];
    recta.contentMode = UIViewContentModeScaleAspectFit;
    [recta setTag:2];
    [recta setCenter:CGPointMake(( (28 + _speeder)) + _mutliSpeed, [self getRandomNumberBetween:50 maxNumber:200])];
    [recta setImage:[UIImage imageNamed:@"diamond"]];
    [self.view   addSubview:recta];
    [_rectaCollection addObject:recta];

}
-(void) makeRocket {
    
    UIImageView *recta = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 26)];
    recta.contentMode = UIViewContentModeScaleAspectFit;
    [recta setTag:3];
    [recta setCenter:CGPointMake(( (28 + _speeder)) + _mutliSpeed, [self getRandomNumberBetween:50 maxNumber:150])];
    [recta setImage:[UIImage imageNamed:@"rocket"]];
    [self.view   addSubview:recta];
    [_rectaCollection addObject:recta];
    
    _letRocket = NO;

}

- (void) GameOver
{
    //[[RevMobAds session] showFullscreen];
    [Chartboost showInterstitial:CBLocationHomeScreen];
    [_displayLink invalidate];
    [_gameOverView setHidden:NO];
    [self.view addSubview:_gameOverView];
    [_pauseBtn setHidden:YES];
    
    
    [self reportHighScore:_scoreValue forLeaderboardId:k_game_center_domain];
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"score"] intValue] <_scoreValue ){
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_scoreValue] forKey:@"score"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    }

}

- (void) makeObstacle
{
    _timeToGenerateObstacle++;
    if ( _timeToGenerateObstacle == 3)
    {
        UIImageView *recta = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 61)];
        recta.contentMode = UIViewContentModeScaleAspectFit;

        [recta setTag:1];
        [recta setCenter:CGPointMake(( (28 + _speeder)) + _mutliSpeed, 210)];
        [recta setImage:[UIImage imageNamed:[NSString stringWithFormat:@"block%li",(long)[self getRandomNumberBetween:1 maxNumber:2]]]];
        [self.view   addSubview:recta];
        [_rectaCollection addObject:recta];
        _timeToGenerateObstacle = 0;
    }

}

- (void) eatenDiamond
{
    [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         if ( _hasSound) { [_pop play]; }
         
         [_TempForObj setAlpha:0];
         [_TempForObj setTag:4];
         [_TempForObj setCenter:CGPointMake(400,400)];
         _scoreValue+=1;
         [_score setText:[NSString stringWithFormat:@"%i",_scoreValue]];
         
     } completion:^(BOOL finished){
         
     }];

}

- (void) moveBackground
{
    _BG1.center = CGPointMake(_BG1.center.x - _speed -_speeder, _BG1.center.y );
    if ( _BG1.center.x < -_BG1.frame.size.width/2)
    {
        _BG1.center = CGPointMake( _BG1.frame.size.width + _BG2.center.x - 20  , _BG1.center.y);
    }
    _BG2.center = CGPointMake(_BG2.center.x - _speed
                              - _speeder, _BG2.center.y );
    if ( _BG2.center.x < -_BG2.frame.size.width/2)
    {
        _BG2.center = CGPointMake( _BG2.frame.size.width + _BG1.center.x - 20 , _BG2.center.y);
    }
    
    
    
    _bgp.center = CGPointMake(_bgp.center.x - (_speed/3) + - _speeder, _bgp.center.y);
    
    if ( _bgp.center.x < -_bgp.frame.size.width)
    {
        [_bgp setCenter:CGPointMake(_bgp.frame.size.width*2, _bgp.center.y)];
    }
    
    _bgp2.center = CGPointMake(_bgp2.center.x - (_speed/3) - _speeder, _bgp2.center.y);
    
    if ( _bgp2.center.x < -_bgp2.frame.size.width)
    {
        [_bgp2 setCenter:CGPointMake(_bgp2.frame.size.width*2, _bgp2.center.y)];
    }

    
    
    _land.center = CGPointMake(_land.center.x - (_speed/1.7) - _speeder, _land.center.y);
    
    if ( _land.center.x < -_land.frame.size.width)
    {
        [_land setCenter:CGPointMake(_land.frame.size.width*2, _land.center.y)];
        [_land setImage:[UIImage imageNamed:[NSString stringWithFormat:@"land%li",(long)[self getRandomNumberBetween:1 maxNumber:2]]]];
        
    }
    
    
    _c1.center = CGPointMake(_c1.center.x - (_speed/1.7) - _speeder, _c1.center.y);
    
    if ( _c1.center.x < -_c1.frame.size.width)
    {
        [_c1 setCenter:CGPointMake(self.view.frame.size.width*2, _c1.center.y)];
        
        
    }


    _c2.center = CGPointMake(_c2.center.x - _speed - _speeder, _c2.center.y);
    
    if ( _c2.center.x < -_c2.frame.size.width)
    {
        [_c2 setCenter:CGPointMake(self.view.frame.size.width*2, _c2.center.y)];
        
        
    }
    
    _c3.center = CGPointMake(_c3.center.x - (_speed*1.2) - _speeder, _c3.center.y);
    
    if ( _c3.center.x < -_c3.frame.size.width)
    {
        [_c3 setCenter:CGPointMake(self.view.frame.size.width*2, _c3.center.y)];
        
        
    }
}



-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    _upNow = YES;

    if ( _letJump ){
        
    _mainJumping = false;
        
        _letJumpNum--;

        if ( _letJumpNum == 0)
        
        _letJump = NO;
    }

}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _upNow = NO;
}



-(void) jumpAction
{
    
    if(!_mainJumping){

		_mainJumping = YES;
		_jumpSpeed = _jumpSpeedLimit*-1;
        [_Character setCenter:CGPointMake(_Character.center.x, _Character.center.y + _jumpSpeed)];

	} else {

				 if(_jumpSpeed < 0){
			_jumpSpeed *= 1 - _jumpSpeedLimit/120;
			if(_jumpSpeed > -_jumpSpeedLimit/10){
				_jumpSpeed *= -1;
			}
            
		}
    }
    
		if(_jumpSpeed > 0 && _jumpSpeed <= _jumpSpeedLimit){
			_jumpSpeed *= 1 + _jumpSpeedLimit/50;

		}
    
        [_Character setCenter:CGPointMake(_Character.center.x, _Character.center.y + _jumpSpeed)];

    
      if(_Character.center.y >= (MAIN_WIDTH) - _Character.frame.size.height*1.8){
          _letJump = YES;
          _letJumpNum = 2;
        [_Character setCenter:CGPointMake(_Character.center.x, (MAIN_WIDTH) - _Character.frame.size.height*1.8 )];
          
         
    }
 }

- (IBAction)pauseLoop {
    _GAME_STATE_STATUS_TEMP = _GAME_STATE_STATUS;
    _GAME_STATE_STATUS = PAUSE;
}

- (IBAction)resumeToGame:(id)sender {
    _GAME_STATE_STATUS = _GAME_STATE_STATUS_TEMP;
    
    
    if (_GAME_STATE_STATUS == FLYING )
    {
        [_flying play];

    }
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop)];
   // [_displayLink setFrameInterval:1];
    
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_pauseBtn setHidden:NO];
    [_PlayButtonFromTheScene setHidden:YES];
    [_pauseText setHidden:YES];
    
    [_menuButtonForPause setHidden:YES];

}
- (IBAction)menuButton {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playTheGame {
    
    for ( int i = 0 ; i < _rectaCollection.count ;i++)  // this FOR detects all the objects ( Diamond , Rockets, Obstacles ) and removes them from the stage!
    {
        
        UIImageView *tt = [_rectaCollection objectAtIndex:i];
        
        [tt setCenter:CGPointMake([[_rectaCollection objectAtIndex:i] center].x + 600, tt.center.y)];
        
        [tt setAlpha:0];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.1];
        
        tt.center = CGPointMake(0, 50);
        [UIView commitAnimations];
        
    } // For ends
    
    [_gameOverView setHidden:YES];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop)];
  //  [_displayLink setFrameInterval:1];
    
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    _stopJump = NO;
    _letRocket = YES;
    _flyingTime = NO;
    _speeder = 0;
    _harder = 0;
    _flyingTimeToCheck = 0;
    [_pauseBtn setHidden:NO];
    _scoreValue = 0;
    [_score setText:[NSString stringWithFormat:@"%i",_scoreValue]];
    [_Character setFrame:CGRectMake( 60 , _Character.center.y, _Character.frame.size.width - 30, _Character.frame.size.height - 10)];

    _Character.animationImages = _walkingCharacterAnimationFrames;
	_Character.animationDuration = .2;
	_Character.contentMode = UIViewContentModeScaleAspectFit;
	[_Character startAnimating];
    
    
}

- (IBAction)shareScore {
    
    NSString * text = [NSString stringWithFormat:@"My time Is %li In Jetpack Knight. Beat That!", (long)_scoreValue];
    UIImage * image = [UIImage imageNamed:@"rc.png"];
    NSArray * activityItems = @[text, image];
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    avc.excludedActivityTypes = @[ UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    avc.popoverPresentationController.sourceView=self.view;
    
    [self presentViewController:avc animated:YES completion:nil];

}
-(void) gravity
{
    if(_upNow)
        _vx -= 1;
    
    
    _vx += 0.3;
    
    _vx *= _friction;
    
    _Character.center = CGPointMake(_Character.center.x, _Character.center.y + _vx);
    
}

- (void)earthquake:(UIView*)itemView With:(CGFloat) em
{
    
    CGFloat t = em;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, t);
    
    itemView.transform = leftQuake;
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:3];
    [UIView setAnimationDuration:0.05];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
    
    
    
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}
- (NSInteger)getRandomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random() % (max - min + 1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTopView:nil];
    [super viewDidUnload];
}
- (void) reportHighScore:(NSInteger) highScore forLeaderboardId:(NSString*) leaderboardId {
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore* scores = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardId];
        scores.value = highScore;
        [GKScore reportScores:@[scores] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"error: %@", error);
            }
        }];
    }
}

//-(void)bannerView:(ADBannerView *)banner
//didFailToReceiveAdWithError:(NSError *)error{
   // NSLog(@"Error in Loading Banner!");
//}

//-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
   // NSLog(@"iAd banner Loaded Successfully!");
   // [banner setAlpha:1];
    
//}
//-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
   // NSLog(@"iAd Banner will load!");
//}
//-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
   // NSLog(@"iAd Banner did finish");
    
//}

@end
