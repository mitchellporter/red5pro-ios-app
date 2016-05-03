//
//  HomeViewController.m
//  Red5ProiOS
//
//  Created by Andy Zupko on 10/9/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"

@interface HomeViewController()
@property enum StreamMode selectedMode;
@end

@implementation HomeViewController
- (IBAction)onPublishTouch:(id)sender {
    self.selectedMode = r5_example_publish;
}

- (IBAction)onSubscribeTouch:(id)sender {
    self.selectedMode = r5_example_stream;
}

- (IBAction)onTwoWayTouch:(id)sender {
    self.selectedMode = r5_example_twoway;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    SettingsViewController *settingsController = (SettingsViewController *)segue.destinationViewController;
    if(settingsController != nil && [settingsController respondsToSelector:@selector(setCurrentMode:)]) {
        settingsController.currentMode = self.selectedMode;
    }
}

@end
