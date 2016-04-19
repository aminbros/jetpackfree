//
//  MenuViewController.m
//  FlashRunner
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#import "MenuViewController.h"
AVAudioPlayer  *MainAudio;

@interface MenuViewController ()

@end
bool firstOne = YES;
@implementation MenuViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [_score setFont:[UIFont fontWithName:@"AngryBirds" size:32]];
    
    [_score setText: [[NSUserDefaults standardUserDefaults] stringForKey:@"score"]];
    
    
    if ( firstOne )
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"];
        
        MainAudio =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        MainAudio.numberOfLoops = -1;
        [MainAudio.delegate self];
        [MainAudio play];
        firstOne = NO;
        NSLog(@"First One");
        
    }
    
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 0 ){
        
        [_soundONOFF setAlpha:1];
        
    } else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 1 )
    {
        [_soundONOFF setAlpha:.5];
        [MainAudio setVolume:0.0];
    }
    

}
-(void) viewDidAppear:(BOOL)animated
{
    [_score setText: [[NSUserDefaults standardUserDefaults] stringForKey:@"score"]];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)soundCheckAction {
    
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 0 ){
        
        [_soundONOFF setAlpha:.5];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"soundsStatuss"];
        [MainAudio setVolume:0.0];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 1)
    {
        [_soundONOFF setAlpha:1];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"soundsStatuss"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MainAudio setVolume:1.0];
        
    }
    

}

- (IBAction)openGameCenter {
    GKGameCenterViewController  *gameCenterController = [[GKGameCenterViewController alloc] init];
    if ( gameCenterController != nil)
    {
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gameCenterController.gameCenterDelegate = self;
        
        UIViewController *vc = self.view.window.rootViewController;
        vc.popoverPresentationController.sourceView=self.view;
        [vc presentViewController: gameCenterController animated: YES completion:nil];
    }

}

- (IBAction)openTwitter {
    
    NSURL *myUrl = [NSURL URLWithString:@"https://twitter.com/JetpackKnight"];
    
    if(![[UIApplication sharedApplication] openURL:myUrl]){
        NSLog(@"open Faild...");
    }
}


- (IBAction)gopro {
    
    NSURL *myUrl = [NSURL URLWithString:@"https://itunes.apple.com/us/app/jetpack-knight-pro/id1100427555?ls=1&mt=8"];
    
    if(![[UIApplication sharedApplication] openURL:myUrl]){
        NSLog(@"open Faild...");
    }
}

- (IBAction)openFacebook {
    
    
    NSURL *myUrl = [NSURL URLWithString:@"https://www.facebook.com/Jetpack-Knight-Game-1727696540810793/"];
    
    if(![[UIApplication sharedApplication] openURL:myUrl]){
        NSLog(@"open Faild...");
        
    }
    
    
}


@end
