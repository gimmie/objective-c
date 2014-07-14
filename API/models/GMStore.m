//
//  GMStore.m
//  OX
//
//  Created by llun on 11/16/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMStore.h"
#import "GMReward.h"

@implementation GMStore

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _name = [data objectForKey:@"name"];
        _imageURL = [data objectForKey:@"image_url"];
        
        NSArray *rewardArray = [data objectForKey:@"rewards"];
        NSMutableArray *tempRewards = [NSMutableArray arrayWithCapacity:[rewardArray count]];
        for (NSDictionary *rewardDict in rewardArray) {
            GMReward *reward = [[GMReward alloc] initWithDictionary:rewardDict];
            [tempRewards addObject:reward];
        }
        _rewards = [NSArray arrayWithArray:tempRewards];
    }
    return self;
}

@end
