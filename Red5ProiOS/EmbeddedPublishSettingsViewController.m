//
//  EmbeddedPublishSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedPublishSettingsViewController.h"

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
    
    int savedQuality = [[self getUserSetting:@"quality" withDefault:@"1"] intValue];
    
    if (savedQuality < 3) {
        [self setSelectedQualityIndex:savedQuality];
    } else {
        if (self.settingsViewController != nil) {
            [self.settingsViewController goToAdvancedForCurrentMode];
        }
    }
    
    self.streamTextfield.text = [self getUserSetting:@"stream" withDefault:@""];
    if (self.streamTextfield.text.length > 0) {
        self.doneBtn.alpha = 1.0f;
        self.doneBtn.enabled = YES;
    } else {
        self.doneBtn.alpha = 0.5f;
        self.doneBtn.enabled = NO;
    }
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
            [defaults setObject:@"400" forKey:@"bitrate"];
            break;
        case 1:
            [defaults setInteger:854 forKey:@"resolutionWidth"];
            [defaults setInteger:480 forKey:@"resolutionHeight"];
            [defaults setObject:@"1000" forKey:@"bitrate"];
            break;
        case 2:
            [defaults setInteger:1920 forKey:@"resolutionWidth"];
            [defaults setInteger:1080 forKey:@"resolutionHeight"];
            [defaults setObject:@"4500" forKey:@"bitrate"];
            break;
        default:
            [defaults setInteger:854 forKey:@"resolutionWidth"];
            [defaults setInteger:480 forKey:@"resolutionHeight"];
            [defaults setObject:@"1000" forKey:@"bitrate"];
            break;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.streamTextfield) {
        if (textField.text.length > 0) {
            self.doneBtn.alpha = 1.0f;
            self.doneBtn.enabled = YES;
        } else {
            self.doneBtn.alpha = 0.5f;
            self.doneBtn.enabled = NO;
        }
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.streamTextfield) {
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.streamTextfield.text forKey:@"stream"];
    
    if (self.settingsViewController != nil) {
        [self.settingsViewController doneSettings];
    }
}

@end
