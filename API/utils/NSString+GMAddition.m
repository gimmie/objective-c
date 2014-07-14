//
//  NSString+GMAddition.m
//  Gimmie
//
//  Created by llun on 11/26/12.
//  Copyright (c) 2012 gimmie. All rights reserved.
//

#import "NSString+GMAddition.h"

@implementation NSString (GMAddition)

+ (NSString *)UUID
{
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

+ (NSString *) randomStringWithSize:(NSUInteger) size
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:size];
    for (int i = 0; i < size; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

- (NSString *)urlEncoding {
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    NSString *rfcEscaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) self, NULL, (CFStringRef)@";/?:@&=$+{}<>,", cfEncoding));
    return rfcEscaped;
}

@end
