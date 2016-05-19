//
//  EmbeddedPublishSettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmbeddedSettingsViewController.h"

@interface EmbeddedPublishSettingsViewController : EmbeddedSettingsViewController

@property (weak, nonatomic) IBOutlet UITextField *streamTextfield;
@property (weak, nonatomic) IBOutlet UIButton *lQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *mQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *hQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *oQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *advancedBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@end
