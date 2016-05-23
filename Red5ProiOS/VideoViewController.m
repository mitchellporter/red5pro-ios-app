//
//  VideoViewController.m
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import "VideoViewController.h"
#import <R5Streaming/R5Streaming.h>

@interface VideoViewController() {
    R5Stream *stream;
   
}
@end


@implementation VideoViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}

-(R5Stream *)setUpNewStream {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *domain = (NSString*)[defaults objectForKey:@"domain"];
    NSString *app = (NSString*)[defaults objectForKey:@"app"];
    NSInteger port = [defaults integerForKey:@"port"];
    
    R5Configuration * config = [R5Configuration new];
    
    config.host = domain;
    config.contextName = app;
    config.port = (int) port;
    
    R5Connection *connection = [[R5Connection new] initWithConfig:config];
    R5Stream *r5Stream = [[R5Stream new] initWithConnection:connection];
    return r5Stream;
}

-(void)start {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *streamName = (NSString*)[defaults objectForKey:@"connectToStream"];
    stream = [self setUpNewStream];
    [self attachStream:stream];
    [stream play:streamName];
}

- (void)startWithStreamName:(NSString *)streamName {
    stream = [self setUpNewStream];
    [self attachStream:stream];
    [stream play:streamName];
}

-(void)stop {
    @try {
        [stream stop];
    }
    @catch(NSException *exception) {
        NSLog(@"Could not stop subscription: %@", exception);
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stop];
}

@end
