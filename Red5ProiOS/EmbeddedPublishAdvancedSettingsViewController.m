//
//  EmbeddedPublishAdvancedSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedPublishAdvancedSettingsViewController.h"
#import "ValidationUtility.h"

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.streamTextfield.text = [self getUserSetting:@"stream" withDefault:@"stream"];
    
    self.audioCheck.selected = [defaults boolForKey:@"includeAudio"];
    self.videoCheck.selected = [defaults boolForKey:@"includeVideo"];
    self.adaptiveBitrateCheck.selected = [defaults boolForKey:@"adaptiveBitrate"];
    self.debugCheck.selected = [defaults boolForKey:@"debugOn"];
    
    self.appTextfield.text = [self getUserSetting:@"app" withDefault:@"live"];
    self.serverTextfield.text = [self getUserSetting:@"domain" withDefault:@"127.0.0.1"];
    self.portTextfield.text = [self getUserSetting:@"port" withDefault:@"8554"];
    
    self.bitrateTextfield.text = [NSString stringWithFormat:@"%ld", (long)[defaults integerForKey:@"bitrate"]];
    NSString *resWidth = [NSString stringWithFormat:@"%ld", (long)[defaults integerForKey:@"resolutionWidth"]];
    NSString *resHeight = [NSString stringWithFormat:@"%ld", (long)[defaults integerForKey:@"resolutionHeight"]];
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

- (void) shouldEnableDoneButton:(BOOL)shouldEnable {
    if (shouldEnable) {
        [self.doneBtn setAlpha:1.0f];
        [self.doneBtn setEnabled:YES];
    } else {
        [self.doneBtn setAlpha:0.5f];
        [self.doneBtn setEnabled:YES];
    }
}

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
    
    NSLog(@"Have app %@", app);
    enum AppValidationCode isAppValid = [ValidationUtility isValidApp:app];
    
    NSLog(@"App validation code: %ld", (long)isAppValid);
    
    BOOL appHasGoodLength = [ValidationUtility appValidationCodeHasGoodLength:isAppValid];
    BOOL appHasGoodFormat = [ValidationUtility appValidationCodeHasGoodFormat:isAppValid];
    
    if (!appHasGoodFormat) NSLog(@"App does not have good format");
    if (!appHasGoodLength) NSLog(@"App does not have good length");
    
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
    
    BOOL streamHasGoodLength = [ValidationUtility streamValidationCodeHasGoodLength:isStreamValid];
    BOOL streamHasGoodFormat = [ValidationUtility streamValidationCodeHasGoodFormat:isStreamValid];
    
    if (streamHasGoodFormat && streamHasGoodLength) {
        [defaults setObject:stream forKey:@"stream"];
        [defaults synchronize];
        return YES;
    }
    
    [ValidationUtility flashRed:self.streamTextfield];
    
    return NO;
}

- (BOOL) validateBitrate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bitrate = [ValidationUtility trimString:self.bitrateTextfield.text];
    
    enum LengthValidationCode bitrateLengthCode = [ValidationUtility isValidLength:bitrate];
    
    BOOL bitrateHasGoodLength = bitrateLengthCode != LengthValidationCode_BAD_LENGTH;
    BOOL bitrateHasGoodFormat = [self bitrateIsPositive];
    
    if (bitrateHasGoodFormat && bitrateHasGoodLength) {
        [defaults setInteger:[bitrate integerValue] forKey:@"bitrate"];
        [defaults synchronize];
        return YES;
    }
    
    [ValidationUtility flashRed:self.bitrateTextfield];
    
    return NO;
}

- (BOOL) validateResolution {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *resolution = [ValidationUtility trimString:self.resolutionTextfield.text];
    
    enum LengthValidationCode resolutionLengthCode = [ValidationUtility isValidLength:resolution];
    
    BOOL resolutionHasGoodLength = resolutionLengthCode != LengthValidationCode_BAD_LENGTH;
    BOOL resolutionHasGoodFormat = [self resolutionIsValid];
    
    if (resolutionHasGoodFormat && resolutionHasGoodLength) {
        NSRange xRange = [resolution rangeOfString:@"x"];
        NSString *resWidth = [resolution substringToIndex:xRange.location];
        NSString *resHeight = [resolution substringFromIndex:(xRange.location + xRange.length)];
        
        [defaults setInteger:[resWidth integerValue] forKey:@"resolutionWidth"];
        [defaults setInteger:[resHeight integerValue] forKey:@"resolutionHeight"];
        [defaults synchronize];
        return YES;
    }
    
    [ValidationUtility flashRed:self.resolutionTextfield];
    
    return NO;
}

- (BOOL) allFieldsValid {
    return  [self validateServer] &&
            [self validatePort] &&
            [self validateApp] &&
            [self validateStream] &&
            [self validateBitrate] &&
            [self validateResolution];
}

- (BOOL) bitrateIsPositive {
    NSInteger intValue = [[ValidationUtility trimString:self.bitrateTextfield.text] integerValue];
    
    if (intValue <= 0) {
        [ValidationUtility flashRed:self.bitrateTextfield];
        
        return NO;
    }
    
    return YES;
}

- (BOOL) resolutionIsValid {
    NSString *str = [ValidationUtility trimString:self.resolutionTextfield.text];
    NSRange rangeOfSeparator = [str rangeOfString:@"x"];
    
    if (rangeOfSeparator.location == NSNotFound) {
        [ValidationUtility flashRed:self.resolutionTextfield];
        
        return NO;
    }
    
    NSString *w = [str substringToIndex:rangeOfSeparator.location];
    NSString *h = [str substringFromIndex:(rangeOfSeparator.location + rangeOfSeparator.length)];
    NSInteger wInt = [w integerValue];
    NSInteger hInt = [h integerValue];
    
    if (wInt <= 0 || hInt <= 0) {
        [ValidationUtility flashRed:self.resolutionTextfield];
        
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

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.serverTextfield) {
        [self validateServer];
    } else if (textField == self.portTextfield) {
        [self validatePort];
    } else if (textField == self.appTextfield) {
        [self validateApp];
    } else if (textField == self.streamTextfield) {
        [self validateStream];
    } else if (textField == self.bitrateTextfield) {
        [self validateBitrate];
    } else if (textField == self.resolutionTextfield) {
        [self validateResolution];
    }
}

#pragma mark - IBActions

- (IBAction) onCheckboxTouch:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        
        NSString *key = btn == self.audioCheck ? @"includeAudio" : btn == self.videoCheck ? @"includeVideo" : btn == self.adaptiveBitrateCheck ? @"adaptiveBitrate" : @"debugOn";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setBool:btn.selected forKey:key];
        [defaults synchronize];
    }
}

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
