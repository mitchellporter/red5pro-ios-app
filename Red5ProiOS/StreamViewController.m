//
//  StreamViewController.m
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "StreamViewController.h"
#import "PublishViewController.h"
#import "VideoViewController.h"
#import "SettingsViewController.h"

@interface StreamViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsHeight;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *camera;
@property SettingsViewController *settingsViewController;
@property (weak, nonatomic) IBOutlet UIView *streamingView;

@property NSMutableDictionary *viewControllerMap;

@end

@implementation StreamViewController

- (void)displayCameraButtons:(BOOL)ok {
//    [[self launchButton] setHidden:NO];
    [[self camera] setHidden:!ok];
}

-(BOOL) updateMode:(enum StreamMode) mode {
    if(self.currentMode == mode) {
        return NO;
    }
    self.currentMode = mode;
    [self launchCurrentView];
    return YES;
}

-(void) launchCurrentView {
    switch(self.currentMode){
        case r5_example_publish:
        case r5_example_twoway:
            [self loadStreamView:@"publishView"];
            break;
        case r5_example_stream:
            [self loadStreamView:@"subscribeView"];
            break;
    }
    
   [self displayCameraButtons: self.currentMode == r5_example_publish];
}

- (void) startOrStartPublish {
    PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
    
    if (self.launchButton.selected) {
        [publisher start];
        self.launchButton.enabled = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.launchButton.enabled = true;
        });
    } else {
        [publisher stop: YES];
        if(self.currentMode != r5_example_stream)
            [[self camera] setHidden:NO];
        
        [self performSegueWithIdentifier:@"streamingViewToHomeView" sender:self];
    }
}

- (void) startOrStartSubscribe {
    VideoViewController *subscriber = (VideoViewController *)[[self viewControllerMap] objectForKey:@"subscribeView"];
    
    if (self.launchButton.selected) {
        [subscriber start];
    } else {
        [subscriber stop];
        [self performSegueWithIdentifier:@"streamingViewToHomeView" sender:self];
    }
}

- (IBAction)onCameraTouch:(id)sender {
    self.launchButton.selected = !self.launchButton.selected;
    
    switch (self.currentMode) {
        case r5_example_publish:
        case r5_example_twoway:
            [self startOrStartPublish];
            break;
        case r5_example_stream:
            [self startOrStartSubscribe];
            break;
        default:
            break;
    }
}

- (IBAction)onCameraSwitch:(id)sender {
    PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
    
    [publisher toggleCamera];
}

- (IBAction)onShowSettings:(id)sender {
    if (self.launchButton.selected) {
        switch (self.currentMode) {
            case r5_example_publish:
            case r5_example_twoway: {
                PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
                [publisher stop:YES];
                break;
            }
            
            case r5_example_stream: {
                VideoViewController *subscriber = (VideoViewController *)[[self viewControllerMap] objectForKey:@"subscribeView"];
                [subscriber stop];
                break;
            }
                
            default:
                break;
        }
    }
    
    [self performSegueWithIdentifier:@"streamingViewToSettingsView" sender:self];
}

-(void)loadStreamView:(NSString *)viewID{
    if(self.currentStreamView){
        [self.currentStreamView removeFromParentViewController];
        [self.currentStreamView.view removeFromSuperview];
    }
    
    UIViewController *myController = (UIViewController *)[[self viewControllerMap] objectForKey:viewID];
    if(myController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        myController = [storyboard instantiateViewControllerWithIdentifier:viewID];
        [[self viewControllerMap] setObject:myController forKey:viewID];
    }
    
    self.currentStreamView = myController;
    
    CGRect frameSize = self.view.bounds;
    frameSize.size.height -= 72;
    
    myController.view.layer.frame = frameSize;
    myController.view.frame = frameSize;
    
   // NSLog(@"Frame size: %f, %f, %f, %f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);

    [self.view addSubview:myController.view];
    [self.view sendSubviewToBack:myController.view];
    
    if ([myController isKindOfClass:[VideoViewController class]]) {
        VideoViewController *videoViewController = (VideoViewController *)myController;
        videoViewController.streamViewController = self;
    } else if ([myController isKindOfClass:[PublishViewController class]]) {
        PublishViewController *publishViewController = (PublishViewController *)myController;
        publishViewController.streamViewController = self;
    }
}

-(void)loadViewFromStoryboard:(NSString *)viewID {
    if(self.currentStreamView){
        [self.currentStreamView removeFromParentViewController];
        [self.currentStreamView.view removeFromSuperview];
    }
    
    UIViewController *myController = [[self viewControllerMap] objectForKey:viewID];
    if(myController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        myController = [storyboard instantiateViewControllerWithIdentifier:viewID];
        [[self viewControllerMap] setObject:myController forKey:viewID];
    }
    
    self.currentStreamView = myController;
    
    CGRect frameSize = self.view.bounds;
    frameSize.size.height -= 72;
    
    myController.view.layer.frame = frameSize;
    myController.view.frame = frameSize;
    
    [self.view addSubview:myController.view];
    [self.view sendSubviewToBack:myController.view];
    [myController.view updateConstraintsIfNeeded];
    [myController.view layoutIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllerMap = [NSMutableDictionary dictionary];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self launchCurrentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"streamingViewToSettingsView"]) {
        SettingsViewController *settingsView = (SettingsViewController *)segue.destinationViewController;
        
        if (settingsView != nil) {
            settingsView.currentMode = self.currentMode;
        }
    }
}

-(void)updateControllersOnSettings:(BOOL)shown {
    PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
    
    VideoViewController *subscriber = (VideoViewController *)[[self viewControllerMap] objectForKey:@"subscribeView"];
    
    if(shown == YES) {
        [self displayCameraButtons:NO];
        [self.launchButton setSelected:NO];
        [publisher stop : NO];
        [subscriber stop];
    } else {
        [self displayCameraButtons:self.currentMode == r5_example_publish];

    }
}

@end
