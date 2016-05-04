//
//  SettingsViewController.m
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "SettingsViewController.h"
#import "TwoWaySettingsViewController.h"
#import "StreamViewController.h"

@interface SettingsViewController ()

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

    self.app.delegate = self;
    self.stream.delegate = self;
    self.advancedStream.delegate = self;
    self.port.delegate = self;
    self.server.delegate = self;
    self.bitrate.delegate = self;
    self.resolution.delegate = self;
    
    self.qualityButtons = [NSArray arrayWithObjects:self.lowQualityBtn, self.mediumQualityBtn, self.highQualityBtn, self.otherQualityBtn, nil];
    
    self.stream.text = [self getUserSetting:@"stream" withDefault:self.stream.text];
    self.advancedStream.text = self.stream.text;
    
    self.audioCheck.selected = [[self getUserSetting:@"includeAudio" withDefault:@"1"] boolValue];
    self.videoCheck.selected = [[self getUserSetting:@"includeVideo" withDefault:@"1"] boolValue];
    self.adaptiveBitrateCheck.selected = [[self getUserSetting:@"adaptiveBitrate" withDefault:@"1"] boolValue];
    
    self.app.text = [self getUserSetting:@"app" withDefault:@"live"];
    self.server.text = [self getUserSetting:@"domain" withDefault:@"127.0.0.1"];
    self.port.text = [self getUserSetting:@"port" withDefault:@"8554"];
    
    int savedQuality = [[self getUserSetting:@"quality" withDefault:@"1"] intValue];
    
    if (savedQuality < 3) {
        [self setSelectedQualityIndex:savedQuality];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.bitrate.text = (NSString *)[defaults objectForKey:@"bitrate"];
        NSString *resWidth = (NSString *)[defaults objectForKey:@"resolutionWidth"];
        NSString *resHeight = (NSString *)[defaults objectForKey:@"resolutionHeight"];
        self.resolution.text = [NSString stringWithFormat:@"%@x%@", resWidth, resHeight];
        [self showAdvancedSettings];
    }
    
    switch(self.currentMode) {
        case r5_example_publish:
            [self.streamSettingsForm setHidden:NO];
            [self.publishSettingsForm setHidden:NO];
            [[self doneBtn] setTitle:@"PUBLISH" forState:UIControlStateNormal];
            break;
        case r5_example_stream:
            [self.streamSettingsForm setHidden:NO];
            [self.publishSettingsForm setHidden:YES];
            [[self doneBtn] setTitle:@"SUBSCRIBE" forState:UIControlStateNormal];
            break;
        case r5_example_twoway:
            [self.streamSettingsForm setHidden:NO];
            [self.publishSettingsForm setHidden:NO];
            [[self doneBtn] setTitle:@"NEXT" forState:UIControlStateNormal];
            break;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingsToTwoWaySettings"]) {
        TwoWaySettingsViewController *twoWayController = (TwoWaySettingsViewController *)segue.destinationViewController;
        
        if (twoWayController != nil && [twoWayController respondsToSelector:@selector(setCurrentMode:)]) {
            twoWayController.currentMode = self.currentMode;
        }
    } else if ([segue.identifier isEqualToString:@"settingsToStreamView"]) {
        StreamViewController *streamController = (StreamViewController *)segue.destinationViewController;
        
        if (streamController != nil && [streamController respondsToSelector:@selector(setCurrentMode:)]) {
            streamController.currentMode = self.currentMode;
        }
    }
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
            self.bitrate.text = @"400";
            self.resolution.text = @"426x240";
            break;
        case 1:
            [defaults setInteger:854 forKey:@"resolutionWidth"];
            [defaults setInteger:480 forKey:@"resolutionHeight"];
            [defaults setObject:@"1000" forKey:@"bitrate"];
            self.bitrate.text = @"1000";
            self.resolution.text = @"854x480";
            break;
        case 2:
            [defaults setInteger:1920 forKey:@"resolutionWidth"];
            [defaults setInteger:1080 forKey:@"resolutionHeight"];
            [defaults setObject:@"4500" forKey:@"bitrate"];
            self.bitrate.text = @"4500";
            self.resolution.text = @"1920x1080";
            break;
        default:
            [defaults setInteger:854 forKey:@"resolutionWidth"];
            [defaults setInteger:480 forKey:@"resolutionHeight"];
            [defaults setObject:@"1000" forKey:@"bitrate"];
            self.bitrate.text = @"1000";
            self.resolution.text = @"854x480";
            break;
    }
}

- (IBAction)onDoneClicked:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int selected = [self getSelectedQualityIndex];
    [self setQualityWithIndex:selected];
    
    [defaults setBool:self.audioCheck.selected forKey:@"includeAudio"];
    [defaults setBool:self.videoCheck.selected forKey:@"includeVideo"];
    [defaults setBool:self.adaptiveBitrateCheck.selected forKey:@"adaptiveBitrate"];
    
    [defaults setObject:self.stream.text forKey:@"stream"];
    [defaults setObject:self.app.text forKey:@"app"];
    [defaults setObject:self.server.text forKey:@"domain"];
    [defaults setObject:self.port.text forKey:@"port"];
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDefaultsChange" object:nil];
    
    switch (self.currentMode) {
        case r5_example_publish:
        case r5_example_stream:
            [self performSegueWithIdentifier:@"settingsToStreamView" sender:self];
            break;
        case r5_example_twoway:
            [self performSegueWithIdentifier:@"settingsToTwoWaySettings" sender:self];
            break;
    }
}

- (BOOL)isHiddenKeyboardField:(UITextField *)field {
    return field == self.stream || field == self.advancedStream;
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
    
    if (textField == self.stream) {
        self.advancedStream.text = self.stream.text;
    } else if (textField == self.advancedStream) {
        self.stream.text = textField.text;
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    const int movementDistance = 90;
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    }];
}

- (void) showAdvancedSettings {
    [self.advancedSettingsView setAlpha:0.0f];
    [self.advancedSettingsView setHidden:NO];
    
    [UIView animateWithDuration:0.16f animations:^{
        [self.advancedSettingsView setAlpha:1.0f];
    }];
}

- (void) hideAdvancedSettings {
    [UIView animateWithDuration:0.16f animations:^{
        [self.advancedSettingsView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.advancedSettingsView setHidden:YES];
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

- (IBAction)onQualityTap:(id)sender {
    UIButton *btn = (UIButton *)sender;
    int oldIndex = [self getSelectedQualityIndex];
    int index = (int)[self.qualityButtons indexOfObject:btn];
    
    if (index < 3) {
        [self setSelectedQualityIndex:index];
        [self setQualityWithIndex:index];
    } else {
        [self setSelectedQualityIndex:oldIndex];
        [self showAdvancedSettings];
    }
}

- (IBAction)onAdvancedSettingsTouch:(id)sender {
    [self showAdvancedSettings];
}

- (IBAction)onBackTouch:(id)sender {
    if (self.advancedSettingsView.isHidden) {
        [self performSegueWithIdentifier:@"settingsToHomeView" sender:self];
    } else {
        [self hideAdvancedSettings];
    }
}

@end
