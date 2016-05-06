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
#import "PublishStreamUtility.h"
#import "StreamTableViewCell.h"

@interface SettingsViewController ()

@property UITextField *focusedField;
@property NSArray *qualityButtons;
@property NSArray *liveStreams;

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
    self.advancedStream.delegate = self;
    self.simpleStream.delegate = self;
    self.port.delegate = self;
    self.server.delegate = self;
    self.bitrate.delegate = self;
    self.resolution.delegate = self;
    
    self.stream.delegate = self;
    self.stream.dataSource = self;
    self.liveStreams = @[];
    
    self.qualityButtons = [NSArray arrayWithObjects:self.lowQualityBtn, self.mediumQualityBtn, self.highQualityBtn, self.otherQualityBtn, nil];
    
    self.simpleStream.text = [self getUserSetting:@"stream" withDefault:self.advancedStream.text];
    self.advancedStream.text = [self getUserSetting:@"stream" withDefault:self.advancedStream.text];
    
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
    
    [self.doneBtn setAlpha:1.0f];
    [self.doneBtn setEnabled:YES];
    
    [self.simpleStream setHidden:NO];
    [self.stream setHidden:YES];
    [self.listRefreshBtn setHidden:YES];
    
    [self.streamSettingsForm setHidden:NO];
    [self.publishSettingsForm setHidden:NO];
    
    [self.advancedSettingsView setHidden:YES];
    
    [self.streamsAvailableLbl setHidden:YES];
    
    switch(self.currentMode) {
        case r5_example_publish:
            [[self doneBtn] setTitle:@"PUBLISH" forState:UIControlStateNormal];
            break;
        case r5_example_stream:
            [self.simpleStream setHidden:YES];
            [self.stream setHidden:NO];
            [self.listRefreshBtn setHidden:NO];
            [self.streamsAvailableLbl setHidden:NO];
            
            [self.advancedSettingsBtn setHidden:YES];
            [self.advancedSettingsLbl setHidden:YES];
            [self.publishSettingsForm setHidden:YES];
            
            [self.view bringSubviewToFront:self.listRefreshBtn];
            
            [[self doneBtn] setTitle:@"SUBSCRIBE" forState:UIControlStateNormal];
            
            [self.doneBtn setAlpha:0.5f];
            [self.doneBtn setEnabled:NO];
            break;
        case r5_example_twoway:
            [[self doneBtn] setTitle:@"NEXT" forState:UIControlStateNormal];
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.currentMode == r5_example_stream) {
        [[StreamListUtility getInstance] callWithBlock:^(NSArray *streams) {
            [self updateTableDataWithArray:streams];
        }];
        
        [[StreamListUtility getInstance] callWithReturn:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[StreamListUtility getInstance] clearAndDisconnect];
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

#pragma mark - Helpers

- (void) setSubscribeBtnEnabled:(BOOL)isEnabled {
    [self.doneBtn setEnabled:isEnabled];
    [self.doneBtn setAlpha:isEnabled ? 1.0f : 0.5f];
}

#pragma mark - Table

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StreamTableViewCell *cell = (StreamTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"streamCell"];
    
    NSInteger idx = indexPath.row;
    cell.streamNameLbl.text = (idx != NSNotFound && idx < self.liveStreams.count) ? [self.liveStreams objectAtIndex:idx] : @"Whoops! Hold on...";
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveStreams.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StreamTableViewCell *cell = (StreamTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *connectToStreamName = [cell.streamNameLbl text];
    
    [self.doneBtn setAlpha:1.0f];
    [self.doneBtn setEnabled:YES];
    
    [self connectTo:connectToStreamName];
    [self setSubscribeBtnEnabled:YES];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setSubscribeBtnEnabled:NO];
}

#pragma mark - Connections

- (void) connectTo:(NSString *)connectionStreamName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:connectionStreamName forKey:@"connectToStream"];
    [defaults synchronize];
}

#pragma mark - Navigation

- (IBAction)onDoneClicked:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int selected = [self getSelectedQualityIndex];
    [self setQualityWithIndex:selected];
    
    if (self.stream.isHidden) {
        [defaults setObject:self.simpleStream.text forKey:@"stream"];
    }
    
    [defaults setBool:self.audioCheck.selected forKey:@"includeAudio"];
    [defaults setBool:self.videoCheck.selected forKey:@"includeVideo"];
    [defaults setBool:self.adaptiveBitrateCheck.selected forKey:@"adaptiveBitrate"];
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

#pragma mark - Textfields

- (BOOL)isHiddenKeyboardField:(UITextField *)field {
    return field == self.advancedStream;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.focusedField = nil;
    
    if (textField == self.simpleStream) {
        // Nothing
    } else {
        if (textField == self.server) {
            [self.port becomeFirstResponder];
        } else if (textField == self.port) {
            [self.app becomeFirstResponder];
        } else if (textField == self.app) {
            [self.advancedStream becomeFirstResponder];
        } else if (textField == self.advancedStream) {
            [self.bitrate becomeFirstResponder];
        } else if (textField == self.bitrate) {
            [self.resolution becomeFirstResponder];
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextFieldUp:YES];
    self.focusedField = textField;
    
    textField.returnKeyType = (textField == self.simpleStream || textField == self.resolution) ? UIReturnKeyDone : UIReturnKeyNext;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextFieldUp:NO];
    
    if (textField == self.simpleStream) {
        self.advancedStream.text = self.simpleStream.text;
    } else if (textField == self.advancedStream) {
        self.simpleStream.text = self.advancedStream.text;
    }
}

- (void) animateTextFieldUp:(BOOL)up {
    const int movementDistance = 90;
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    }];
}

#pragma mark - IBActions

- (void) showAdvancedSettings {
    [self.advancedSettingsView setAlpha:0.0f];
    [self.advancedSettingsView setHidden:NO];
    
    if (self.currentMode == r5_example_stream) {
        [self.bitrate setHidden:YES];
        [self.bitrateLbl setHidden:YES];
        [self.resolution setHidden:YES];
        [self.resolutionLbl setHidden:YES];
        [self.audioCheck setHidden:YES];
        [self.audioCheckLbl setHidden:YES];
        [self.videoCheck setHidden:YES];
        [self.videoCheckLbl setHidden:YES];
        [self.adaptiveBitrateCheck setHidden:YES];
        [self.adaptiveBitrateCheckLbl setHidden:YES];
    }
    
    [UIView animateWithDuration:0.16f animations:^{
        [self.advancedSettingsView setAlpha:1.0f];
    }];
}

- (void) hideAdvancedSettings {
    [UIView animateWithDuration:0.16f animations:^{
        [self.advancedSettingsView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.advancedSettingsView setHidden:YES];
        
        [self.bitrate setHidden:NO];
        [self.bitrateLbl setHidden:NO];
        [self.resolution setHidden:NO];
        [self.resolutionLbl setHidden:NO];
        [self.audioCheck setHidden:NO];
        [self.audioCheckLbl setHidden:NO];
        [self.videoCheck setHidden:NO];
        [self.videoCheckLbl setHidden:NO];
        [self.adaptiveBitrateCheck setHidden:NO];
        [self.adaptiveBitrateCheckLbl setHidden:NO];
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

- (IBAction)onListRefreshTouch:(id)sender {
    [[StreamListUtility getInstance] callWithBlock:^(NSArray *streams) {
        [self updateTableDataWithArray:streams];
    }];
}

#pragma mark - List Listener

- (void) updateTableDataWithArray:(NSArray *)array {
    NSIndexPath *selected = [self.stream indexPathForSelectedRow];
    StreamTableViewCell *cell = selected ? [self.stream cellForRowAtIndexPath:selected] : nil;
    NSString *selectedLabel = cell ? cell.streamNameLbl.text : nil;
    
    self.liveStreams = array;
    
    NSInteger selectedIdx = selectedLabel ? [array indexOfObject:selectedLabel] : NSNotFound;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.liveStreams.count == 1) {
            self.streamsAvailableLbl.text = @"1 STREAM";
        } else {
            self.streamsAvailableLbl.text = [NSString stringWithFormat:@"%lu STREAMS", (unsigned long)self.liveStreams.count];
        }
        
        [self.stream reloadData];
        
        if (selectedIdx != NSNotFound) {
            NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:selectedIdx inSection:0];
            [self.stream selectRowAtIndexPath:newSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    });
}

- (void) listUpdated:(NSArray *)updatedList {
    [self updateTableDataWithArray:updatedList];
}

@end
