//
//  GMProfile.m
//  OX
//
//  Created by llun on 11/14/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMProfile.h"
#import "GMClaim.h"
#import "GMBadge.h"
#import "GMMayorship.h"
#import "GMUser.h"

@implementation GMProfile

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        NSDictionary *user = [data objectForKey:@"user"];
        
        _user = [[GMUser alloc] initWithDictionary:user];
        
        NSArray *claims = [data objectForKey:@"claims"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[claims count]];
        for (NSDictionary *claimDict in claims) {
            GMClaim *claim = [[GMClaim alloc] initWithDictionary:claimDict];
            [temp addObject:claim];
        }
        _claims = [[temp reverseObjectEnumerator] allObjects];
        
        NSArray *badges = [data objectForKey:@"badges"];
        [temp removeAllObjects];
        for (NSDictionary *badgeDict in badges) {
            GMBadge *badge = [[GMBadge alloc] initWithDictionary:badgeDict];
            [temp addObject:badge];
        }
        _badges = [NSArray arrayWithArray:temp];
        
        NSArray *mayorships = [data objectForKey:@"mayors"];
        [temp removeAllObjects];
        for (NSDictionary *mayorshipDict in mayorships) {
            GMMayorship *mayorship = [[GMMayorship alloc] initWithDictionary:mayorshipDict];
            [temp addObject:mayorship];
        }
        _mayorships = [NSArray arrayWithArray:temp];
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@\n%@", [_user description], _claims];
}

@end
