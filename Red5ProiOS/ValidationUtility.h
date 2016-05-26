//
//  ValidationUtility.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/24/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ServerValidationCode : NSInteger {
    ServerValidationCode_VALID,
    ServerValidationCode_BAD_SEGMENTS,
    ServerValidationCode_BAD_FORMAT,
    ServerValidationCode_BAD_LENGTH,
    ServerValidationCode_BAD_SEGMENTS_AND_FORMAT,
    ServerValidationCode_BAD_SEGMENTS_AND_LENGTH,
    ServerValidationCode_BAD_FORMAT_AND_LENGTH,
    ServerValidationCode_ALL_BAD
};

enum PortValidationCode : NSInteger {
    PortValidationCode_VALID,
    PortValidationCode_BAD_LENGTH,
    PortValidationCode_BAD_FORMAT,
    PortValidationCode_ALL_BAD
};

enum StreamValidationCode : NSInteger {
    StreamValidationCode_VALID,
    StreamValidationCode_BAD_LENGTH,
    StreamValidationCode_BAD_FORMAT,
    StreamValidationCode_ALL_BAD
};

enum AppValidationCode : NSInteger {
    AppValidationCode_VALID,
    AppValidationCode_BAD_LENGTH,
    AppValidationCode_BAD_FORMAT,
    AppValidationCode_ALL_BAD
};

enum LengthValidationCode : NSInteger {
    LengthValidationCode_VALID,
    LengthValidationCode_BAD_LENGTH
};

@interface ValidationUtility : NSObject

+ (NSString *) trimString:(NSString *)str;

+ (void) flashRed:(UITextField *)tf;

+ (enum ServerValidationCode) isValidServer:(NSString *)server;
+ (enum PortValidationCode) isValidPort:(NSString *)port;
+ (enum StreamValidationCode) isValidStream:(NSString *)stream;
+ (enum AppValidationCode) isValidApp:(NSString *)app;
+ (enum LengthValidationCode) isValidLength:(NSString *)str;

+ (BOOL) serverValidationCodeHasGoodLength:(enum ServerValidationCode)code;
+ (BOOL) serverValidationCodeHasGoodFormat:(enum ServerValidationCode)code;
+ (BOOL) serverValidationCodeHasGoodSegments:(enum ServerValidationCode)code;

+ (BOOL) portValidationCodeHasGoodLength:(enum PortValidationCode)code;
+ (BOOL) portValidationCodeHasGoodFormat:(enum PortValidationCode)code;

+ (BOOL) streamValidationCodeHasGoodLength:(enum StreamValidationCode)code;
+ (BOOL) streamValidationCodeHasGoodFormat:(enum StreamValidationCode)code;

+ (BOOL) appValidationCodeHasGoodLength:(enum AppValidationCode)code;
+ (BOOL) appValidationCodeHasGoodFormat:(enum AppValidationCode)code;

@end
