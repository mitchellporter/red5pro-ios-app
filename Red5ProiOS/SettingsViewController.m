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
    
    
    CGRect viewBase = _scrollView.frame;
    [_scrollView setFrame:CGRectMake(viewBase.origin.x, viewBase.origin.y , viewBase.size.width, [[UIScreen mainScreen] bounds].size.height)];
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
    
//    vc.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGRect container = self.containerView.frame;
    CGRect child = vc.view.frame;
    
    [vc willMoveToParentViewController:self];
    [self.containerView addSubview:vc.view];
    
    child.origin.x = container.origin.x + (container.size.width * 0.5f) - (child.size.width * 0.5f);
    child.origin.y = 8.0f;
    
    [vc.view setFrame:child];
    
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    __block CGSize scrollSize = vc.view.bounds.size;
    __block float largestY = [[UIScreen mainScreen] bounds].size.height - self.containerView.frame.origin.y;
    
    [vc.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        float y = obj.frame.origin.y + obj.frame.size.height;
        if (y >= largestY) {
            largestY = y;
            scrollSize.height = largestY + 20.0f;
        }
    }];
    
    scrollSize.height += self.containerView.frame.origin.y;
    
    [_scrollView setContentSize:scrollSize];
    [_scrollView setNeedsLayout];
    [_scrollView layoutIfNeeded];
    
    [_containerView.superview setBounds:CGRectMake(_containerView.superview.bounds.origin.x, _containerView.superview.bounds.origin.y, _containerView.superview.bounds.size.width, scrollSize.height)];
    [_containerView setBounds:CGRectMake(_containerView.bounds.origin.x, _containerView.bounds.origin.y, _containerView.bounds.size.width, scrollSize.height - self.containerView.frame.origin.y)];
    [vc.view setBounds:CGRectMake(vc.view.bounds.origin.x, vc.view.bounds.origin.y, vc.view.bounds.size.width, scrollSize.height - self.containerView.frame.origin.y)];
    
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
