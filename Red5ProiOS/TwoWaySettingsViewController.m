//
//  TwoWaySettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/3/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "TwoWaySettingsViewController.h"
#import "SettingsViewController.h"
#import "StreamViewController.h"

@interface TwoWaySettingsViewController ()

@end

@implementation TwoWaySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"twoWaySettingsToSettings"]) {
        SettingsViewController *settingsController = (SettingsViewController *)segue.destinationViewController;
        
        if(settingsController != nil && [settingsController respondsToSelector:@selector(setCurrentMode:)]) {
            settingsController.currentMode = self.currentMode;
        }
    } else if ([segue.identifier isEqualToString:@"twoWaySettingsToStreamView"]) {
        StreamViewController *streamController = (StreamViewController *)segue.destinationViewController;
        
        if (streamController != nil && [streamController respondsToSelector:@selector(setCurrentMode:)]) {
            streamController.currentMode = self.currentMode;
        }
    }
}

@end
