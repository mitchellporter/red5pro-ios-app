//
//  VideoViewController.h
//  Red5ProiOS
//
//  Created by Andy Zupko on 9/18/14.
//  Copyright (c) 2014 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <R5Streaming/R5Streaming.h>
#import "StreamViewController.h"

@interface VideoViewController : R5VideoViewController
@property (nonatomic, strong) StreamViewController *streamViewController;

-(void)start;
- (void)startWithStreamName:(NSString *)streamName;
-(void)stop;
@end
