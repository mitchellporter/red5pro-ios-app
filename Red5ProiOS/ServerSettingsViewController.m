//
//  ServerSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 4/20/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "ServerSettingsViewController.h"
#import "ValidationUtility.h"

@interface ServerSettingsViewController ()

@end

@implementation ServerSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *server = [self getUserSetting:@"domain" withDefault:@"127.0.0.1"];
    
    self.serverTextField.text = server;
    self.portTextField.text = [NSString stringWithFormat:@"%ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"port"]];
    
    [[self serverTextField] setDelegate:self];
    [[self portTextField] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[SlideNavigationController sharedInstance] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    if ([[SlideNavigationController sharedInstance] respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [SlideNavigationController sharedInstance].interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}

- (IBAction)onTapOutside:(id)sender {
    [self.serverTextField resignFirstResponder];
    [self.portTextField resignFirstResponder];
}

#pragma mark - Helpers

- (NSString *)getUserSetting:(NSString *)key withDefault:(NSString *)defaultValue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:key]) {
        return [defaults stringForKey:key];
    }
    return defaultValue;
}

- (void)setUserSetting:(NSString *)key withValue:(NSString *)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:value forKey:key];
}

- (void) keyboardDidShow:(NSNotification *)notification {
    /*NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect currentFrame = self.view.frame;
    
    currentFrame.origin.y -= kbSize.height;
    
    self.view.layer.frame = currentFrame;
    self.view.frame = currentFrame;*/
}

- (void) keyboardDidHide:(NSNotification *)notification {
    /*CGRect currentFrame = self.view.frame;
    
    currentFrame.origin.y = 0;
    
    self.view.layer.frame = currentFrame;
    self.view.frame = currentFrame;*/
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"goToMain"]) {
        NSString *port = [ValidationUtility trimString:self.portTextField.text];
        NSString *server = [ValidationUtility trimString:self.serverTextField.text];
        
        BOOL shouldPerformSegue = [self isValid];
        
        if (shouldPerformSegue) {
            [self setUserSetting:@"domain" withValue:server];
            [self setUserSetting:@"port" withValue:port];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        return shouldPerformSegue;
    }
    return YES;
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

#pragma mark - Validation

- (BOOL) isValid {
    NSInteger serverValidation = [ValidationUtility isValidServer:self.serverTextField.text];
    NSInteger portValidation = [ValidationUtility isValidPort:self.portTextField.text];
    
    BOOL goodServerLength = [ValidationUtility serverValidationCodeHasGoodLength:serverValidation];
    BOOL goodPortLength = [ValidationUtility portValidationCodeHasGoodLength:portValidation];
    BOOL haveGoodLengths =  goodServerLength && goodPortLength;
    BOOL portIsInt = [ValidationUtility portValidationCodeHasGoodFormat:portValidation];
    BOOL ipIsGood = [ValidationUtility serverValidationCodeHasGoodFormat:serverValidation];
    BOOL allIPSegmentsAreInGoodRange = [ValidationUtility serverValidationCodeHasGoodSegments:serverValidation];
    
    NSString *errorMessage = nil;
    
    if (!haveGoodLengths) {
        if (!goodServerLength) [ValidationUtility flashRed:self.serverTextField];
        if (!goodPortLength) [ValidationUtility flashRed:self.portTextField];
        errorMessage = @"You must enter both fields";
    } else if (!portIsInt) {
        [ValidationUtility flashRed:self.portTextField];
        errorMessage = @"The port must be valid";
    } else if (!ipIsGood) {
        [ValidationUtility flashRed:self.serverTextField];
        errorMessage = @"Server IP must have a valid format";
    } else if (!allIPSegmentsAreInGoodRange) {
        [ValidationUtility flashRed:self.serverTextField];
        errorMessage = @"Server IP must have valid ranges";
    }
    
    if (errorMessage != nil) {
        [self.errorLabel setText:errorMessage];
        
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.errorLabel.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.2f
                                                   delay:1.3f
                                                 options:0
                                              animations:^{
                                                  self.errorLabel.alpha = 0.0f;
                                              }
                                              completion:^(BOOL finished) {}
                              ];
                         }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == [self serverTextField]) {
        [[self portTextField] becomeFirstResponder];
    } else if (textField == [self portTextField]) {
        if ([self isValid]) {
            [self performSegueWithIdentifier:@"goToMain" sender:nil];
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextFieldUp:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextFieldUp:NO];
}

- (void) animateTextFieldUp:(BOOL)up {
    const int movementDistance = 90;
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    }];
}

@end