//
//  GMUser.m
//  OX
//
//  Created by llun on 11/20/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMUser.h"

@implementation GMUser

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _userID = [data objectForKey:@"user_id"];
        _awardedPoints = [[data objectForKey:@"awarded_points"] intValue];
        _redeemedPoints = [[data objectForKey:@"redeemed_points"] intValue];
        _usedPoints = _awardedPoints - _redeemedPoints;
        
        _level = [[data objectForKey:@"current_level"] intValue];
        _nextLevelPoints = -1;
        _levelProgressPercent = 0;
        _currentLevelPoints = [[data objectForKey:@"current_level_points"] intValue];
        
        if ([[data objectForKey:@"next_level_points"] class] != [NSNull class]) {
            _nextLevelPoints = [[data objectForKey:@"next_level_points"] intValue];
            
            _levelProgressPercent = (double) (_awardedPoints - _currentLevelPoints) / (double) (_nextLevelPoints - _currentLevelPoints) * 100;
            _pointsToNextLevel = [[data objectForKey:@"points_to_next_level"] intValue];
        }
        else {
            _nextLevelPoints = -1;
            _pointsToNextLevel = -1;
            _levelProgressPercent = 100;
        }
        
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"ID: %@ Awarded: %d Redeemed: %d Used: %d",
            _userID, _awardedPoints, _redeemedPoints, _usedPoints];
}

@end
