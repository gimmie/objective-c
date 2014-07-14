//
//  GMRemoteObject.m
//  OX
//
//  Created by llun on 11/16/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMIDObject.h"

@implementation GMIDObject

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _raw = data;
        _objectID = [[data objectForKey:@"id"] intValue];
    }
    return self;
}

/**
 Private API for getting raw data
 
 @return NSDictionary raw dictionary from API
 */
- (NSDictionary *) rawData {
    return _raw;
}

- (NSString *) description
{
    return [_raw description];
}

@end
