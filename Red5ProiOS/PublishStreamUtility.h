//
//  TwoWayUtility.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/5/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <R5Streaming/R5Streaming.h>

@interface PublishStreamUtility : NSObject

@property BOOL isFrontSelected;

+ (PublishStreamUtility *) getInstance;
- (R5Stream *) createNewStream;
- (R5Stream *) getOrCreateNewStream;
- (void) killStream;

@end
