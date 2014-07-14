//
//  GMEvent.m
//  OX
//
//  Created by llun on 11/20/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMEvent.h"
#import "GMAction.h"

@implementation GMEvent

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _description = [data objectForKey:@"description"];
        _name = [data objectForKey:@"name"];
        
        NSArray *actionsDict = [data objectForKey:@"actions"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[actionsDict count]];
        for (NSDictionary *actionDict in actionsDict) {
            GMAction *action = [[GMAction alloc] initWithDictionary:actionDict];
            [temp addObject:action];
        }
        
        _actions = [NSArray arrayWithArray:temp];
    }
    return self;
}

@end
