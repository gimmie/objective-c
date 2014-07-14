//
//  GMMayorship.m
//  Gimmie
//
//  Created by llun on 8/19/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//

#import "GMMayorship.h"
#import "GMService.h"

@implementation GMMayorship

- (id) initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        _name = [data objectForKey:@"name"];
        _imageURL = [GMService imageURLFromPath:[data objectForKey:@"image_url_retina"]];
    }
    return self;
}

@end
