//
//  ServerSettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 4/20/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerSettingsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *submitBtn;
@property (nonatomic, weak) IBOutlet UITextField *serverTextField;
@property (nonatomic, weak) IBOutlet UITextField *portTextField;

@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

@property (nonatomic, weak) IBOutlet UIButton *helpBtn;

@end
