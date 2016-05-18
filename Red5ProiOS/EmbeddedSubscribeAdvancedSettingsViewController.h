//
//  EmbeddedSubscribeAdvancedSettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmbeddedSettingsViewController.h"

@interface EmbeddedSubscribeAdvancedSettingsViewController : EmbeddedSettingsViewController

@property (weak, nonatomic) IBOutlet UITextField *appTextfield;
@property (weak, nonatomic) IBOutlet UITextField *streamTextfield;
@property (weak, nonatomic) IBOutlet UITextField *serverTextfield;
@property (weak, nonatomic) IBOutlet UITextField *portTextfield;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
