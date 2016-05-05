//
//  SettingsViewController.h
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>

enum StreamMode {
    r5_example_stream,
    r5_example_publish,
    r5_example_twoway
};

@interface SettingsViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *simpleSettingsView;
@property (weak, nonatomic) IBOutlet UIView *advancedSettingsView;

@property (weak, nonatomic) IBOutlet UIView *publishSettingsView;

@property (weak, nonatomic) IBOutlet UIView *streamSettingsForm;
@property (weak, nonatomic) IBOutlet UIView *publishSettingsForm;

@property (weak, nonatomic) IBOutlet UITableView *stream;
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

@property (weak, nonatomic) IBOutlet UIButton *lowQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediumQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *highQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherQualityBtn;

@property (weak, nonatomic) IBOutlet UIButton *advancedSettingsBtn;
@property (weak, nonatomic) IBOutlet UILabel *advancedSettingsLbl;

@property (weak, nonatomic) IBOutlet UIButton *advancedSettingsSubscribeBtn;
@property (weak, nonatomic) IBOutlet UILabel *advancedSettingsSubscribeLbl;

@property (weak, nonatomic) IBOutlet UILabel *bitrateLbl;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLbl;
@property (weak, nonatomic) IBOutlet UILabel *audioCheckLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoCheckLbl;
@property (weak, nonatomic) IBOutlet UILabel *adaptiveBitrateCheckLbl;

@property enum StreamMode currentMode;

@end
