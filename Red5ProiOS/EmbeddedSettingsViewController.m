//
//  EmbeddedSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedSettingsViewController.h"

@interface EmbeddedSettingsViewController ()

@end

@implementation EmbeddedSettingsViewController

@synthesize activeField;
@synthesize settingsViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOutsideTextfields)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

#pragma mark - Helpers

- (NSString*) getUserSetting:(NSString *)key withDefault:(NSString *)defaultValue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:key]) {
        return [defaults stringForKey:key];
    }
    return defaultValue;
}

#pragma mark - EmbeddedSettingsViewController

- (void) keyboardWasShown:(NSNotification *)notification {
    if (self.settingsViewController != nil) {
        NSDictionary* info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.settingsViewController.scrollView.contentInset = contentInsets;
        self.settingsViewController.scrollView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
            [self.settingsViewController.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
        }
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification {
}

#pragma mark - Tap Gesture Recognizer

- (void) onTapOutsideTextfields {
    [self.view endEditing:YES];
    self.activeField = nil;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

@end
