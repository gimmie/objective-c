//
//  GMAction.m
//  OX
//
//  Created by llun on 11/20/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMAction.h"
#import "GMClaim.h"

@implementation GMAction

- (id) initWithDictionary:(NSDictionary *) data
{
    self = [super init];
    if (self) {
        
        if ([[data objectForKey:@"action_type"] isEqualToString:@"Award Points"]) {
            _type = GMActionTypeAwardPoints;
        }
        else if ([[data objectForKey:@"action_type"] isEqualToString:@"Instant Reward"]) {
            _type = GMActionTypeInstantReward;
        }
        else {
            _type = GMActionTypeUnknown;
        }
        
        _message = [data objectForKey:@"message"];
        if (![[data objectForKey:@"points"] isKindOfClass:[NSNull class]]) {
            _points = [[data objectForKey:@"points"] intValue];
        }
        _success = [[data objectForKey:@"success"] boolValue];
        
        if (_type == GMActionTypeInstantReward) {
            _claim = [[GMClaim alloc] initWithDictionary:[data objectForKey:@"claim"]];
        }
    }
    return self;
}

@end
