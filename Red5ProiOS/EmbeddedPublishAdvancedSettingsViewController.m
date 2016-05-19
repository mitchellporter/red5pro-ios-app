//
//  EmbeddedPublishAdvancedSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedPublishAdvancedSettingsViewController.h"

@interface EmbeddedPublishAdvancedSettingsViewController ()

@end

@implementation EmbeddedPublishAdvancedSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.appTextfield.delegate = self;
    self.streamTextfield.delegate = self;
    self.portTextfield.delegate = self;
    self.serverTextfield.delegate = self;
    self.bitrateTextfield.delegate = self;
    self.resolutionTextfield.delegate = self;
    
    [self.serverTextfield setReturnKeyType:UIReturnKeyNext];
    [self.portTextfield setReturnKeyType:UIReturnKeyNext];
    [self.appTextfield setReturnKeyType:UIReturnKeyNext];
    [self.streamTextfield setReturnKeyType:UIReturnKeyNext];
    [self.bitrateTextfield setReturnKeyType:UIReturnKeyNext];
    [self.resolutionTextfield setReturnKeyType:UIReturnKeyDone];
    
    self.streamTextfield.text = [self getUserSetting:@"stream" withDefault:@""];
    
    self.audioCheck.selected = [[self getUserSetting:@"includeAudio" withDefault:@"1"] boolValue];
    self.videoCheck.selected = [[self getUserSetting:@"includeVideo" withDefault:@"1"] boolValue];
    self.adaptiveBitrateCheck.selected = [[self getUserSetting:@"adaptiveBitrate" withDefault:@"1"] boolValue];
    
    self.appTextfield.text = [self getUserSetting:@"app" withDefault:@"live"];
    self.serverTextfield.text = [self getUserSetting:@"domain" withDefault:@"127.0.0.1"];
    self.portTextfield.text = [self getUserSetting:@"port" withDefault:@"8554"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.bitrateTextfield.text = (NSString *)[defaults objectForKey:@"bitrate"];
    NSString *resWidth = (NSString *)[defaults objectForKey:@"resolutionWidth"];
    NSString *resHeight = (NSString *)[defaults objectForKey:@"resolutionHeight"];
    self.resolutionTextfield.text = [NSString stringWithFormat:@"%@x%@", resWidth, resHeight];
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
        if ([self bitrateIsPositive]) {
            if ([self resolutionIsValid]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) allFieldsHaveContent {
    NSArray *validateTextfields = @[self.serverTextfield, self.portTextfield, self.appTextfield, self.streamTextfield, self.bitrateTextfield, self.resolutionTextfield];
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

- (BOOL) bitrateIsPositive {
    NSInteger intValue = [self.bitrateTextfield.text integerValue];
    
    if (intValue <= 0) {
        [self.bitrateTextfield becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL) resolutionIsValid {
    NSString *str = self.resolutionTextfield.text;
    NSRange rangeOfSeparator = [str rangeOfString:@"x"];
    
    if (rangeOfSeparator.location == NSNotFound) {
        [self.resolutionTextfield becomeFirstResponder];
        return NO;
    }
    
    NSString *w = [str substringToIndex:rangeOfSeparator.location];
    NSString *h = [str substringFromIndex:(rangeOfSeparator.location + rangeOfSeparator.length)];
    NSInteger wInt = [w integerValue];
    NSInteger hInt = [h integerValue];
    
    if (wInt <= 0 || hInt <= 0) {
        [self.resolutionTextfield becomeFirstResponder];
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
    } else if (textField == self.streamTextfield) {
        [self.bitrateTextfield becomeFirstResponder];
    } else if (textField == self.bitrateTextfield) {
        [self.resolutionTextfield becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction) onCheckboxTouch:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
    }
}

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
    
    [defaults setBool:self.audioCheck.selected forKey:@"includeAudio"];
    [defaults setBool:self.videoCheck.selected forKey:@"includeVideo"];
    [defaults setBool:self.adaptiveBitrateCheck.selected forKey:@"adaptiveBitrate"];
    [defaults setObject:self.appTextfield.text forKey:@"app"];
    [defaults setObject:self.serverTextfield.text forKey:@"domain"];
    [defaults setObject:self.portTextfield.text forKey:@"port"];
    
    NSString *res = self.resolutionTextfield.text;
    NSRange xRange = [res rangeOfString:@"x"];
    NSString *resWidth = [res substringToIndex:xRange.location];
    NSString *resHeight = [res substringFromIndex:(xRange.location + xRange.length)];
    
    [defaults setObject:resWidth forKey:@"resolutionWidth"];
    [defaults setObject:resHeight forKey:@"resolutionHeight"];
    
    [defaults setObject:self.bitrateTextfield.text forKey:@"bitrate"];
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDefaultsChange" object:nil];
    
    if (self.settingsViewController != nil) {
        [self.settingsViewController doneSettings];
    }
}

@end
