//
//  SettingsViewController.h
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

enum StreamMode {
    r5_example_stream,
    r5_example_publish,
    r5_example_twoway
};

@interface SettingsViewController : UIViewController<SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

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
