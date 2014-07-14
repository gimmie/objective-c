//
//  GMTier.m
//  Gimmie
//
//  Created by llun on 12/18/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//

#import "GMTier.h"
#import "GMBadge.h"
#import "GMProfile.h"

@interface GMTier (internal)

- (NSArray *) badgedWithProgressForProfile:(GMProfile *)profile andUnlocked:(BOOL)isUnlock;

@end

@implementation GMTier

- (id) initWithBadges:(NSArray *)badges;
{
    self = [super init];
    if (self) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:[badges count]];
        for (NSDictionary *dict in badges) {
            GMBadge *badge = [[GMBadge alloc] initWithDictionary:dict];
            [items addObject:badge];
        }
        _badges = items;
    }
    return self;
}

- (NSString *) description
{
    return [_badges description];
}

- (NSArray *) unlockedBadgesWithProgressForProfile:(GMProfile *)profile
{
    return [self badgedWithProgressForProfile:profile andUnlocked:YES];
}

- (NSArray *) lockedBadgesWithProgressForProfile:(GMProfile *)profile
{
    return [self badgedWithProgressForProfile:profile andUnlocked:NO];
}

- (NSArray *) badgedWithProgressForProfile:(GMProfile *)profile andUnlocked:(BOOL)isUnlock
{
    NSMutableSet *unlockedSet = [NSMutableSet set];
    for (GMBadge *badge in profile.badges) {
        [unlockedSet addObject:[NSNumber numberWithInt:badge.objectID]];
    }
    
    NSMutableArray *unlockedArray = [NSMutableArray array];
    for (GMBadge *badge in _badges) {
        if ([unlockedSet containsObject:[NSNumber numberWithInt:badge.objectID]] == isUnlock) {
            [unlockedArray addObject:badge];
        }
    }
    return unlockedArray;
}

@end
