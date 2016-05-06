//
//  TwoWayUtility.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/5/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "PublishStreamUtility.h"

@interface PublishStreamUtility ()

@property R5Stream *stream;

@end

@implementation PublishStreamUtility

static PublishStreamUtility *instance;

+ (PublishStreamUtility *) getInstance {
    if (instance == nil) {
        instance = [[PublishStreamUtility alloc] init];
        instance.isFrontSelected = YES;
    }
    
    return instance;
}

- (AVCaptureDevice *) getSelectedDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return self.isFrontSelected ? [devices lastObject] : [devices firstObject];
}

- (R5Stream *) createNewStream {
    if (self.stream != nil) {
        [self killStream];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *domain = (NSString*)[defaults objectForKey:@"domain"];
    NSString *app = (NSString*)[defaults objectForKey:@"app"];
    NSString *port = (NSString *)[defaults objectForKey:@"port"];
    BOOL includeAudio = [defaults boolForKey:@"includeAudio"];
    BOOL includeVideo = [defaults boolForKey:@"includeVideo"];
    BOOL adaptiveBitrate = [defaults boolForKey:@"adaptiveBitrate"];
    
    R5Configuration * config = [R5Configuration new];
    
    config.host = domain;
    config.contextName = app;
    config.port = [port intValue];
    
    R5Connection *connection = [[R5Connection new] initWithConfig:config];
    R5Camera *camera = [[R5Camera alloc] initWithDevice:[self getSelectedDevice] andBitRate:128];
    camera.orientation = 90;
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio];
    R5Microphone *microphone = [[R5Microphone new] initWithDevice:audioDevice];
    
    self.stream = [[R5Stream new] initWithConnection:connection];
    
    if(includeVideo)
        [self.stream attachVideo:camera];
    if(includeAudio)
        [self.stream attachAudio:microphone];
    
    if (adaptiveBitrate) {
        config.buffer_time = 0.25f;
        R5AdaptiveBitrateController *adaptiveController = [R5AdaptiveBitrateController new];
        [adaptiveController attachToStream:self.stream];
        if (includeVideo) {
            [adaptiveController setRequiresVideo:YES];
        }
    }
    
    return self.stream;
}

- (R5Stream *) getOrCreateNewStream {
    if (self.stream != nil) {
        return self.stream;
    }
    
    return [self createNewStream];
}

- (void) killStream {
    @try {
        [self.stream stop];
        [self.stream setDelegate:nil];
        self.stream = nil;
    }
    @catch(NSException *exception) {
        NSLog(@"Could not stop: %@", exception);
    }
}

@end
