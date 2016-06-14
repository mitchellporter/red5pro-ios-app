//
//  EmbeddedPublishAdvancedSettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmbeddedSettingsViewController.h"

@interface EmbeddedPublishAdvancedSettingsViewController : EmbeddedSettingsViewController

@property (weak, nonatomic) IBOutlet UITextField *appTextfield;
@property (weak, nonatomic) IBOutlet UITextField *streamTextfield;
@property (weak, nonatomic) IBOutlet UITextField *serverTextfield;
@property (weak, nonatomic) IBOutlet UITextField *portTextfield;
@property (weak, nonatomic) IBOutlet UITextField *bitrateTextfield;
@property (weak, nonatomic) IBOutlet UITextField *resolutionTextfield;

@property (weak, nonatomic) IBOutlet UIButton *audioCheck;
@property (weak, nonatomic) IBOutlet UIButton *videoCheck;
@property (weak, nonatomic) IBOutlet UIButton *adaptiveBitrateCheck;
@property (weak, nonatomic) IBOutlet UIButton *debugCheck;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
