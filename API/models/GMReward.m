//
//  GMReward.m
//  OX
//
//  Created by llun on 11/16/12.
//  Copyright (c) 2012 Gimmie. All rights reserved.
//

#import "GMService.h"
#import "GMReward.h"

@implementation GMReward

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _name = [data objectForKey:@"name"];
        _shortName = [data objectForKey:@"short_name"];
        _rewardDescription = [data objectForKey:@"description"];
        if (!_rewardDescription ||
            [_rewardDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            _rewardDescription = @"No description";
        }
        
        _finePrint = [data objectForKey:@"fine_print"];
        if (!_finePrint ||
            [_finePrint stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            _finePrint = @"No fine print";
        }
        
        _imageURL = [GMService imageURLFromPath:[data objectForKey:@"image_url_retina"]];
        _storeName = [data objectForKey:@"store_name"];
        
        _category = [data objectForKey:@"category_name"];
        
        _points = [[data objectForKey:@"points"] intValue];
        
        _totalQuantity = [[data objectForKey:@"total_quantity"] intValue];
        _claimedQuantity = [[data objectForKey:@"claimed_quantity"] intValue];
        
        if ((_totalQuantity > 0 && _totalQuantity > _claimedQuantity) || _totalQuantity < 0) {
            _isSoldOut = NO;
        }
        else {
            _isSoldOut = YES;
        }
        
        _isFeatured = [[data objectForKey:@"featured"] boolValue];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        if ([data objectForKey:@"start_date"]) {
            _startDate = [formatter dateFromString:[data objectForKey:@"start_date"]];
        }
        if ([data objectForKey:@"end_date"]) {
            _endDate = [formatter dateFromString:[data objectForKey:@"end_date"]];
        }

        NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
        
        if ([data objectForKey:@"valid_until"]) {
            _validUntil = [rfc3339DateFormatter dateFromString:[data objectForKey:@"valid_until"]];
        }
        
        if ([_validUntil compare:[NSDate date]] == NSOrderedAscending) {
            _isExpired = YES;
        }
        else {
            _isExpired = NO;
        };

        _countries = [data objectForKey:@"country_codes"];
    }
    return self;
}

- (BOOL) isAvailableInCountry:(NSString *)country
{
    if ([_countries containsObject:GMCountryGlobal]) {
        return true;
    }
    else {
        return [_countries containsObject:[country uppercaseString]];
    }
}

@end
