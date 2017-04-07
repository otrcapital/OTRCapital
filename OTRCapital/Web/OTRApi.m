//
//  OTRApi.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 07.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRApi.h"
#import "OTRDefaults.h"
#import "CrashlyticsManager.h"
#import "Reachability.h"

@interface OTRApi()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation OTRApi

+ (id)instance {
    static OTRApi *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if([super init]) {
        self.queue = [NSOperationQueue new];
    }
    return self;
}


#pragma mark - Public methods


+ (BOOL)hasConnection {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)loginWithUsername: (NSString*)username andPassword: (NSString*)password completionBlock:(OTRAPICompletionBlock)block {
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedPassword = [NSString stringWithFormat:@"%@", [passwordData base64EncodedStringWithOptions:0]];
    [self loginWithUsername:username encodedPassword:encodedPassword completionBlock:block];
}

- (void)loginWithUsername: (NSString*)username encodedPassword: (NSString*)password completionBlock:(OTRAPICompletionBlock)block {
    [OTRDefaults saveString:username forKey:KEY_LOGIN_USER_NAME];
    [OTRDefaults saveString:password forKey:KEY_LOGIN_PASSWORD];
    
    NSString *url = [NSString stringWithFormat:@"%@api/GetClientInfo/%@/%@", OTR_SERVER_BASE_URL, username, password];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    [self appendAuthInfoToRequestTypeGet:request];
    [self sendRequest:request completionBlock:block];
}

- (void)fetchCustomerDetails:(NSString *)lastFetchDate withCompletion:(OTRAPICompletionBlock)block {
    NSString *url = [NSString stringWithFormat:@"%@api/GetCustomers/%@",OTR_SERVER_BASE_URL, lastFetchDate];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    [self appendAuthInfoToRequestTypeGet:request];
    [self sendRequest:request completionBlock:block];
}


#pragma mark - URLRequest methods


- (void)sendRequest:(NSURLRequest *)request completionBlock:(OTRAPICompletionBlock)block {
    __block OTRApi *blockedSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               if(!error) {
                                   [blockedSelf connectionFinished:data statusCode:[httpResponse statusCode] completionBlock:block];
                               }else {
                                   DLog(@"HTTP Request Failed");
                                   [[CrashlyticsManager sharedManager]logException:error];
                                   
                                   if(block) block(nil, error);
                               }
                           }];
}

- (void)connectionFinished:(NSData *)data statusCode:(NSInteger)statusCode completionBlock:(OTRAPICompletionBlock)block {
    if (data && statusCode == 200) {
        NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([responseString hasPrefix:@"\""]) {
            responseString = [responseString substringFromIndex:1];
            responseString = [responseString substringToIndex:responseString.length - 1];
        }
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        DLog(@"%@", [NSString stringWithFormat:@"Response String: %@", responseString]);
        if ([responseString hasPrefix:@"["]) {
            responseString = [NSString stringWithFormat:@"{\"data\":%@}", responseString];
        }
        
        NSError *jsonError;
        NSData *objectData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if(!jsonError) {
            if(block) block(json, nil);
            return;
        }
    }
    NSString* errorString = @"Unknown Server Error, kindly contect OTR Capital for assitanace.";
    if (data){
        errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: errorString,
                               NSLocalizedFailureReasonErrorKey: errorString
                               };
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:userInfo];
    [[CrashlyticsManager sharedManager]logException:error];
    
    if(block) block(nil, error);
}


#pragma mark - Inner Functions


- (void) appendAuthInfoToRequestTypeGet: (NSMutableURLRequest*)request{
    [request setHTTPMethod:@"GET"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [OTRDefaults getUserName], [OTRDefaults getPasswordDecoded]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"Fiddler" forHTTPHeaderField:@"User-Agent"];
    [request setValue:OTR_SERVER_URL forHTTPHeaderField:@"Host"];
}

- (void) appendAuthInfoToRequestTypePost: (NSMutableURLRequest*)request{
    [request setHTTPMethod:@"POST"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [OTRDefaults getUserName], [OTRDefaults getPasswordDecoded]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"Fiddler" forHTTPHeaderField:@"User-Agent"];
    [request setValue:OTR_SERVER_URL forHTTPHeaderField:@"Host"];
}


@end
