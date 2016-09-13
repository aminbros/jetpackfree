//
//  MenuViewController.m
//  FlashRunner
//
//  Created by Sherman Johnson
//  Copyright (c) 2015 MobileFusionSoft.com, Inc All rights reserved.
//

#import "MenuViewController.h"
#import "JetpackKnightViewController.h"
#import "AppDelegate.h"

#ifdef ENABLE_SCREEN_RECORDER
#import "ASScreenRecorder.h"
#endif

AVAudioPlayer  *MainAudio;

@interface MenuViewController ()<GKMatchmakerViewControllerDelegate,JetpackKnightViewControllerDelegate>

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
    
#ifdef ENABLE_SCREEN_RECORDER
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recorderGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:tapGesture];
#endif
    
    
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


- (void)presentMatchmakerWithInvite:(GKInvite*)invite {
    GKMatchmakerViewController *vc = [[GKMatchmakerViewController alloc] initWithInvite:invite];
    vc.matchmakerDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)didTapMakeMatch:(id)sender {
    GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init];
    matchRequest.minPlayers = 2;
    matchRequest.maxPlayers = 2;
    GKMatchmakerViewController *vc = [[GKMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
    vc.matchmakerDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - jetpackKnightViewController delegate

- (void)jetpackKnightGameOverBackToMenu:(JetpackKnightViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - matchmakerViewController delegate

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
    JetpackKnightViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JetpackKnightViewController"];
    vc.match = match;
    vc.delegate = self;
    [[[AppDelegate sharedInstance] activeViewController] presentViewController:vc animated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"matchmaker...didFailWithError: %@", [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#ifdef ENABLE_SCREEN_RECORDER
- (IBAction)recorderGesture:(id)sender {
    ASScreenRecorder *recorder = [ASScreenRecorder sharedInstance];
    
    if (recorder.isRecording) {
        [recorder stopRecordingWithCompletion:^{
            NSLog(@"Finished recording");
        }];
    } else {
        [recorder startRecording];
        NSLog(@"Start recording");
    }
}
#endif

@end
