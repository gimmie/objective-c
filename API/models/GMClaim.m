//
//  GMClaim.m
//  OX
//
//  Created by llun on 11/19/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMService.h"
#import "GMClaim.h"

@implementation GMClaim

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _code = [data objectForKey:@"code"];
        
        NSDictionary *rewardDictionary = [data objectForKey:@"reward"];
        _reward = [[GMReward alloc] initWithDictionary:rewardDictionary];
        _url = [rewardDictionary objectForKey:@"url"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
        
        _createdDate = [formatter dateFromString:[data objectForKey:@"created_at"]];

    }
    return self;
}

- (NSString *) url {
    NSMutableString *urlWithNameAndEmail = [NSMutableString stringWithString:_url];
    
    GMService *service = [GMService sharedService];
    if ([service userInformationForKey:GMUserInformationKeyName]) {
        [urlWithNameAndEmail appendFormat:@"&name=%@", [service userInformationForKey:GMUserInformationKeyName]];
    }
    
    if ([service userInformationForKey:GMUserInformationKeyEmail]) {
        [urlWithNameAndEmail appendFormat:@"&email=%@", [service userInformationForKey:GMUserInformationKeyEmail]];
    }
    
    return _url;
}

@end
