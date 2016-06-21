
//
//  PublishViewController.m
//  Red5ProiOS
//
//  Created by Andy Zupko on 10/7/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "PublishViewController.h"
#import "ALToastView.h"
#import "PublishStreamUtility.h"
#import "StreamViewController.h"

@interface PublishViewController() {
    R5Stream *stream;
    BOOL isTogglable;
    BOOL isFrontSelected;
}
@end

@implementation PublishViewController

-(void)viewDidLoad {
//    r5_set_log_level(r5_log_level_debug);
    [super viewDidLoad];
    isFrontSelected = YES;
    [[PublishStreamUtility getInstance] setIsFrontSelected:isFrontSelected];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(stream == nil)
        [self establishPreview];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self killStream];
    [self showPreview:false];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}

-(void)onR5StreamStatus:(R5Stream *)stream withStatus:(int)statusCode withMessage:(NSString *)msg {
    if (msg && ![msg isEqualToString:@"null"]) {
        [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"Stream: %s - %@", r5_string_for_status(statusCode), msg]];
    } else {
        [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"Stream: %s", r5_string_for_status(statusCode)]];
    }
    
    switch (statusCode) {
        case r5_status_connected:
        case r5_status_netstatus:
        case r5_status_start_streaming:
            break;
        case r5_status_connection_close:
        case r5_status_connection_timeout:
        case r5_status_connection_error:
        case r5_status_disconnected: {
            if (statusCode == r5_status_disconnected) {
                [ALToastView toastInView:self.view withText:@"Your stream was disconnected"];
            }
            
            [self stop:YES];
            
            if (self.streamViewController) {
                [self.streamViewController onCameraTouch:nil];
            } else {
                NSLog(@"No StreamViewController reference!");
            }
            
            break;
        }
        case r5_status_stop_streaming:
            [self stop:NO];
            break;
        default:
            break;
    }
}

-(void)establishPreview {
    if(stream == nil) {
         stream = [[PublishStreamUtility getInstance] getOrCreateNewStream];
    }

    [stream setDelegate:self];
    
    [self attachStream:stream];
    [self showPreview:true];
    [self showDebugInfo:[[NSUserDefaults standardUserDefaults] boolForKey:@"debugOn"]];
    isTogglable = YES;
}

-(AVCaptureDevice *)getSelectedDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return isFrontSelected ? [devices lastObject] : [devices firstObject];
}

-(void)killStream {
    [[PublishStreamUtility getInstance] killStream];
    stream = nil;
}

-(void)start {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *streamName = (NSString*)[defaults objectForKey:@"stream"];

    
//    isTogglable = NO;
    [stream publish:streamName type:R5RecordTypeLive];
}

-(void)close{
    
}

-(void)stop:(BOOL)reset {
    [self killStream];
    
    if(reset == YES)
        [self establishPreview];
}

-(void)updatePreview {
    [self establishPreview];
}

-(void)toggleCamera {
    if(isTogglable) {
        isFrontSelected = !isFrontSelected;
        [[PublishStreamUtility getInstance] setIsFrontSelected:isFrontSelected];
        if(stream != nil){
            R5Camera *cam2 = (R5Camera *)[stream getVideoSource];
            [cam2 setDevice:[self getSelectedDevice]];
        }
        //[self updatePreview];
    }
}

@end
