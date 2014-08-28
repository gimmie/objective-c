//
//  GMLog.m
//  Gimmie-API
//
//  Created by llun on 8/28/14.
//  Copyright (c) 2014 Gimmieworld pte ltd. All rights reserved.
//

#import "GMLog.h"

@interface GMLog ()

+ (GMLog *) getInstance;

- (void) debug:(NSString *)format withParams:(va_list)valist;

@end

@implementation GMLog

static GMLog *instance;

+ (GMLog *) getInstance {
    if (!instance) {
        instance = [[GMLog alloc] init];
    }
    return instance;
}

+ (void)debug: (NSString *)format, ... {

    va_list data;
    va_start(data, format);
    
    [[GMLog getInstance] debug:format withParams:data];

    va_end(data);
}

- (void) debug: (NSString *)format withParams:(va_list)valist {
    NSString *log = [[NSString alloc] initWithFormat:format arguments:valist];
    NSLog(log);
    
    NSURL *url = [NSURL URLWithString:@"http://logs-01.loggly.com/inputs/9f9b6f87-3600-43bc-afea-fa9850da4390/tag/ios/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    NSData *postData = [log dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    
    if ([[NSURLConnection class] respondsToSelector: @selector(sendAsynchronousRequest:queue:completionHandler:)]) {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        }];
    }
}

@end
