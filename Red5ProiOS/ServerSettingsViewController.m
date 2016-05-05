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
    
    [[self serverTextField] setDelegate:self];
    [[self portTextField] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapOutside:(id)sender {
    [self.serverTextField resignFirstResponder];
    [self.portTextField resignFirstResponder];
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

- (void) keyboardDidShow:(NSNotification *)notification {
    /*NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect currentFrame = self.view.frame;
    
    currentFrame.origin.y -= kbSize.height;
    
    self.view.layer.frame = currentFrame;
    self.view.frame = currentFrame;*/
}

- (void) keyboardDidHide:(NSNotification *)notification {
    /*CGRect currentFrame = self.view.frame;
    
    currentFrame.origin.y = 0;
    
    self.view.layer.frame = currentFrame;
    self.view.frame = currentFrame;*/
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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == [self serverTextField]) {
        [[self portTextField] becomeFirstResponder];
    } else if (textField == [self portTextField]) {
        [self performSegueWithIdentifier:@"goToMain" sender:nil];
    }
    return YES;
}

@end
