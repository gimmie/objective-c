//
//  GMBadge.m
//  Gimmie
//
//  Created by llun on 8/19/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//

#import "GMBadge.h"
#import "GMService.h"

@implementation GMBadge

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _name = [data objectForKey:@"name"];
        _category = [data objectForKey:@"category_name"];
        _detail = [data objectForKey:@"description"];
        _imageURL = [GMService imageURLFromPath:[data objectForKey:@"image_url_retina"]];
        _tier = [[data objectForKey:@"tier"] intValue];
        _unlockMessage = [data objectForKey:@"unlock_message"];
        _ruleDescription = [data objectForKey:@"rule_description"];
    }
    return self;
}

- (NSNumber *) progress
{
    NSNumber *progress = @-1;
    
    NSArray *rules = [_ruleDescription objectForKey:@"or"];
    if (rules) {
        for (NSDictionary *andRules in rules) {
            NSArray *rules = [andRules objectForKey:@"and"];
            int total = 0;
            int count = 0;
            
            for (NSDictionary *rule in rules) {
                
                if ([rule objectForKey:@"progress"]) {
                    int progress = [[rule objectForKey:@"progress"] intValue];
                    int atLeast = [[rule objectForKey:@"at_least"] intValue];
                    total += atLeast;
                    
                    if (progress >= atLeast) {
                        count += atLeast;
                    }
                    else {
                        count += progress;
                    }
                }
                
            }
            
            NSNumber *currentRuleProgress = [NSNumber numberWithFloat:(count / total) * 100];
            if (currentRuleProgress.floatValue > progress.floatValue) {
                progress = currentRuleProgress;
            }
            
        }
    }
    
    return progress;
}

@end
