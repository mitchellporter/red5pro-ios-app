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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self goToSimpleForCurrentMode];
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
    [self.scrollView setContentInset:UIEdgeInsetsZero];
    
    [self removeLoadedView];
    
    CGRect rect = CGRectZero;
    rect.origin = self.containerView.frame.origin;
    rect.size = vc.view.frame.size;
    
//    [self.containerView addSubview:vc.view];
    
    [vc.view setFrame:rect];
    [self.containerView.superview addSubview:vc.view];
    
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    
    CGSize scrollSize = vc.view.bounds.size;
    scrollSize.height += [SlideNavigationController sharedInstance].navigationBar.bounds.size.height;
//    scrollSize.height += self.containerView.frame.origin.y;
    scrollSize.height += vc.view.frame.origin.y;
    [self.scrollView setContentSize:scrollSize];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, scrollSize.width, 1) animated:NO];
    
    self.loadedView = vc;
}

- (void) removeLoadedView {
    if (self.loadedView != nil) {
        [self.loadedView willMoveToParentViewController:nil];
        [self.loadedView.view removeFromSuperview];
        [self.loadedView didMoveToParentViewController:nil];
        self.loadedView = nil;
    }
}

- (void) goToAdvancedForCurrentMode {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EmbeddedSettingsViewController *vc;
    
    switch (self.currentMode) {
        case r5_example_publish: {
            vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishAdvancedSettings"];
            break;
        }
        case r5_example_stream: {
            vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedSubscribeAdvancedSettings"];
            break;
        }
        case r5_example_twoway: {
            vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishAdvancedSettings"];
            break;
        }
    }
    
    vc.settingsViewController = self;
    vc.currentMode = self.currentMode;
    
    [self addToContainerView:vc];
}

- (void) goToSimpleForCurrentMode {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EmbeddedSettingsViewController *vc;
    
    switch (self.currentMode) {
        case r5_example_publish: {
            vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishSettings"];
            break;
        }
        case r5_example_stream: {
            vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedSubscribeSettings"];
            break;
        }
        case r5_example_twoway: {
            vc = [storyboard instantiateViewControllerWithIdentifier:@"embeddedPublishSettings"];
            break;
        }
    }
    
    vc.settingsViewController = self;
    vc.currentMode = self.currentMode;
    
    [self addToContainerView:vc];
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
