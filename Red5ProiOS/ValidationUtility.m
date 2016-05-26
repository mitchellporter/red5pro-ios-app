//
//  ValidationUtility.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/24/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "ValidationUtility.h"

@implementation ValidationUtility

#pragma mark - Utility methods

+ (NSString *) trimString:(NSString *)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (void) flashRed:(UITextField *)tf {
    [tf setBackgroundColor:[UIColor whiteColor]];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [tf setBackgroundColor:[UIColor colorWithRed:(227.0f/255.0f) green:(25.0f/255.0f) blue:0.0f alpha:1.0f]];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                               delay:0.3f
                                             options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                                          animations:^{
                                              [tf setBackgroundColor:[UIColor whiteColor]];
                                          }
                                          completion:^(BOOL finished) {}
                          ];
                     }];
}

#pragma mark - Server Validation

+ (enum ServerValidationCode) isValidServer:(NSString *)server {
    NSString *trimmed = [self trimString:server];
    
    //  e.g. 0-255.0-255.0-255.0-255, but must be done in two parts
    NSString *ipRegexStr = @"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
    NSError *err;
    
    BOOL hasGoodLength = trimmed.length > 0;
    NSRegularExpression *ipRegex = [NSRegularExpression regularExpressionWithPattern:ipRegexStr options:0 error:&err];
    NSArray *ipMatches = [ipRegex matchesInString:trimmed options:0 range:NSMakeRange(0, trimmed.length)];
    BOOL ipIsGood = ipMatches != nil && ipMatches.count == 1;
    
    NSRegularExpression *segmentRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d{1,3}\\.?" options:0 error:&err];
    __block BOOL allIPSegmentsAreInGoodRange = YES;
    [segmentRegex enumerateMatchesInString:trimmed options:0 range:NSMakeRange(0, trimmed.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSString *match = [trimmed substringWithRange:result.range];
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
    
    //  Combos:
    //  - bad length, bad format, bad segments
    //  - bad length, bad format
    //  - bad length, bad segments
    //  - bad format, bad segments
    //  - bad length
    //  - bad format
    //  - bad segments
    
    if (!hasGoodLength && !ipIsGood && !allIPSegmentsAreInGoodRange) {
        return ServerValidationCode_ALL_BAD;
    } else if (!hasGoodLength && !ipIsGood) {
        return ServerValidationCode_BAD_FORMAT_AND_LENGTH;
    } else if (!hasGoodLength && !allIPSegmentsAreInGoodRange) {
        return ServerValidationCode_BAD_SEGMENTS_AND_LENGTH;
    } else if (!ipIsGood && !allIPSegmentsAreInGoodRange) {
        return ServerValidationCode_BAD_SEGMENTS_AND_FORMAT;
    } else if (!hasGoodLength) {
        return ServerValidationCode_BAD_LENGTH;
    } else if (!ipIsGood) {
        return ServerValidationCode_BAD_FORMAT;
    } else if (!allIPSegmentsAreInGoodRange) {
        return ServerValidationCode_BAD_SEGMENTS;
    }
    
    return ServerValidationCode_VALID;
}

+ (BOOL) serverValidationCodeHasGoodLength:(enum ServerValidationCode)code {
    return  code != ServerValidationCode_ALL_BAD &&
            code != ServerValidationCode_BAD_FORMAT_AND_LENGTH &&
            code != ServerValidationCode_BAD_LENGTH &&
            code != ServerValidationCode_BAD_SEGMENTS_AND_LENGTH;
}

+ (BOOL) serverValidationCodeHasGoodFormat:(enum ServerValidationCode)code {
    return  code != ServerValidationCode_ALL_BAD &&
            code != ServerValidationCode_BAD_FORMAT &&
            code != ServerValidationCode_BAD_FORMAT_AND_LENGTH &&
            code != ServerValidationCode_BAD_SEGMENTS_AND_FORMAT;
}

+ (BOOL) serverValidationCodeHasGoodSegments:(enum ServerValidationCode)code {
    return  code != ServerValidationCode_ALL_BAD &&
            code != ServerValidationCode_BAD_SEGMENTS &&
            code != ServerValidationCode_BAD_SEGMENTS_AND_FORMAT &&
            code != ServerValidationCode_BAD_SEGMENTS_AND_LENGTH;
}

#pragma mark - Port Validation

+ (enum PortValidationCode) isValidPort:(NSString *)port {
    NSString *trimmed = [self trimString:port];
    NSInteger intVal = [trimmed integerValue];
    
    BOOL hasValidLength = trimmed.length > 0;
    BOOL isValidPort = intVal > 0;
    
    if (!hasValidLength && !isValidPort) {
        return PortValidationCode_ALL_BAD;
    } else if (!hasValidLength) {
        return PortValidationCode_BAD_LENGTH;
    } else if (!isValidPort) {
        return PortValidationCode_BAD_FORMAT;
    }
    
    return PortValidationCode_VALID;
}

+ (BOOL) portValidationCodeHasGoodLength:(enum PortValidationCode)code {
    return  code != PortValidationCode_ALL_BAD &&
            code != PortValidationCode_BAD_LENGTH;
}

+ (BOOL) portValidationCodeHasGoodFormat:(enum PortValidationCode)code {
    return  code != PortValidationCode_ALL_BAD &&
            code != PortValidationCode_BAD_FORMAT;
}

#pragma mark - Stream Validation

+ (enum StreamValidationCode) isValidStream:(NSString *)stream {
    NSString *trimmed = [self trimString:stream];
    
    BOOL hasValidLength = trimmed.length > 0;
    BOOL hasNoSpaces = ![trimmed containsString:@" "];
    
    if (!hasValidLength && !hasNoSpaces) {
        return StreamValidationCode_ALL_BAD;
    } else if (!hasValidLength) {
        return StreamValidationCode_BAD_LENGTH;
    } else if (!hasNoSpaces) {
        return StreamValidationCode_BAD_FORMAT;
    }
    
    return StreamValidationCode_VALID;
}

+ (BOOL) streamValidationCodeHasGoodLength:(enum StreamValidationCode)code {
    return  code != StreamValidationCode_ALL_BAD &&
            code != StreamValidationCode_BAD_LENGTH;
}

+ (BOOL) streamValidationCodeHasGoodFormat:(enum StreamValidationCode)code {
    return  code != StreamValidationCode_ALL_BAD &&
            code != StreamValidationCode_BAD_FORMAT;
}

#pragma mark - App Validation

+ (enum AppValidationCode) isValidApp:(NSString *)app {
    NSString *trimmed = [self trimString:app];
    
    BOOL hasValidLength = trimmed.length > 0;
    BOOL hasNoSpaces = ![trimmed containsString:@" "];
    
    if (!hasValidLength && !hasNoSpaces) {
        return AppValidationCode_ALL_BAD;
    } else if (!hasValidLength) {
        return AppValidationCode_BAD_LENGTH;
    } else if (!hasNoSpaces) {
        return AppValidationCode_BAD_FORMAT;
    }
    
    return AppValidationCode_VALID;
}

+ (BOOL) appValidationCodeHasGoodLength:(enum AppValidationCode)code {
    return  code != AppValidationCode_ALL_BAD &&
    code != AppValidationCode_BAD_LENGTH;
}

+ (BOOL) appValidationCodeHasGoodFormat:(enum AppValidationCode)code {
    return  code != AppValidationCode_ALL_BAD &&
    code != AppValidationCode_BAD_FORMAT;
}

#pragma mark - Generic Validation

+ (enum LengthValidationCode) isValidLength:(NSString *)str {
    NSString *trimmed = [self trimString:str];
    
    if (trimmed.length > 0) {
        return LengthValidationCode_VALID;
    }
    
    return LengthValidationCode_BAD_LENGTH;
}

@end
