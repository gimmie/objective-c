//
//  GMTopPlayer.m
//  Gimmie
//
//  Created by llun on 28/5/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//

#import "GMTopPlayer.h"

@implementation GMTopPlayer

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _externalUid = [data objectForKey:@"external_uid"];
        _rank = [[data objectForKey:@"rank"] intValue];
        _value = [NSNumber numberWithDouble:[[data objectForKey:@"value"] doubleValue]];
        
        _raw = data;
    }
    return self;
}

- (NSString *) description
{
    return [_raw description];
}

@end
