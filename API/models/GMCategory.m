//
//  GMCategory.m
//  Gimmie
//
//  Created by llun on 12/19/12.
//  Copyright (c) 2012 gimmie. All rights reserved.
//

#import "GMService.h"
#import "GMCategory.h"
#import "GMReward.h"

@implementation GMCategory

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [self initWithCountry:GMCountryGlobal andDictionary:data];
    return self;
}

- (id) initWithCountry:(NSString *)country andDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _name = [data objectForKey:@"name"];
        
        NSArray *rewardArray = [data objectForKey:@"rewards"];
        
        NSMutableArray *fullyRedeemedRewards = [NSMutableArray arrayWithCapacity:[rewardArray count]];
        NSMutableArray *tempRewards = [NSMutableArray arrayWithCapacity:[rewardArray count]];
        for (NSDictionary *rewardDict in rewardArray) {
            GMReward *reward = [[GMReward alloc] initWithDictionary:rewardDict];
            if ([reward isAvailableInCountry:country]) {
                if (reward.isSoldOut) {
                    [fullyRedeemedRewards addObject:reward];
                }
                else {
                    [tempRewards addObject:reward];
                }
                
            }
        }
        
        // Shuffle an array
        srandom(time(NULL));
        NSUInteger count = [tempRewards count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            int nElements = count - i;
            if (nElements > 0) {
                int n = (random() % nElements) + i;
                [tempRewards exchangeObjectAtIndex:i withObjectAtIndex:n];
            }
        }
        
        _rewards = [tempRewards arrayByAddingObjectsFromArray:fullyRedeemedRewards];
    }
    return self;
}

@end
