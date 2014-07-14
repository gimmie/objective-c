//
//  GMActivity.m
//  Gimmie
//
//  Created by llun on 1/29/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//

#import "GMRecentAction.h"

@implementation GMRecentAction

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _event = [[GMEvent alloc] initWithDictionary:[data objectForKey:@"event"]];
        _action = [[GMAction alloc] initWithDictionary:[data objectForKey:@"action"]];
        
        _createdTime = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"created_at"] longLongValue]];
    }
    return self;
}

@end
