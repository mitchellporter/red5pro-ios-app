//
//  SettingsViewController.m
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "SettingsViewController.h"
#import "TwoWaySettingsViewController.h"
#import "StreamViewController.h"

#import "EmbeddedPublishSettingsViewController.h"
#import "EmbeddedSubscribeSettingsViewController.h"
#import "EmbeddedPublishAdvancedSettingsViewController.h"
#import "EmbeddedSubscribeAdvancedSettingsViewController.h"

@interface SettingsViewController ()

@property UIViewController *loadedView;

@property float offset;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.offset = self.containerView.frame.origin.y;
    
    [self goToSimpleForCurrentMode];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[SlideNavigationController sharedInstance] setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([[SlideNavigationController sharedInstance] respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [SlideNavigationController sharedInstance].interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingsToTwoWaySettings"]) {
        TwoWaySettingsViewController *twoWayController = (TwoWaySettingsViewController *)segue.destinationViewController;
        
        if (twoWayController != nil && [twoWayController respondsToSelector:@selector(setCurrentMode:)]) {
            twoWayController.currentMode = self.currentMode;
        }
    } else if ([segue.identifier isEqualToString:@"settingsToStreamView"]) {
        StreamViewController *streamController = (StreamViewController *)segue.destinationViewController;
        
        if (streamController != nil && [streamController respondsToSelector:@selector(setCurrentMode:)]) {
            streamController.currentMode = self.currentMode;
        }
    }
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}

- (void) addToContainerView:(UIViewController *)vc {
    [self removeLoadedView];
    
    [vc willMoveToParentViewController:self];
    [self.containerView addSubview:vc.view];
    CGRect container = self.containerView.frame;
    CGRect child = vc.view.frame;
    
    child.origin.x = container.origin.x + (container.size.width * 0.5f) - (child.size.width * 0.5f);
    child.origin.y = 8.0f;
    
    [vc.view setFrame:child];
    
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    
    self.loadedView = vc;
}

- (void) removeLoadedView {
    if (self.loadedView != nil) {
        [self.loadedView willMoveToParentViewController:nil];
        [self.loadedView.view removeFromSuperview];
        [self.loadedView removeFromParentViewController];
        self.loadedView = nil;
    }
}

- (void) resetScrollView {
    UIEdgeInsets insets = UIEdgeInsetsMake(self.offset, 0.0f, 0.0f, 0.0f);
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
}

- (void) goToAdvancedForCurrentMode {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (self.currentMode) {
        case r5_example_publish: {
            EmbeddedPublishSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishAdvancedSettings"];
            vc.settingsViewController = self;
            
            [self addToContainerView:vc];
            break;
        }
        case r5_example_stream: {
            EmbeddedSubscribeSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedSubscribeAdvancedSettings"];
            vc.settingsViewController = self;
            
            [self addToContainerView:vc];
            break;
        }
        case r5_example_twoway: {
            EmbeddedPublishSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishAdvancedSettings"];
            vc.settingsViewController = self;
            
            [self addToContainerView:vc];
            break;
        }
    }
}

- (void) goToSimpleForCurrentMode {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (self.currentMode) {
        case r5_example_publish: {
            EmbeddedPublishSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishSettings"];
            vc.settingsViewController = self;
            
            [self addToContainerView:vc];
            break;
        }
        case r5_example_stream: {
            EmbeddedSubscribeSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedSubscribeSettings"];
            vc.settingsViewController = self;
            
            [self addToContainerView:vc];
            break;
        }
        case r5_example_twoway: {
            EmbeddedPublishSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishSettings"];
            vc.settingsViewController = self;
            
            [self addToContainerView:vc];
            break;
        }
    }
}

- (void) doneSettings {
    switch (self.currentMode) {
        case r5_example_publish:
        case r5_example_stream:
            [self performSegueWithIdentifier:@"settingsToStreamView" sender:self];
            break;
        case r5_example_twoway:
            [self performSegueWithIdentifier:@"settingsToTwoWaySettings" sender:self];
            break;
    }
}

@end
