//
//  GMTracker.m
//  Gimmie
//
//  Created by llun on 28/5/14.
//  Copyright (c) 2014 gimmie. All rights reserved.
//

#import "GMAnalytics.h"

#import "GMGATracker.h"

@implementation GMAnalytics
{
    id<GMTracker> _tracker;
}

static GMAnalytics * instance = nil;

+ (GMAnalytics *) instance {
    if (!instance) {
        instance = [GMAnalytics new];
    }
    return instance;
}

- (id) init
{
    self = [super init];
    if (self) {
        _tracker = [[GMGATracker alloc] initWithTrackingID:@"UA-51271973-1"];
    }
    return self;
}

- (id<GMTracker>) tracker {
    return _tracker;
}

+ (void) trackEvent:(NSString *) eventName
{
    [[GMAnalytics instance].tracker trackEvent:eventName];
}

+ (void) trackEvent:(NSString *)eventName properties: (NSDictionary *) properties
{
    [[GMAnalytics instance].tracker trackEvent:eventName properties:properties];
}

+ (void) login:(NSString *)user
{
    [[GMAnalytics instance].tracker login:user];
}

+ (void) logout
{
    [[GMAnalytics instance].tracker logout];
}

+ (void) flush
{
    [[GMAnalytics instance].tracker flush];
}

@end
