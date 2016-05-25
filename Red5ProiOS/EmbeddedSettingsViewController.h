//
//  EmbeddedSettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "StreamViewController.h"

@interface EmbeddedSettingsViewController : UIViewController<UITextFieldDelegate, EmbeddedSettingsViewController>

@property enum StreamMode currentMode;

- (NSString*) getUserSetting:(NSString *)key withDefault:(NSString *)defaultValue;

@end
