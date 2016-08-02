//
//  AppDelegate.m
//  Red5ProiOS
//
//  Created by David Heimann on 8/22/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "AppDelegate.h"
#import <R5Streaming/R5Streaming.h>
#import "SideNavigationViewController.h"
#import "SlideNavigationController.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [SlideNavigationController sharedInstance].leftMenu = [storyboard instantiateViewControllerWithIdentifier:@"sideNav"];
    
    [SlideNavigationController sharedInstance].avoidSwitchingToSameClassViewController = YES;
    [SlideNavigationController sharedInstance].enableShadow = YES;
    [SlideNavigationController sharedInstance].enableSwipeGesture = YES;
    [SlideNavigationController sharedInstance].menuRevealAnimator = [[SlideNavigationContorllerAnimatorScaleAndFade alloc] initWithMaximumFadeAlpha:1.0f fadeColor:[UIColor darkGrayColor] andMinimumScale:0.85f];
    [SlideNavigationController sharedInstance].panGestureSideOffset = 44;
    
    CGRect rect = [UIScreen mainScreen].bounds;
    
    float offset = 1.0f - 0.4f;
    [SlideNavigationController sharedInstance].portraitSlideOffset = rect.size.width * offset;
    [SlideNavigationController sharedInstance].landscapeSlideOffset = rect.size.height * offset;
    
    [[SlideNavigationController sharedInstance] setNavigationBarHidden:NO animated:YES];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackTap:)];
    [leftItem setTintColor:[UIColor colorWithRed:0.8901960784f green:0.09803921569f blue:0.0f alpha:1.0f]];
    
    [SlideNavigationController sharedInstance].leftBarButtonItem = leftItem;
    
    if ([[SlideNavigationController sharedInstance] respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [SlideNavigationController sharedInstance].interactivePopGestureRecognizer.enabled = NO;
    }
    
    UINavigationBar *navbar = [SlideNavigationController sharedInstance].navigationBar;
    if ([navbar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
        [navbar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    [navbar setShadowImage:[UIImage new]];
    
    r5_set_log_level(r5_log_level_debug);
    
    [self initiateDefaults];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)onBackTap:(id)sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

#pragma mark - Defaults initiation

- (void) initiateDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fp = [[NSBundle mainBundle] pathForResource:@"userDefaults" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:fp];
    
    NSLog(@"Initiation defaults: %@", dict);
    
    [defaults registerDefaults:dict];
}

@end
