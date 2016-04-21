//
//  ServerSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 4/20/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "ServerSettingsViewController.h"

@interface ServerSettingsViewController ()

@end

@implementation ServerSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *server = [self getUserSetting:@"domain" withDefault:@"0.0.0.0"];
    
    if (![server isEqualToString:@"0.0.0.0"]) {
        self.serverTextField.text = server;
    }
    self.portTextField.text = [self getUserSetting:@"port" withDefault:self.portTextField.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

- (NSString *)getUserSetting:(NSString *)key withDefault:(NSString *)defaultValue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:key]) {
        return [defaults stringForKey:key];
    }
    return defaultValue;
}

- (void)setUserSetting:(NSString *)key withValue:(NSString *)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:value forKey:key];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"goToMain"]) {
        NSString *port = [self.portTextField text];
        NSString *server = [self.serverTextField text];
        
        BOOL shouldPerformSegue = port.length > 0 && server.length > 0;
        
        if (!shouldPerformSegue) {
            [UIView animateWithDuration:0.25f animations:^{
                self.errorLabel.alpha = 1.0f;
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25f animations:^{
                        self.errorLabel.alpha = 0.0f;
                    }];
                });
            }];
        } else {
            [self setUserSetting:@"domain" withValue:server];
            [self setUserSetting:@"port" withValue:port];
        }
        
        return shouldPerformSegue;
    }
    return YES;
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

@end
