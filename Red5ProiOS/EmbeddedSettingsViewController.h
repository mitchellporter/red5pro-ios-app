//
//  EmbeddedSettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface EmbeddedSettingsViewController : UIViewController<UITextFieldDelegate, EmbeddedSettingsViewController>

- (NSString*) getUserSetting:(NSString *)key withDefault:(NSString *)defaultValue;

@end
