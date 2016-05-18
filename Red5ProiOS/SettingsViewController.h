//
//  SettingsViewController.h
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamListUtility.h"
#import "SlideNavigationController.h"

enum StreamMode {
    r5_example_stream,
    r5_example_publish,
    r5_example_twoway
};

@interface SettingsViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, listListener, SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *simpleSettingsView;
@property (weak, nonatomic) IBOutlet UIView *advancedSettingsView;

@property (weak, nonatomic) IBOutlet UIView *streamSettingsForm;
@property (weak, nonatomic) IBOutlet UIView *publishSettingsForm;

@property (weak, nonatomic) IBOutlet UITableView *stream;

@property (weak, nonatomic) IBOutlet UITextField *simpleStream;
@property (weak, nonatomic) IBOutlet UITextField *app;
@property (weak, nonatomic) IBOutlet UITextField *advancedStream;
@property (weak, nonatomic) IBOutlet UITextField *server;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *bitrate;
@property (weak, nonatomic) IBOutlet UITextField *resolution;

@property (weak, nonatomic) IBOutlet UIButton *audioCheck;
@property (weak, nonatomic) IBOutlet UIButton *videoCheck;
@property (weak, nonatomic) IBOutlet UIButton *adaptiveBitrateCheck;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIButton *lowQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediumQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *highQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherQualityBtn;

@property (weak, nonatomic) IBOutlet UIButton *listRefreshBtn;

@property (weak, nonatomic) IBOutlet UIButton *advancedSettingsBtn;
@property (weak, nonatomic) IBOutlet UILabel *advancedSettingsLbl;

@property (weak, nonatomic) IBOutlet UILabel *bitrateLbl;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLbl;
@property (weak, nonatomic) IBOutlet UILabel *audioCheckLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoCheckLbl;
@property (weak, nonatomic) IBOutlet UILabel *adaptiveBitrateCheckLbl;

@property (weak, nonatomic) IBOutlet UILabel *streamsAvailableLbl;

@property enum StreamMode currentMode;

- (void) resetScrollView;
- (void) goToAdvancedForCurrentMode;
- (void) goToSimpleForCurrentMode;
- (void) doneSettings;

@end

@protocol EmbeddedSettingsViewController <NSObject>

@property (weak, nonatomic) SettingsViewController *settingsViewController;
@property (weak, nonatomic) UITextField *activeField;

- (void) keyboardWasShown:(NSNotification *)notification;
- (void) keyboardWillBeHidden:(NSNotification *)notification;

@end
