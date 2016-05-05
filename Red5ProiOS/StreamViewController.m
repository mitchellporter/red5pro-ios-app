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
#import "PublishStreamUtility.h"

@interface StreamViewController ()

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *camera;
@property SettingsViewController *settingsViewController;
@property (weak, nonatomic) IBOutlet UIView *streamingView;

@property NSMutableDictionary *viewControllerMap;

@end

@implementation StreamViewController

- (void)displayCameraButtons:(BOOL)ok {
    if (ok) {
        self.camera.alpha = 1.0f;
        self.camera.enabled = YES;
    } else {
        self.camera.alpha = 0.5f;
        self.camera.enabled = NO;
    }
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
        case r5_example_publish: {
            [self loadStreamView:@"publishView"];
            PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
            
            [publisher stop:YES];
            break;
        }
        case r5_example_twoway: {
            [self loadTwoWayViews];
            PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
            
            [publisher updatePreview];
            break;
        }
        case r5_example_stream:
            [self loadStreamView:@"subscribeView"];
            break;
    }
    
   [self displayCameraButtons: self.currentMode != r5_example_stream];
}

- (void) startOrStartPublish {
    PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
    
    if (self.launchButton.selected) {
        [publisher start];
        self.launchButton.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.launchButton.enabled = true;
        });
        
        self.settingsButton.enabled = NO;
        self.settingsButton.alpha = 0.5f;
    } else {
        [publisher stop: YES];
        if(self.currentMode != r5_example_stream)
            [[self camera] setHidden:NO];
        
        self.settingsButton.enabled = YES;
        self.settingsButton.alpha = 1.0f;
        
        [self performSegueWithIdentifier:@"streamingViewToHomeView" sender:self];
    }
}

- (void) startOrStartSubscribe {
    VideoViewController *subscriber = (VideoViewController *)[[self viewControllerMap] objectForKey:@"subscribeView"];
    
    if (self.launchButton.selected) {
        [subscriber start];
        
        self.settingsButton.enabled = NO;
        self.settingsButton.alpha = 0.5f;
    } else {
        [subscriber stop];
        
        self.settingsButton.enabled = YES;
        self.settingsButton.alpha = 1.0f;
        
        [self performSegueWithIdentifier:@"streamingViewToHomeView" sender:self];
    }
}

- (void) startOrStopTwoWay {
    VideoViewController *subscriber = (VideoViewController *)[[self viewControllerMap] objectForKey:@"subscribeView"];
    PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
    
    if (self.launchButton.selected) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *connectToStream = (NSString *)[defaults objectForKey:@"connectToStream"];
        
        [subscriber startWithStreamName:connectToStream];
        
        self.launchButton.enabled = NO;
        
        self.settingsButton.enabled = NO;
        self.settingsButton.alpha = 0.5f;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.launchButton.enabled = true;
        });
    } else {
        [publisher stop: YES];
        [subscriber stop];
        
        self.settingsButton.enabled = YES;
        self.settingsButton.alpha = 1.0f;
        
        [self performSegueWithIdentifier:@"streamingViewToHomeView" sender:self];
    }
}

- (IBAction)onCameraTouch:(id)sender {
    self.launchButton.selected = !self.launchButton.selected;
    
    switch (self.currentMode) {
        case r5_example_publish:
            [self startOrStartPublish];
            break;
        case r5_example_twoway:
            [self startOrStopTwoWay];
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
            case r5_example_publish: {
                PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
                [publisher stop:YES];
                break;
            }
            
            case r5_example_twoway: {
                PublishViewController *publisher = (PublishViewController *)[[self viewControllerMap] objectForKey:@"publishView"];
                [publisher stop:YES];
                
                VideoViewController *subscriber = (VideoViewController *)[[self viewControllerMap] objectForKey:@"subscribeView"];
                [subscriber stop];
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

- (UIViewController *)viewControllerForIdentifier:(NSString *)identifier {
    UIViewController *vc = (UIViewController *)[self.viewControllerMap objectForKey:identifier];
    if (vc == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
        [self.viewControllerMap setObject:vc forKey:identifier];
    }
    return vc;
}

- (void)loadTwoWayViews {
    if (self.currentStreamView) {
        [self.currentStreamView removeFromParentViewController];
        [self.currentStreamView.view removeFromSuperview];
    }
    
    if (self.altStreamView) {
        [self.altStreamView removeFromParentViewController];
        [self.altStreamView.view removeFromSuperview];
    }
    
    VideoViewController *subscribe = (VideoViewController *)[self viewControllerForIdentifier:@"subscribeView"];
    PublishViewController *publish = (PublishViewController *)[self viewControllerForIdentifier:@"publishView"];
    
    subscribe.streamViewController = self;
    publish.streamViewController = self;
    
    self.currentStreamView = subscribe;
    self.altStreamView = publish;
    
    //  Add Publish
    CGRect smallFrame = self.view.bounds;
    float plannedWidth = smallFrame.size.width * 0.333f;
    float plannedHeight = smallFrame.size.height * 0.333f;
    smallFrame.origin.x = smallFrame.size.width - 16.0f /*padding*/ - plannedWidth;
    smallFrame.origin.y = smallFrame.size.height - 72.0f /*bottom pad*/ - 16.0f /*padding*/ - plannedHeight;
    smallFrame.size.width = plannedWidth;
    smallFrame.size.height = plannedHeight;
    
    publish.view.layer.frame = smallFrame;
    publish.view.frame = smallFrame;
    
    [self.view addSubview:publish.view];
    [self.view sendSubviewToBack:publish.view];
    
    //  Add Subscribe last
    CGRect largeFrame = self.view.bounds;
    largeFrame.size.height -= 72;
    
    subscribe.view.layer.frame = largeFrame;
    subscribe.view.frame = largeFrame;
    
    [self.view addSubview:subscribe.view];
    [self.view sendSubviewToBack:subscribe.view];
}

-(void)loadStreamView:(NSString *)viewID{
    if(self.currentStreamView){
        [self.currentStreamView removeFromParentViewController];
        [self.currentStreamView.view removeFromSuperview];
    }
    
    if (self.altStreamView) {
        [self.altStreamView removeFromParentViewController];
        [self.altStreamView.view removeFromSuperview];
    }
    
    UIViewController *myController = [self viewControllerForIdentifier:viewID];
    
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
