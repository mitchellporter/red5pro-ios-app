//
//  SideNavigationViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/12/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "SideNavigationViewController.h"
#import "SettingsViewController.h"
#import "SlideNavigationController.h"
#import "HelpDialogSegue.h"
#import "HelpDialogViewController.h"

@interface SideNavigationViewController ()

@end

@implementation SideNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
 */

#pragma mark - IBActions

- (IBAction)onPublishTap:(id)sender {
    [self goToSettingsWithMode:r5_example_publish];
}

- (IBAction)onSubscribeTap:(id)sender {
    [self goToSettingsWithMode:r5_example_stream];
}

- (IBAction)onTwoWayTap:(id)sender {
    [self goToSettingsWithMode:r5_example_twoway];
}

- (IBAction)onServerSettingsTap:(id)sender {
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
}

- (IBAction)onHelpTap:(id)sender {
    HelpDialogViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"helpView"];
    HelpDialogSegue *segue = [[HelpDialogSegue alloc] initWithIdentifier:@"currentViewToHelp" source:[SlideNavigationController sharedInstance].viewControllers.lastObject destination:vc];
    
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
    
    [segue perform];
}

#pragma mark - Helper methods

- (void) goToSettingsWithMode:(enum StreamMode)mode {
    UIViewController *current = [SlideNavigationController sharedInstance].viewControllers.lastObject;
    
    if ([current isKindOfClass:[SettingsViewController class]]) {
        SettingsViewController *present = (SettingsViewController *)current;
        if (present.currentMode == mode) {
            return;
        }
    }
    
    SettingsViewController *vc = (SettingsViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"settings"];
    vc.currentMode = mode;
    [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
}

@end
