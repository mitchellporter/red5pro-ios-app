//
//  ServerSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 4/20/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "ServerSettingsViewController.h"

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
        NSString *port = [self.portTextField text];
        NSString *server = [self.serverTextField text];
        
        BOOL shouldPerformSegue = [self isValid];
        
        if (shouldPerformSegue) {
            [self setUserSetting:@"domain" withValue:server];
            [self setUserSetting:@"port" withValue:port];
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
    NSString *server = [self.serverTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *port = [self.portTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //  e.g. 0-255.0-255.0-255.0-255, but must be done in two parts
    NSString *ipRegexStr = @"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
    NSError *err;
    
    BOOL haveGoodLengths = server.length > 0 && port.length > 0;
    BOOL portIsInt = [port integerValue] > 0;
    NSRegularExpression *ipRegex = [NSRegularExpression regularExpressionWithPattern:ipRegexStr options:0 error:&err];
    NSArray *ipMatches = [ipRegex matchesInString:server options:0 range:NSMakeRange(0, server.length)];
    BOOL ipIsGood = ipMatches != nil && ipMatches.count == 1;
    
    NSRegularExpression *segmentRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d{1,3}\\.?" options:0 error:&err];
    __block BOOL allIPSegmentsAreInGoodRange = YES;
    [segmentRegex enumerateMatchesInString:server options:0 range:NSMakeRange(0, server.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSString *match = [server substringWithRange:result.range];
        NSInteger value = -1;
        
        if ([match containsString:@"."]) {
            value = [[match substringWithRange:NSMakeRange(0, match.length-1)] integerValue];
        } else {
            value = [match integerValue];
        }
        
        if (result.range.location == 0) {
            if (value <= 0 || value > 255) {
                *stop = YES;
                allIPSegmentsAreInGoodRange = NO;
            }
        } else {
            if (value < 0 || value > 255) {
                *stop = YES;
                allIPSegmentsAreInGoodRange = NO;
            }
        }
    }];
    
    NSString *errorMessage = nil;
    
    if (!haveGoodLengths) {
        errorMessage = @"You must enter both fields";
    } else if (!portIsInt) {
        errorMessage = @"The port must be valid";
    } else if (!ipIsGood) {
        errorMessage = @"Server IP must have a valid format";
    } else if (!allIPSegmentsAreInGoodRange) {
        errorMessage = @"Server IP must have valid ranges";
    }
    
    if (errorMessage) {
        [self.errorLabel setText:errorMessage];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.errorLabel.alpha = 1.0f;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25f animations:^{
                    self.errorLabel.alpha = 0.0f;
                }];
            });
        }];
    }
    
    return haveGoodLengths && portIsInt && ipIsGood && allIPSegmentsAreInGoodRange;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == [self serverTextField]) {
        [[self portTextField] becomeFirstResponder];
    } else if (textField == [self portTextField]) {
        [self performSegueWithIdentifier:@"goToMain" sender:nil];
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
