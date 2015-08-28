/*
 *  R5Device.h
 *  SecondScreenSdk
 *
 *  Created by Trevor Burton [trevor@infrared5.com] on 21/01/2010.
 *  Copyright 2010 Infrared5. All rights reserved.
 *
 */

#import "R5Enums.h"
#import "R5Externalisable.h"

@class R5Address;

@interface R5Device  : NSObject <R5Externalisable>

@property (nonatomic) R5Address* address;
@property (nonatomic, readonly) NSString* deviceId;
@property (nonatomic) NSString* name;
@property (nonatomic) R5DeviceType type;

- (id)initWithId:(NSString *)deviceId type:(R5DeviceType)type name:(NSString*)name;

+ (instancetype)deviceWithId:(NSString *)deviceId type:(R5DeviceType)type name:(NSString*)name;

@end
