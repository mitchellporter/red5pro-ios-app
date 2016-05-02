//
//  SettingsViewController.m
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property enum StreamMode currentMode;
@property UITextField *focusedField;
@property NSArray *qualityButtons;
@end

@implementation SettingsViewController

- (NSString*) getUserSetting:(NSString *)key withDefault:(NSString *)defaultValue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:key]) {
        return [defaults stringForKey:key];
    }
    return defaultValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.hidden = YES;

    self.app.delegate = self;
    self.stream.delegate = self;
    
    self.qualityButtons = [NSArray arrayWithObjects:self.lowQualityBtn, self.mediumQualityBtn, self.highQualityBtn, self.otherQualityBtn, nil];
}

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
        
        //  TODO: Account for advanced (index 3)?
        if (intIdx == index) {
            [btn setSelected:YES];
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
            //  TODO: Account for advanced (index 3)?
            [defaults setInteger:854 forKey:@"resolutionWidth"];
            [defaults setInteger:480 forKey:@"resolutionHeight"];
            [defaults setObject:@"1000" forKey:@"bitrate"];
            break;
    }
}

-(void)showSettingsForMode:(enum StreamMode) mode{
    self.currentMode = mode;
    
    self.view.hidden = NO;
    
    self.stream.text = [self getUserSetting:@"stream" withDefault:self.stream.text];
    self.audioCheck.selected = [[self getUserSetting:@"includeAudio" withDefault:@"1"] boolValue];
    self.videoCheck.selected = [[self getUserSetting:@"includeVideo" withDefault:@"1"] boolValue];
    self.adaptiveBitrateCheck.selected = [[self getUserSetting:@"adaptiveBitrate" withDefault:@"1"] boolValue];
    
    int savedQuality = [[self getUserSetting:@"quality" withDefault:@"1"] intValue];
    
    [self setSelectedQualityIndex:savedQuality];
    
    [[self publishDoneBtn] setHidden:YES];
    [[self subscribeDoneBtn] setHidden:YES];
    
    switch(self.currentMode) {
        case r5_example_publish:
            [self.streamSettingsForm setHidden:NO];
            [self.publishSettingsForm setHidden:NO];
            [[self publishDoneBtn] setHidden:NO];
            self.app.text = [self getUserSetting:@"app" withDefault:@"live"];
            break;
        case r5_example_stream:
            [self.streamSettingsForm setHidden:NO];
            [self.publishSettingsForm setHidden:YES];
            [[self subscribeDoneBtn] setHidden:NO];
            self.app.text = [self getUserSetting:@"app" withDefault:@"live"];
            break;
    }

}

- (IBAction)onDoneClicked:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.stream.text forKey:@"stream"];
    
    int selected = [self getSelectedQualityIndex];
    [self setQualityWithIndex:selected];
    
    [defaults setBool:self.audioCheck.selected forKey:@"includeAudio"];
    [defaults setBool:self.videoCheck.selected forKey:@"includeVideo"];
    [defaults setBool:self.adaptiveBitrateCheck.selected forKey:@"adaptiveBitrate"];
    
    switch (self.currentMode) {
        case r5_example_publish:
        case r5_example_stream:
            [defaults setObject:self.app.text forKey:@"app"];
            break;
    }
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDefaultsChange" object:nil];
    
    if(self.delegate)
        [self.delegate closeSettings];
}

- (BOOL)isHiddenKeyboardField:(UITextField *)field {
    return field == self.stream;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.focusedField = nil;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([self isHiddenKeyboardField:textField]) {
        [self animateTextField: textField up: YES];
    }
    self.focusedField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self isHiddenKeyboardField:textField]) {
        [self animateTextField: textField up: NO];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    const int movementDistance = 90;
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    }];
}

- (IBAction)onAudioClick:(id)sender {
    [[self audioCheck] setSelected:!self.audioCheck.selected];
}

- (IBAction)onVideoClick:(id)sender {
    [[self videoCheck] setSelected:!self.videoCheck.selected];
}

- (IBAction)onAdaptiveBitrateClick:(id)sender {
    [[self adaptiveBitrateCheck] setSelected:!self.adaptiveBitrateCheck.selected];
}

- (IBAction)onCloseButton:(id)sender {
    if(self.delegate)
        [self.delegate closeSettings];
}

- (IBAction)onQualityTap:(id)sender {
    UIButton *btn = (UIButton *)sender;
    int index = (int)[self.qualityButtons indexOfObject:btn];
    
    [self setSelectedQualityIndex:index];
    
    if (index < 3) {
        [self setQualityWithIndex:index];
    } else {
        // TODO: Show advanced
    }
}

@end
