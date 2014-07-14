//
//  GMTriggerResponse.m
//  Gimmie
//
//  Created by llun on 8/22/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//

#import "GMCombineResponse.h"

#import "GMUser.h"
#import "GMCategory.h"
#import "GMAction.h"
#import "GMBadge.h"
#import "GMMayorship.h"

NSString * const GMCombineResponseKeyActions = @"actions";
NSString * const GMCombineResponseKeyBadges = @"badges";
NSString * const GMCombineResponseKeyCategories = @"categories";
NSString * const GMCombineResponseKeyMayorship = @"mayor";
NSString * const GMCombineResponseKeyUser = @"user";

@interface GMCombineResponse (Internal)

+ (NSArray *) arrayForKey:(NSString *)key inDictionary:(NSDictionary *)rawDictionary;
+ (Class) classForKey:(NSString *)key;

@end

@implementation GMCombineResponse

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _rawResponse = dictionary;
    }
    return self;
}

- (id) objectForKey:(NSString *)key
{
    if ([_rawResponse objectForKey:key]) {
        if ([key isEqualToString:GMCombineResponseKeyActions] ||
            [key isEqualToString:GMCombineResponseKeyBadges] ||
            [key isEqualToString:GMCombineResponseKeyCategories]) {
            return [GMCombineResponse arrayForKey:key inDictionary:_rawResponse];
        }
        else if ([key isEqualToString:GMCombineResponseKeyMayorship] ||
                 [key isEqualToString:GMCombineResponseKeyUser]) {
            Class clazz = [GMCombineResponse classForKey:key];
            return [[clazz alloc] initWithDictionary:[_rawResponse objectForKey:key]];
        }
    }
    
    return nil;
}

+ (NSArray *) arrayForKey:(NSString *)key inDictionary:(NSDictionary *)rawDictionary;
{
    Class clazz = [GMCombineResponse classForKey:key];
    NSArray *rawObjects = [rawDictionary objectForKey:key];
    NSMutableArray *temporaryConcreteArray = [NSMutableArray arrayWithCapacity:[rawObjects count]];
    for (NSDictionary *rawDictionary in rawObjects) {
        id concreteObject = [[clazz alloc] initWithDictionary:rawDictionary];
        [temporaryConcreteArray addObject:concreteObject];
    }
    return [NSArray arrayWithArray:temporaryConcreteArray];
}

+ (Class) classForKey:(NSString *)key
{
    Class output = nil;
    if ([key isEqualToString:GMCombineResponseKeyActions]) {
        output = [GMAction class];
    }
    else if ([key isEqualToString:GMCombineResponseKeyBadges]) {
        output = [GMBadge class];
    }
    else if ([key isEqualToString:GMCombineResponseKeyCategories]) {
        output = [GMCategory class];
    }
    else if ([key isEqualToString:GMCombineResponseKeyMayorship]) {
        output = [GMMayorship class];
    }
    else if ([key isEqualToString:GMCombineResponseKeyUser]) {
        output = [GMUser class];
    }
    return output;
}

@end
