//
//  GMGATracker.m
//  Gimmie
//
//  Created by llun on 28/5/14.
//  Copyright (c) 2014 gimmie. All rights reserved.
//

#import "GMGATracker.h"
#import "NSString+GMAddition.h"

#import "GMService.h"

#import "GMLog.h"

@interface GMGATracker(internal)

+ (NSString *) dimensionKeyFromName:(NSString *) name;

@end

@implementation GMGATracker
{
    NSString *_user;
}

- (id) initWithTrackingID:(NSString *)trackingID
{
    self = [super init];
    if (self) {
        _trackingID = trackingID;
    }
    return self;
}

- (void) trackEvent: (NSString *) eventName
{
    [self trackEvent:eventName properties:@{}];
}

- (void) trackEvent: (NSString *) eventName properties: (NSDictionary *) properties
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ssl.google-analytics.com/collect"]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableDictionary *gaProperties = [NSMutableDictionary dictionaryWithCapacity:10];
    [gaProperties setObject:@"1" forKey:@"v"];
    [gaProperties setObject:_trackingID forKey:@"tid"];
    [gaProperties setObject:[NSString randomStringWithSize:10] forKey:@"cid"];
    [gaProperties setObject:@"event" forKey:@"t"];
    
    [gaProperties setObject:@"iOS" forKey:@"ec"];
    [gaProperties setObject:eventName forKey:@"ea"];
    [gaProperties setObject:[GMService sharedService].key forKey:@"el"];
    
    for (NSString *key in properties.allKeys) {
        [gaProperties setObject:[properties objectForKey:key] forKey:[GMGATracker dimensionKeyFromName:key]];
    }
    
    if (_user) {
        [gaProperties setObject:_user forKey:@"uid"];
    }
    
    NSMutableString *payload = [NSMutableString stringWithCapacity:20];
    for (NSString *key in gaProperties) {
        NSObject *value = [gaProperties objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            value = [(NSString *)value urlEncoding];
        }
        [payload appendFormat:@"%@=%@&", [key urlEncoding], value];
    }
    
    [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [GMLog debug:@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }];
}

- (void) login: (NSString *) username
{
    _user = username;
}

- (void) logout
{
    _user = nil;
}

- (void) flush
{
    
}

#pragma mark Internal methods
+ (NSString *) dimensionKeyFromName:(NSString *)name
{
    static NSDictionary *dimensions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dimensions = @{
                 @"reward_id": @1,
                 @"reward_name": @2,
                 @"store_id": @3,
                 @"store_name": @4,
                 @"category_id": @5,
                 @"category_name": @6
                 };
    });
    return [NSString stringWithFormat:@"cd%@", dimensions[name]];
}

@end
