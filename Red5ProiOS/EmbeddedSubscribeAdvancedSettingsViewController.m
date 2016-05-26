//
//  EmbeddedSubscribeAdvancedSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedSubscribeAdvancedSettingsViewController.h"
#import "ValidationUtility.h"

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
    
    self.streamTextfield.text = [self getUserSetting:@"connectToStream" withDefault:@"stream"];
    
    self.appTextfield.text = [self getUserSetting:@"app" withDefault:@"live"];
    self.serverTextfield.text = [self getUserSetting:@"domain" withDefault:@"127.0.0.1"];
    self.portTextfield.text = [NSString stringWithFormat:@"%ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"port"]];
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

- (BOOL) validateServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *server = [ValidationUtility trimString:self.serverTextfield.text];
    
    enum ServerValidationCode isServerValid = [ValidationUtility isValidServer:server];
    
    BOOL serverHasGoodFormat = [ValidationUtility serverValidationCodeHasGoodFormat:isServerValid];
    BOOL serverHasGoodLength = [ValidationUtility serverValidationCodeHasGoodLength:isServerValid];
    BOOL serverHasGoodSegments = [ValidationUtility serverValidationCodeHasGoodSegments:isServerValid];
    
    if (serverHasGoodFormat && serverHasGoodLength && serverHasGoodSegments) {
        [defaults setObject:server forKey:@"domain"];
        [defaults synchronize];
        return YES;
    }
    
    [ValidationUtility flashRed:self.serverTextfield];
    
    return NO;
}

- (BOOL) validatePort {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *port = [ValidationUtility trimString:self.portTextfield.text];
    
    enum PortValidationCode isPortValid = [ValidationUtility isValidPort:port];
    
    BOOL portHasGoodLength = [ValidationUtility portValidationCodeHasGoodLength:isPortValid];
    BOOL portHasGoodFormat = [ValidationUtility portValidationCodeHasGoodFormat:isPortValid];
    
    if (portHasGoodFormat && portHasGoodLength) {
        [defaults setInteger:[port integerValue] forKey:@"port"];
        [defaults synchronize];
        return YES;
    }
    
    [ValidationUtility flashRed:self.portTextfield];
    
    return NO;
}

- (BOOL) validateApp {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *app = [ValidationUtility trimString:self.appTextfield.text];
    
    enum AppValidationCode isAppValid = [ValidationUtility isValidApp:app];
    
    BOOL appHasGoodFormat = [ValidationUtility appValidationCodeHasGoodFormat:isAppValid];
    BOOL appHasGoodLength = [ValidationUtility appValidationCodeHasGoodLength:isAppValid];
    
    if (appHasGoodFormat && appHasGoodLength) {
        [defaults setObject:app forKey:@"app"];
        [defaults synchronize];
        return YES;
    }
    
    [ValidationUtility flashRed:self.appTextfield];
    
    return NO;
}

- (BOOL) validateStream {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *stream = [ValidationUtility trimString:self.streamTextfield.text];
    
    enum StreamValidationCode isStreamValid = [ValidationUtility isValidStream:stream];
    
    BOOL streamHasGoodFormat = [ValidationUtility streamValidationCodeHasGoodFormat:isStreamValid];
    BOOL streamHasGoodLength = [ValidationUtility streamValidationCodeHasGoodLength:isStreamValid];
    
    if (streamHasGoodFormat && streamHasGoodLength) {
        [defaults setObject:stream forKey:@"connectToStream"];
        [defaults synchronize];
        return YES;
    }
    
    [ValidationUtility flashRed:self.streamTextfield];
    
    return NO;
}

- (BOOL) allFieldsValid {
    return  [self validateServer] &&
            [self validatePort] &&
            [self validateApp] &&
            [self validateStream];
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

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.serverTextfield) {
        [self validateServer];
    } else if (textField == self.portTextfield) {
        [self validatePort];
    } else if (textField == self.appTextfield) {
        [self validateApp];
    } else if (textField == self.streamTextfield) {
        [self validateStream];
    }
}

#pragma mark - IBActions

- (IBAction) onBackTouch:(id)sender {
    if (self.settingsViewController != nil) {
        [self.settingsViewController goToSimpleForCurrentMode];
    }
}

- (IBAction) onDoneTouch:(id)sender {
    if (![self allFieldsValid]) {
        return;
    }
    
    if (self.settingsViewController != nil) {
        [self.settingsViewController doneSettings];
    }
}

@end
