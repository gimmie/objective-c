//
//  GMNetworkOperation.m
//  Gimmie
//
//  Created by llun on 1/15/13.
//  Copyright (c) 2013 gimmie. All rights reserved.
//
#import <CommonCrypto/CommonCrypto.h>

#import "GMNetworkOperation.h"

#import "NSData+GMAddition.h"
#import "NSString+GMAddition.h"

@implementation GMNetworkOperation

+ (NSOperationQueue *) networkQueue
{
    static NSOperationQueue *queue = nil;
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
    }
    return queue;
}

- (id) initWithKey:(NSString *)key secret:(NSString *)secret api:(NSString *)api
{
    self = [super init];
    if (self) {
        _key = key;
        _secret = secret;
        _api = api;
        
        _isExecuting = NO;
    }
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    GMNetworkOperation *operation = [[GMNetworkOperation allocWithZone:zone] initWithKey:_key secret:_secret api:_api];
    return operation;
}

- (void) main
{
    NSMutableString *arguments = [NSMutableString string];
    if ([_parameters count] > 0) {
        [arguments appendString:@"?"];
        NSEnumerator *enumerator = [_parameters keyEnumerator];
        for (NSString *key in enumerator) {
            NSString *value = [NSString stringWithFormat:@"%@", [_parameters objectForKey:key]];
            [arguments appendFormat:@"%@=%@&", [key urlEncoding], [value urlEncoding]];
        }
        [arguments deleteCharactersInRange:NSMakeRange([arguments length] - 1, 1)];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _target, arguments]
                        relativeToURL:[NSURL URLWithString:_api]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    if (self.headers) {
        for (NSString *key in [self.headers keyEnumerator]) {
            NSString *value = [self.headers objectForKey:key];
            [request setValue:value forHTTPHeaderField:key];
        }
    }
    
    [self signatureBaseStringForRequest:request];
    if ([[NSURLConnection class] respondsToSelector: @selector(sendAsynchronousRequest:queue:completionHandler:)]) {
        [NSURLConnection sendAsynchronousRequest:request queue:[GMNetworkOperation networkQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            @try {
                if (!error) {
                    NSError *JSONError = nil;
                    NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&JSONError];
                    if (!JSONError) {
                        NSDictionary *response = [output objectForKey:@"response"];
                        if ([[response objectForKey:@"success"] boolValue]) {
                            if (_callback && !self.isCancelled) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    _callback (nil, output);
                                });
                            }
                        }
                        else {
                            NSDictionary *errorDict = [output objectForKey:@"error"];
                            NSError *error = [[NSError alloc] initWithDomain:[errorDict objectForKey:@"code"] code:0 userInfo:errorDict];
                            NSLog(@"GMError: %@", error);
                            if (!self.isCancelled) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:GMErrorNotification object:nil userInfo:errorDict];
                                if (_callback) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        _callback (error, nil);
                                    });
                                }
                            }
                        }
                    }
                }
                else {
                    NSLog(@"GMError: %@", error);
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
                    dictionary[@"error"] = @"Cannot connect to the rewards catalog. Try again with connection.";
                    NSError *_error = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:dictionary];
                    if (!self.isCancelled) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:GMErrorNotification object:nil userInfo:dictionary];
                        if (_callback) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _callback(_error, nil);
                            });
                        }
                    }
                }
                
                

            }
            @catch (NSException *exception) {
                NSLog(@"Unexpected error: %@", exception);
            }
            @finally {
                [self willChangeValueForKey:@"isExecuting"];
                [self willChangeValueForKey:@"isFinished"];
                _isExecuting = NO;
                [self didChangeValueForKey:@"isExecuting"];
                [self didChangeValueForKey:@"isFinished"];
            }
        }];
    }
    else {
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            NSError *JSONError = nil;
            
            NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
            if (!JSONError) {
                NSDictionary *response = [output objectForKey:@"response"];
                if ([[response objectForKey:@"success"] boolValue]) {
                    if (_callback && !self.isCancelled) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _callback (nil, output);
                        });
                    }
                }
                else {
                    NSDictionary *errorDict = [output objectForKey:@"error"];
                    NSError *error = [[NSError alloc] initWithDomain:[errorDict objectForKey:@"code"] code:0 userInfo:errorDict];
                    NSLog(@"GMError: %@", error);
                    if (!self.isCancelled) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:GMErrorNotification object:nil userInfo:errorDict];
                        if (_callback) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _callback (error, nil);
                            });
                        }
                    }
                }
            }
        }
        else {
            NSLog(@"GMError: %@", error);
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            dictionary[@"error"] = @"Cannot connect to the rewards catalog. Try again with connection.";
            NSError *_error = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:dictionary];
            if (!self.isCancelled) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GMErrorNotification object:nil userInfo:dictionary];
                if (_callback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _callback(_error, nil);
                    });
                }
            }
        }
        
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        _isExecuting = NO;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }
    
}

- (void) start
{
    if ([self isCancelled]) {
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(main) object:nil];
    [self willChangeValueForKey:@"isExecutiing"];
    [thread start];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL) isConcurrent
{
    return YES;
}

- (BOOL) isExecuting
{
    return _isExecuting;
}

- (BOOL) isFinished
{
    return !_isExecuting;
}

- (NSString *) user
{
    if (!_user) {
        return @"";
    }
    else {
        return _user;
    }
}

#pragma mark - OAuth methods
- (void)signatureBaseStringForRequest:(NSMutableURLRequest *)request
{
    NSString *authorizationHeader = [self authorizationHeaderForRequest:request timestamp:[NSString stringWithFormat:@"%ld", time(NULL)] nounce:[NSString UUID]];
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
}

- (NSString *)authorizationHeaderForRequest:(NSURLRequest *) request timestamp:(NSString *)timestamp nounce:(NSString *)nonce
{
    NSString *method = request.HTTPMethod;
    NSMutableString *baseURL = [NSMutableString stringWithFormat:@"%@://%@", request.URL.scheme, request.URL.host];
    if (request.URL.port) {
        [baseURL appendFormat:@":%@", request.URL.port];
    }
    [baseURL appendString:request.URL.path];
    
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:10];
    
    NSString *token = [self.user urlEncoding];
    
    [components addObject:[NSDictionary dictionaryWithObjectsAndKeys:_key, @"oauth_consumer_key", nil]];
    [components addObject:[NSDictionary dictionaryWithObjectsAndKeys:nonce, @"oauth_nonce", nil]];
    [components addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"HMAC-SHA1", @"oauth_signature_method", nil]];
    [components addObject:[NSDictionary dictionaryWithObjectsAndKeys:timestamp, @"oauth_timestamp", nil]];
    [components addObject:[NSDictionary dictionaryWithObjectsAndKeys:token, @"oauth_token", nil]];
    [components addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"oauth_version", nil]];
    
    NSArray *queryComponents = [request.URL.query componentsSeparatedByString:@"&"];
    for (NSString *queryComponent in queryComponents) {
        NSArray *queryFragments = [queryComponent componentsSeparatedByString:@"="];
        NSString *key = [queryFragments objectAtIndex:0];
        NSString *value = [queryFragments objectAtIndex:1];
        
        NSDictionary *queryDict = [NSDictionary dictionaryWithObjectsAndKeys:value, key, nil];
        [components addObject:queryDict];
    }
    
    [components sortUsingComparator:^NSComparisonResult(NSDictionary *first, NSDictionary *second) {
        NSString *firstKey = [[first keyEnumerator] nextObject];
        NSString *secondKey = [[second keyEnumerator] nextObject];
        
        NSComparisonResult result = [firstKey compare:secondKey options:NSCaseInsensitiveSearch];
        if (result == NSOrderedSame) {
            NSString *firstValue = [first objectForKey:firstKey];
            NSString *secondValue = [second objectForKey:secondKey];
            
            result = [firstValue compare:secondValue options:NSCaseInsensitiveSearch];
        }
        
        return result;
    }];
    
    NSMutableString *signatureBase = [NSMutableString stringWithFormat:@"%@&%@&", method, [baseURL urlEncoding]];
    
    NSMutableString *arguments = [NSMutableString string];
    
    for (NSDictionary *component in components) {
        NSString *key = [[component keyEnumerator] nextObject];
        if (!key)  continue;
        
        NSString *final = [NSString stringWithFormat:@"%@=%@", key, [component objectForKey:key]];
        [arguments appendFormat:@"&%@", final];
    }
    [signatureBase appendString:[[arguments substringFromIndex:1] urlEncoding]];
    
    NSString *signature = [self generateHMAC_SHA1SignatureFor:signatureBase];
    
    NSMutableString *authorizationHeader = [NSMutableString stringWithFormat:@"OAuth oauth_nonce=\"%@\"", nonce];
    [authorizationHeader appendFormat:@", oauth_timestamp=\"%@\"", timestamp];
    [authorizationHeader appendString:@", oauth_version=\"1.0\""];
    [authorizationHeader appendFormat:@", oauth_consumer_key=\"%@\"", _key];
    [authorizationHeader appendFormat:@", oauth_token=\"%@\"", token];
    [authorizationHeader appendFormat:@", oauth_signature=\"%@\"", [signature urlEncoding]];
    [authorizationHeader appendString:@", oauth_signature_method=\"HMAC-SHA1\""];
    
    return authorizationHeader;
}

- (NSString *)generateHMAC_SHA1SignatureFor:(NSString *)baseString
{
    NSString *key = [NSString stringWithFormat:@"%@&%@",
                     _secret != nil ? [_secret urlEncoding] : @"",
                     _secret != nil ? [_secret urlEncoding] : @""];
    
    const char *keyBytes = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *baseStringBytes = [baseString cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char digestBytes[CC_SHA1_DIGEST_LENGTH];
    
	CCHmacContext ctx;
    CCHmacInit(&ctx, kCCHmacAlgSHA1, keyBytes, strlen(keyBytes));
	CCHmacUpdate(&ctx, baseStringBytes, strlen(baseStringBytes));
	CCHmacFinal(&ctx, digestBytes);
    
	NSData *digestData = [NSData dataWithBytes:digestBytes length:CC_SHA1_DIGEST_LENGTH];
    return [digestData base64EncodedString];
}

@end
