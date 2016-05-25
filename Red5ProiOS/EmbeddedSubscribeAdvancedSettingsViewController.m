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
    
    self.streamTextfield.text = [self getUserSetting:@"stream" withDefault:@"stream"];
    
    self.appTextfield.text = [self getUserSetting:@"app" withDefault:@"live"];
    self.serverTextfield.text = [self getUserSetting:@"domain" withDefault:@"127.0.0.1"];
    self.portTextfield.text = [NSString stringWithFormat:@"%ld", [[NSUserDefaults standardUserDefaults] integerForKey:@"port"]];
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

#pragma mark - Validation

- (BOOL) allFieldsValid {
    if ([self allFieldsHaveContent]) {
        return YES;
    }
    return NO;
}

- (BOOL) allFieldsHaveContent {
    NSArray *validateTextfields = @[self.serverTextfield, self.portTextfield, self.appTextfield, self.streamTextfield];
    __block BOOL isInvalid = NO;
    [validateTextfields enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITextField *tf = (UITextField *)obj;
        
        if (tf.text.length == 0) {
            [tf becomeFirstResponder];
            isInvalid = YES;
            *stop = YES;
        }
    }];
    
    if (isInvalid) {
        return NO;
    }
    return YES;
}

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
    
    if (![self allFieldsValid]) {
        return;
    }
    
    [defaults setObject:self.streamTextfield.text forKey:@"stream"];
    
    [defaults setObject:self.appTextfield.text forKey:@"app"];
    [defaults setObject:self.serverTextfield.text forKey:@"domain"];
    [defaults setInteger:[self.portTextfield.text integerValue] forKey:@"port"];
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDefaultsChange" object:nil];
    
    if (self.settingsViewController != nil) {
        [self.settingsViewController doneSettings];
    }
}

@end
