//
//  EmbeddedSubscribeAdvancedSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedSubscribeAdvancedSettingsViewController.h"

@interface EmbeddedSubscribeAdvancedSettingsViewController ()

@end

@implementation EmbeddedSubscribeAdvancedSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.appTextfield.delegate = self;
    self.streamTextfield.delegate = self;
    self.portTextfield.delegate = self;
    self.serverTextfield.delegate = self;
    
    [self.serverTextfield setReturnKeyType:UIReturnKeyNext];
    [self.portTextfield setReturnKeyType:UIReturnKeyNext];
    [self.appTextfield setReturnKeyType:UIReturnKeyNext];
    [self.streamTextfield setReturnKeyType:UIReturnKeyDone];
    
    self.streamTextfield.text = [self getUserSetting:@"stream" withDefault:@""];
    
    self.appTextfield.text = [self getUserSetting:@"app" withDefault:@"live"];
    self.serverTextfield.text = [self getUserSetting:@"domain" withDefault:@"127.0.0.1"];
    self.portTextfield.text = [self getUserSetting:@"port" withDefault:@"8554"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.serverTextfield) {
        [self.portTextfield becomeFirstResponder];
    } else if (textField == self.portTextfield) {
        [self.appTextfield becomeFirstResponder];
    } else if (textField == self.appTextfield) {
        [self.streamTextfield becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction) onBackTouch:(id)sender {
    if (self.settingsViewController != nil) {
        [self.settingsViewController goToSimpleForCurrentMode];
    }
}

- (IBAction) onDoneTouch:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //  TODO: Validate
    
    [defaults setObject:self.streamTextfield.text forKey:@"stream"];
    
    [defaults setObject:self.appTextfield.text forKey:@"app"];
    [defaults setObject:self.serverTextfield.text forKey:@"domain"];
    [defaults setObject:self.portTextfield.text forKey:@"port"];
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDefaultsChange" object:nil];
    
    if (self.settingsViewController != nil) {
        [self.settingsViewController doneSettings];
    }
}

@end
