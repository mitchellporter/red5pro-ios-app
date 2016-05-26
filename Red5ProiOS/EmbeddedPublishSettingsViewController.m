//
//  EmbeddedPublishSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedPublishSettingsViewController.h"
#import "ValidationUtility.h"

@interface EmbeddedPublishSettingsViewController ()

@property NSArray *qualityButtons;

@end

@implementation EmbeddedPublishSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.streamTextfield.delegate = self;
    
    [self.streamTextfield setReturnKeyType:UIReturnKeyDone];
    
    self.qualityButtons = @[self.lQualityBtn, self.mQualityBtn, self.hQualityBtn, self.oQualityBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int savedQuality = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"quality"];
    
    if (savedQuality < 3) {
        [self setSelectedQualityIndex:savedQuality];
    } else {
        if (self.settingsViewController != nil) {
            [self.settingsViewController goToAdvancedForCurrentMode];
        }
    }
    
    self.streamTextfield.text = [self getUserSetting:@"stream" withDefault:@"stream"];
    if (self.streamTextfield.text.length > 0) {
        self.doneBtn.alpha = 1.0f;
        self.doneBtn.enabled = YES;
    } else {
        self.doneBtn.alpha = 0.5f;
        self.doneBtn.enabled = NO;
    }
    
    if (self.currentMode == r5_example_twoway) {
        [self.doneBtn setTitle:@"NEXT" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
 
- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return [self isValid];
}

#pragma mark - Helpers

- (int)getSelectedQualityIndex {
    __block int index = -1;
    [self.qualityButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = (UIButton *) obj;
        if (btn.selected) {
            index = (int) idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)setSelectedQualityIndex:(int)index {
    [self.qualityButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = (UIButton *) obj;
        int intIdx = (int)idx;
        
        if (intIdx == index) {
            [btn setSelected:YES];
            
            [self setQualityWithIndex:intIdx];
        } else {
            [btn setSelected:NO];
        }
    }];
}

- (void)setQualityWithIndex:(int)index {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:index forKey:@"quality"];
    
    switch (index) {
        case 0:
            [defaults setInteger:426 forKey:@"resolutionWidth"];
            [defaults setInteger:240 forKey:@"resolutionHeight"];
            [defaults setInteger:400 forKey:@"bitrate"];
            break;
        case 2:
            [defaults setInteger:1920 forKey:@"resolutionWidth"];
            [defaults setInteger:1080 forKey:@"resolutionHeight"];
            [defaults setInteger:4500 forKey:@"bitrate"];
            break;
        default:
            [defaults setInteger:854 forKey:@"resolutionWidth"];
            [defaults setInteger:480 forKey:@"resolutionHeight"];
            [defaults setInteger:1000 forKey:@"bitrate"];
            break;
    }
}

#pragma mark - Validation

- (BOOL) isValid {
    NSString *stream = [ValidationUtility trimString:self.streamTextfield.text];
    enum StreamValidationCode streamValidationCode = [ValidationUtility isValidStream:stream];
    
    BOOL isValidStream = [ValidationUtility streamValidationCodeHasGoodFormat:streamValidationCode] && [ValidationUtility streamValidationCodeHasGoodLength:streamValidationCode];
    
    if (!isValidStream) {
        [self.streamTextfield becomeFirstResponder];
        [ValidationUtility flashRed:self.streamTextfield];
        
        self.doneBtn.alpha = 0.5f;
        self.doneBtn.enabled = NO;
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:stream forKey:@"stream"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.doneBtn.alpha = 1.0f;
    self.doneBtn.enabled = YES;
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.streamTextfield) {
        [self isValid];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.streamTextfield) {
        [self isValid];
        [self.view endEditing:YES];
    }
    return YES;
}

#pragma mark - IBActions

- (IBAction) onAdvancedTouch:(id)sender {
    if (self.settingsViewController != nil) {
        [self.settingsViewController goToAdvancedForCurrentMode];
    }
}

- (IBAction)onQualityTap:(id)sender {
    UIButton *btn = (UIButton *)sender;
    int oldIndex = [self getSelectedQualityIndex];
    int index = (int)[self.qualityButtons indexOfObject:btn];
    
    if (index < 3) {
        [self setSelectedQualityIndex:index];
        [self setQualityWithIndex:index];
    } else {
        [self setSelectedQualityIndex:oldIndex];
        
        if (self.settingsViewController != nil) {
            [self.settingsViewController goToAdvancedForCurrentMode];
        }
    }
}

- (IBAction) onDoneTouch:(id)sender {
    if (![self isValid]) {
        return;
    }
    
    if (self.settingsViewController != nil) {
        [self.settingsViewController doneSettings];
    }
}

@end
