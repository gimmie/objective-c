//
//  Gimmie.m
//  Gimmie
//
//  Created by llun on 11/26/12.
//  Copyright (c) 2012 gimmie. All rights reserved.
//

@import UIKit;
@import Security;
#import <CommonCrypto/CommonCrypto.h>

#import "GMNetworkOperation.h"

#import "NSData+GMAddition.h"
#import "NSString+GMAddition.h"

#import "GMService.h"
#import "GMAnalytics.h"

NSString * const GMNetworkErrorNotification = @"gimmie:error";
NSString * const GMEventTriggerDidResponseNotification = @"gimmie:trigger";
NSString * const GMProfileDidResponseNotification = @"gimmie:profile";
NSString * const GMRedeemDidResponseNotification = @"gimmie:redeem";
NSString * const GMNeedLoginNotification = @"gimmie:needlogin";
NSString * const GMLogoutNotification = @"gimmie:logout";
NSString * const GMErrorNotification = @"gimmie:error";

NSString * const GMNotificationFieldResponse = @"response";
NSString * const GMNotificationFieldUser = @"user";
NSString * const GMNotificationFieldProfile = @"profile";

NSString * const GMTop20Points = @"points";
NSString * const GMTop20RedemptionPrices = @"prices";
NSString * const GMTop20RedemptionCount = @"redemptions_count";

NSString * const GMCountryGlobal = @"global";

NSString * const GMUserInformationKeyName = @"name";
NSString * const GMUserInformationKeyEmail = @"email";

@interface GMService (internal)

- (id) initWithConsumerKey:(NSString *)consumerKey secret:(NSString *)secret api:(NSString *)api;
- (void) invokeTarget:(NSString *) target
           parameters:(NSDictionary *) parameters
             callback:(void (^)(NSError *error, NSDictionary *output))callback;
- (void) invokeTarget:(NSString *) target
           parameters:(NSDictionary *) parameters
              headers:(NSDictionary *) headers
             callback:(void (^)(NSError *error, NSDictionary *output))callback;
- (void) invokeTarget:(NSString *) target
           parameters:(NSDictionary *) parameters
              headers:(NSDictionary *) headers
                queue:(NSOperationQueue *)queue
             callback:(void (^)(NSError *error, NSDictionary *output))callback;

- (void) _loginWithOptionalGuestUser:(NSString *) user;

@end

@implementation GMService

static GMService *instance = nil;
static GMNetworkOperation *operationTemplate = nil;
static NSOperationQueue *networkQueue = nil;

+ (GMService *) sharedService
{
    NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSDictionary *gimmieSettings = [dictionary objectForKey:@"Gimmie"];
    if ([dictionary objectForKey:@"Gimmie-Dev"]) {
        gimmieSettings = [dictionary objectForKey:@"Gimmie-Dev"];
    }
    
    NSString *key = [gimmieSettings objectForKey:@"key"];
    NSString *secret = [gimmieSettings objectForKey:@"secret"];
    
    return [GMService sharedServiceWithKey:key secret:secret];
}

+ (GMService *) sharedServiceWithKey:(NSString *)key secret:(NSString *)secret
{
    @synchronized (self) {
        if (!instance) {
            NSDictionary *dictionary = [[NSBundle mainBundle] infoDictionary];
            
            NSDictionary *gimmieSettings = [dictionary objectForKey:@"Gimmie"];
            if ([dictionary objectForKey:@"Gimmie-Dev"]) {
                gimmieSettings = [dictionary objectForKey:@"Gimmie-Dev"];
            }
            
            NSString *api = [gimmieSettings objectForKey:@"api"];
            NSString *sponsorUrl = [gimmieSettings objectForKey:@"sponsor-url"];
            
            if (!api) {
                api = @"https://api.gimmieworld.com/1/";
            }
            
            if (!sponsorUrl) {
                sponsorUrl = @"http://www.gimmieworld.com/sponsors/";
            }
            
            
            NSString *country = [gimmieSettings objectForKey:@"country"];
            if (!country) {
                country = GMCountryGlobal;
            }
            NSLog(@"Gimmie country: %@", country);
            
            NSString *locale = [gimmieSettings objectForKey:@"locale"];
            if (!locale) {
                locale = @"";
            }
            
            NSAssert(key != nil && secret != nil, @"Gimmie key and secret is required");
            instance = [[GMService alloc] initWithConsumerKey:key secret:secret api:api];
            instance.country = country;
            instance.locale = locale;
            instance.sponsorUrl = sponsorUrl;
        }
        return instance;
    }
}

- (id) initWithConsumerKey:(NSString *)consumerKey secret:(NSString *)secret api:(NSString *)api
{
    self = [super init];
    if (self) {
        _key = consumerKey;
        _secret = secret;
        _api = api;
        
        _additionInformation = [NSMutableDictionary dictionaryWithCapacity:2];
        
        if (!operationTemplate) {
            operationTemplate = [[GMNetworkOperation alloc] initWithKey:_key secret:_secret api:_api];
        }
        
        if (!networkQueue) {
            networkQueue = [[NSOperationQueue alloc] init];
        }
        
        _handlers = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void) loginWithGenerateID
{
    NSString * const RANDOM_KEY = @"GIMMIE_RANDOM_ID";
    
    NSString *randomID = nil;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences objectForKey:RANDOM_KEY]) {
        randomID = [preferences objectForKey:RANDOM_KEY];
    }
    else {
        randomID = [[NSUUID UUID] UUIDString];
        [preferences setObject:randomID forKey:RANDOM_KEY];
    }
    
    [self login:[NSString stringWithFormat:@"guest:%@", randomID]];
}

- (void) login:(NSString *)user
{
    [self login:user withAdditionalInformation:nil];
}

- (void) login:(NSString *)user withName:(NSString *)name andEmail:(NSString *)email
{
    NSDictionary *dictionary = @{ GMUserInformationKeyName: name, GMUserInformationKeyEmail: email };
    [self login:user withAdditionalInformation:dictionary];
}

- (void) login:(NSString *)user withAdditionalInformation:(NSDictionary *)additionalInformation
{
    NSString *guestUser = nil;
    if (_user && [_user hasPrefix:@"guest:"]) {
        guestUser = _user;
    }
    
    _user = user;
    
    [_additionInformation removeAllObjects];
    if (additionalInformation) {
        [_additionInformation addEntriesFromDictionary:additionalInformation];
    }
    
    [GMAnalytics login:user];
    
    if (guestUser) {
        [self _loginWithOptionalGuestUser:guestUser];
    }
}

- (void) logout
{
    _user = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: GMLogoutNotification
                                                        object: self
                                                      userInfo: nil];
}

- (BOOL) loggedIn
{
    if (_user) {
        return YES;
    }
    return NO;
}

- (BOOL) isLoginAsGuest
{
    return [_user hasPrefix:@"guest:"];
}

- (NSString *) userInformationForKey:(NSString *)key
{
    return [_additionInformation objectForKey:key];
}

#pragma mark - Notification Actions methods
- (void) registerNotificationHandler:(void (^)(NSError *error, NSArray *actions))handler
{
    [_handlers addObject:handler];
}

#pragma mark - Push notification
- (void) registerPushNotificationWithTokenData:(NSData *)token
{

    GMService *_gimmie = self;
    if ([_gimmie loggedIn]) {
        NSDictionary *parameters = @{@"target": @"ios",
                                     @"id": [token hexRepresentationWithSpaces_AS:NO]};
        [self invokeTarget:@"register_token.json" parameters:parameters callback:^(NSError *error, NSDictionary *output) {
            if (error) {
                NSLog(@"Error: %@", error);
                return;
            }
            
        }];
    }
}

- (void) pushNotificationTokenCallback:(void (^) (NSError *error, NSString *token)) callback
{
    GMService *_gimmie = self;
    if ([_gimmie loggedIn]) {
        [self invokeTarget:@"notification_token.json"
                parameters:nil
                  callback:^(NSError *error, NSDictionary *result) {
                      if (error) {
                          callback(error, nil);
                          return;
                      }
            
                      NSDictionary *response = [result objectForKey:@"response"];
                      if ([[response objectForKey:@"success"] boolValue]) {
                          callback(nil, [response objectForKey:@"notification_token"]);
                      }
                      else {
                          callback(nil, @"");
                      }
                  }];
    }
}

#pragma mark - Service methods
- (void) getProfileCallback:(void (^) (NSError *error, GMProfile *profile))callback
{
    GMService *_gimmie = self;
    [self invokeTarget:@"profile.json" parameters:nil callback:^(NSError *error, NSDictionary *result) {
        if (error) { callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            GMProfile *profile = [[GMProfile alloc] initWithDictionary:response];
            callback (nil, profile);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:GMProfileDidResponseNotification
             object:_gimmie
             userInfo:@{ GMNotificationFieldProfile: profile }];
        }
    }];
}

- (void) loadCategoryCallback:(void (^)(NSError *, NSArray *))callback
{
    [self invokeTarget:@"categories.json" parameters:nil callback:^(NSError *error, NSDictionary *result) {
        if (error) { callback (error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            NSArray *categoriesDict = [response objectForKey:@"categories"];
            NSMutableArray *categoriesTemp = [NSMutableArray arrayWithCapacity:[categoriesDict count]];
            for (NSDictionary *categoryDict in categoriesDict) {
                GMCategory *category = [[GMCategory alloc] initWithDictionary:categoryDict];
                [categoriesTemp addObject:category];
            }
            
            callback (nil, [NSArray arrayWithArray:categoriesTemp]);
        }
    }];
}

- (void) loadCategoryForCountry:(NSString *)countryCode callback:(void (^) (NSError *error, NSArray *categories)) callback
{
    [self invokeTarget:@"categories.json" parameters:nil callback:^(NSError *error, NSDictionary *result) {
        if (error) { callback (error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            NSArray *categoriesDict = [response objectForKey:@"categories"];
            NSMutableArray *categoriesTemp = [NSMutableArray arrayWithCapacity:[categoriesDict count]];
            for (NSDictionary *categoryDict in categoriesDict) {
                GMCategory *category = [[GMCategory alloc] initWithCountry:countryCode andDictionary:categoryDict];
                [categoriesTemp addObject:category];
            }
            
            callback (nil, [NSArray arrayWithArray:categoriesTemp]);
        }
    }];
}

- (void) triggerEventName:(NSString *)eventName
                 callback:(void (^)(NSError *error, GMCombineResponse *))callback
{
    GMService *_gimmie = self;
    NSDictionary *parameters = @{ @"event_name": eventName };
    [self invokeTarget:@"trigger.json" parameters:parameters callback:^(NSError *error, id result) {
        if (error) { if (callback) callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            
            GMCombineResponse *triggerResponse = [[GMCombineResponse alloc] initWithDictionary:response];
            
            if (callback) callback (nil, triggerResponse);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:GMEventTriggerDidResponseNotification
             object:_gimmie
             userInfo:@{ GMNotificationFieldResponse: triggerResponse }];
        }
    }];
}

- (void) triggerEventID:(NSNumber *)eventID
               callback:(void (^)(NSError *, GMCombineResponse *))callback
{
    GMService *_gimmie = self;
    NSDictionary *parameters = @{ @"event_id": eventID };
    [self invokeTarget:@"trigger.json" parameters:parameters callback:^(NSError *error, id result) {
        if (error) { if (callback) callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            
            GMCombineResponse *triggerResponse = [[GMCombineResponse alloc] initWithDictionary:response];
            
            if (callback) callback (nil, triggerResponse);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:GMEventTriggerDidResponseNotification
             object:_gimmie
             userInfo:@{ GMNotificationFieldResponse: triggerResponse }];
        }
    }];
}

- (void) checkin:(NSString *)checkinID
           venue:(NSString *)place
        callback:(void (^)(NSError *error, GMCombineResponse *triggerResponse))callback;

{
    GMService *_gimmie = self;
    NSDictionary *parameters = @{ @"venue": place };
    [self invokeTarget:[NSString stringWithFormat:@"check_in/%@.json", checkinID]
            parameters:parameters
              callback:^(NSError *error, NSDictionary *result) {
                  if (error) { if (callback) callback(error, nil); }
                  else {
                      NSDictionary *response = [result objectForKey:@"response"];
                      
                      GMCombineResponse *triggerResponse = [[GMCombineResponse alloc] initWithDictionary:response];
                      
                      if (callback) callback(nil, triggerResponse);
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:GMEventTriggerDidResponseNotification
                       object:_gimmie
                       userInfo:@{ GMNotificationFieldResponse: triggerResponse }];
                  }
              }];
}

- (void) redeemWithReward:(NSNumber *) rewardID
                 callback:(void (^) (NSError *error, GMUser *user, GMClaim *claim)) callback
{
    GMService *_gimmie = self;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                rewardID, @"reward_id",
                                @"1", @"email", nil];
    [self invokeTarget:@"redeem.json" parameters:parameters callback:^(NSError *error, id result) {
        if (error) { callback(error, nil, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            GMUser *user = [[GMUser alloc] initWithDictionary:[response objectForKey:@"user"]];
            GMClaim *claim = [[GMClaim alloc] initWithDictionary:[response objectForKey:@"claim"]];
            
            callback (nil, user, claim);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:GMRedeemDidResponseNotification
             object:_gimmie
             userInfo:@{ GMNotificationFieldUser : user }];
        }
    }];
}

- (void) loadReward:(NSNumber *) rewardID callback:(void (^) (NSError *error, GMReward *reward)) callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                rewardID, @"reward_id", nil];
    [self invokeTarget:@"rewards.json" parameters:parameters callback:^(NSError *error, id result) {
        if (error) { callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            NSArray *rewards = [response objectForKey:@"rewards"];
            GMReward *reward = [[GMReward alloc] initWithDictionary:[rewards objectAtIndex:0]];
            callback (nil, reward);
        }
    }];
}

- (void) loadClaim:(NSNumber *) claimID callback:(void (^) (NSError *error, GMClaim *claim)) callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                claimID, @"claim_id", nil];
    [self invokeTarget:@"claims.json" parameters:parameters callback:^(NSError *error, id result) {
        if (error) { callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            NSArray *claims = [response objectForKey:@"claims"];
            GMClaim *claim = [[GMClaim alloc] initWithDictionary:[claims objectAtIndex:0]];
            callback (nil, claim);
        }
    }];
}

- (void) loadEventsCallback:(void (^) (NSError *error, NSArray *events)) callback
{
    [self invokeTarget:@"events.json" parameters:nil callback:^(NSError *error, id result) {
        if (error) { callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            NSArray *eventsDict = [response objectForKey:@"events"];
            NSMutableArray *eventsTemp = [NSMutableArray arrayWithCapacity:[eventsDict count]];
            for (NSDictionary *eventDict in eventsDict) {
                GMEvent *event = [[GMEvent alloc] initWithDictionary:eventDict];
                [eventsTemp addObject:event];
            }
            
            callback (nil, [NSArray arrayWithArray:eventsTemp]);
        }
    }];
}

- (void) loadEvents:(NSArray *) eventIDs Callback:(void (^) (NSError *error, NSArray *events)) callback
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [eventIDs componentsJoinedByString:@","], @"event_id", nil];
    [self invokeTarget:@"events.json" parameters:parameters callback:^(NSError *error, id result) {
        if (error) { callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            NSArray *eventsDict = [response objectForKey:@"events"];
            NSMutableArray *eventsTemp = [NSMutableArray arrayWithCapacity:[eventsDict count]];
            for (NSDictionary *eventDict in eventsDict) {
                GMEvent *event = [[GMEvent alloc] initWithDictionary:eventDict];
                [eventsTemp addObject:event];
            }
            
            callback (nil, [NSArray arrayWithArray:eventsTemp]);
        }
    }];
}

- (void) loadRecentActionsCallback:(void (^) (NSError *error, NSArray *actions)) callback
{
    [self invokeTarget:@"recent_actions.json" parameters:nil callback:^(NSError *error, id result) {
        if (error) { callback(error, nil); }
        else {
            NSDictionary *response = [result objectForKey:@"response"];
            NSArray *activitiesDict = [response objectForKey:@"recent_actions"];
            NSMutableArray *activitiesTemp = [NSMutableArray arrayWithCapacity:[activitiesDict count]];
            for (NSDictionary *activityDict in activitiesDict) {
                GMRecentAction *activity = [[GMRecentAction alloc] initWithDictionary:activityDict];
                if (activity.action.type != GMActionTypeUnknown) {
                    [activitiesTemp addObject:activity];
                }
            }
            
            callback (nil, [NSArray arrayWithArray:activitiesTemp]);
        }
    }];
}

- (void) loadBadgesRecipeWithProgress:(BOOL)showProgress
                             callback:(void (^) (NSError *error, NSArray *categories)) callback
{
    NSDictionary *parameters = @{};
    if (showProgress) {
        parameters = @{ @"progress": @1 };
    }
    
    [self invokeTarget:@"badges.json" parameters:parameters callback:^(NSError *error, NSDictionary *result) {
        if (error) { callback(error, nil); }
        else {
            NSMutableArray *categories = [NSMutableArray array];
            NSDictionary *response = [result objectForKey:@"response"];
            NSDictionary *badges = [response objectForKey:@"badges"];
            for (NSString *name in badges.allKeys) {
                NSArray *tiers = [badges objectForKey:name];
                GMBadgeCategory *category = [[GMBadgeCategory alloc] initWithName:name andTiers:tiers];
                [categories addObject:category];
            }
            callback(nil, categories);
        }
    }];
}

- (void) top20For:(NSString *)type
         callback:(void (^) (NSError *error, NSArray *topPlayers)) callback
{
    NSString *target = [NSString stringWithFormat:@"top20%@.json", type];
    [self invokeTarget:target parameters:nil callback:^(NSError *error, NSDictionary *output) {
        NSDictionary *response = [output objectForKey:@"response"];
        NSArray *playerArray  = [response objectForKey:@"players"];
        NSMutableArray *playersTemp = [NSMutableArray arrayWithCapacity:[playerArray count]];
        for (NSDictionary *dictionary in playerArray) {
            GMTopPlayer *topPlayer = [[GMTopPlayer alloc] initWithDictionary:dictionary];
            [playersTemp addObject:topPlayer];
        }
        callback (nil, [NSArray arrayWithArray:playersTemp]);
    }];
}

- (void) _loginWithOptionalGuestUser:(NSString *) user
{
    NSDictionary *parameter = nil;
    if (user) {
        parameter = @{ @"old_uid": user };
    }
    
    [self invokeTarget:@"login.json" parameters:parameter callback:^(NSError *error, NSDictionary *output) {
        if (error) NSLog(@"Gimmie error: %@", error);
    }];
}

#pragma mark - Network operation
- (void) invokeTarget:(NSString *) target
           parameters:(NSDictionary *) parameters
             callback:(void (^)(NSError *error, NSDictionary *output))callback;
{
    [self invokeTarget:target parameters:parameters headers:nil queue:networkQueue callback:callback];
}

- (void) invokeTarget:(NSString *)target
           parameters:(NSDictionary *)parameters
              headers:(NSDictionary *) headers
             callback:(void (^)(NSError *, NSDictionary *))callback
{
    [self invokeTarget:target parameters:parameters headers:headers queue:networkQueue callback:callback];
}

- (void) invokeTarget:(NSString *) target
           parameters:(NSDictionary *) parameters
              headers:(NSDictionary *) headers
                queue:(NSOperationQueue *) queue
             callback:(void (^)(NSError *error, NSDictionary *output))callback
{
    NSMutableDictionary *_mixinInformationDictionary = [parameters mutableCopy];
    if (!_mixinInformationDictionary) {
        _mixinInformationDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    if ([self.locale stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [_mixinInformationDictionary setObject:self.locale forKey:@"locale"];
    }
    
    // Universal version tracker for #88
    [_mixinInformationDictionary setObject:SDK_VERSION forKey:@"ua"];
    
    GMNetworkOperation *operation = [operationTemplate copy];
    operation.target = target;
    operation.parameters = _mixinInformationDictionary;
    operation.headers = headers;
    operation.user = _user;
    operation.callback = callback;
    [queue addOperation:operation];
}

+ (NSString *) imageURLFromPath:(NSString *)path
{
    if ([path hasPrefix:@"//"]) return [NSString stringWithFormat:@"http:%@", path];
    else if ([path hasPrefix:@"/"]) return [NSString stringWithFormat:@"http://api.lvh.me:3000%@", path];
    return path;
}

@end
