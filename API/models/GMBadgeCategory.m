//
//  GMBadgeCategory.m
//  Gimmie
//
//  Created by llun on 12/18/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//

#import "GMBadgeCategory.h"
#import "GMTier.h"
#import "GMProfile.h"


@implementation GMBadgeCategory

- (id) initWithName:(NSString *)name andTiers:(NSArray *)tiers;
{
    self = [super init];
    if (self) {
        _name = name;
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:[tiers count]];
        for (NSArray *badges in tiers) {
            GMTier *tier = [[GMTier alloc] initWithBadges:badges];
            [items addObject:tier];
        }
        _tiers = items;
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@, %@", _name, _tiers];
}


- (NSArray *) unlockedTiersWithProgressForProfile:(GMProfile *)profile
{
    NSMutableArray *unlockedTiers = [NSMutableArray array];
    for (GMTier *tier in _tiers) {
        if ([[tier unlockedBadgesWithProgressForProfile:profile] count] > 0) {
            [unlockedTiers addObject:tier];
        }
    }
    return unlockedTiers;
}

- (NSArray *) lockedTiersWithProgressForProfile:(GMProfile *)profile
{
    NSMutableArray *lockedTiers = [NSMutableArray array];
    for (GMTier *tier in _tiers) {
        if ([[tier lockedBadgesWithProgressForProfile:profile] count] > 0) {
            [lockedTiers addObject:tier];
        }
    }
    
    return lockedTiers;
}


@end
