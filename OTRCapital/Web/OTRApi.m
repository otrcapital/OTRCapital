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
#import "NSArray+OTRJSONString.h"
#import "NSDictionary+OTRJSONString.h"
#import "OTRDocument.h"

static const NSInteger mTimeOutInterval = 30;
static const NSInteger mTimeOutIntervalPost = 60;

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
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:mTimeOutInterval];
    
    [self appendAuthInfoToRequestTypeGet:request];
    [self sendRequest:request completionBlock:block];
}


- (void)fetchCustomerDetails:(NSString *)lastFetchDate withCompletion:(OTRAPICompletionBlock)block {
    NSString *url = [NSString stringWithFormat:@"%@api/GetCustomers/%@",OTR_SERVER_BASE_URL, lastFetchDate];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:mTimeOutInterval];
    
    [self appendAuthInfoToRequestTypeGet:request];
    [self sendRequest:request completionBlock:block];
}


- (void)sendDataToServer:(OTRDocument *)document withPDF:(NSData *)pdfData completionBlock:(OTRAPICompletionBlock)block {
#ifdef DEBUG
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"doc.pdf"];
        [pdfData writeToFile:dataPath atomically:YES];
    });
#endif
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *mcn = document.broker_mc_number;
    NSString *loadNumber = document.loadNumber;
    NSString *invoiceAmount = document.invoiceAmount;
    NSNumber *pKey = document.broker_pkey;
    NSString *advReqAmount = document.adv_req_amount ?: @"";
    NSString *textComcheckPhoneNumber = document.customerPhoneNumber;
    
    NSMutableDictionary *apiInvoiceDataJson = [NSMutableDictionary new];
    
    [apiInvoiceDataJson setObject:mcn forKey:@"CustomerMCNumber"];
    [apiInvoiceDataJson setObject:loadNumber forKey:@"PoNumber"];
    [apiInvoiceDataJson setObject:pKey forKey:@"CustomerPKey"];
    [apiInvoiceDataJson setObject:invoiceAmount forKey:@"InvoiceAmount"];
    [apiInvoiceDataJson setObject:[OTRDefaults getUserName] forKey:@"ClientLogin"];
    [apiInvoiceDataJson setObject:[OTRDefaults getPasswrodEncoded] forKey:@"ClientPassword"];
    [apiInvoiceDataJson setObject:document.advanceRequestType forKey:KEY_ADVANCED_REQUEST_TYPE];
    if (textComcheckPhoneNumber != nil) {
        [apiInvoiceDataJson setObject:textComcheckPhoneNumber forKey:KEY_TEXT_COMCHECK_PHONE_NUMBER];
    }
    
    if (advReqAmount && [advReqAmount length] > 0) {
        [apiInvoiceDataJson setObject:advReqAmount forKey:@"AdvanceRequestAmount"];
    }
    
    NSString *invioceString = [apiInvoiceDataJson jsonStringWithPrettyPrint:false];
    
    [params setObject:invioceString forKey:@"apiInvoiceDataJson"];
    
    NSArray *docTypes = document.documentTypes;
    [params setObject:docTypes forKey:@"DocumentType"];
    [params setObject:@"iOS" forKey:@"mType"];
    [params setObject:document.factorType forKey:@"FactorType"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:mTimeOutIntervalPost];
    [self appendAuthInfoToRequestTypePost:request];
    
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (pdfData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"doc.pdf\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type:application/pdf\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:pdfData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    NSString *url = [NSString stringWithFormat:@"%@%@", OTR_SERVER_BASE_URL, @"api/Upload"];
    [request setURL:[NSURL URLWithString:url]];
    
    [self sendRequest:request completionBlock:block];
}


- (void)findBrokerInfoByPkey:(NSString *)pKey completionBlock:(OTRAPICompletionBlock)block {
    NSString *url = [NSString stringWithFormat:@"%@api/BrokerCheck/%@/%@/%@",OTR_SERVER_BASE_URL,[OTRDefaults getUserName], [OTRDefaults getPasswrodEncoded], pKey];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:mTimeOutInterval];
    
    [self appendAuthInfoToRequestTypeGet:request];
    [self sendRequest:request completionBlock:block];
}


#pragma mark - URLRequest methods


- (void)sendRequest:(NSURLRequest *)request completionBlock:(OTRAPICompletionBlock)block {
    __block OTRApi *blockedSelf = self;
    __block NSURLRequest *blockedRequest = request;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               if(!error) {
                                   [blockedSelf connectionFinished:data requestInfo:blockedRequest statusCode:[httpResponse statusCode] completionBlock:block];
                               }else {
                                   DLog(@"HTTP Request Failed");
                                   [[CrashlyticsManager sharedManager]logException:error];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if(block) block(nil, error);
                                   });
                               }
                           }];
}


- (void)connectionFinished:(NSData *)data requestInfo:(NSURLRequest *)request statusCode:(NSInteger)statusCode completionBlock:(OTRAPICompletionBlock)block {
    if (statusCode == 200) {
        if(!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block) block([NSDictionary new], nil);
                if(request) {
                    NSString* errorString = [NSString stringWithFormat:@"Warning! Empty server response body. Url = %@", request.URL.absoluteString];
                    NSDictionary *userInfo = @{
                                               NSLocalizedDescriptionKey: errorString,
                                               NSLocalizedFailureReasonErrorKey: errorString
                                               };
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:userInfo];
                    [[CrashlyticsManager sharedManager] logException:error];
                }
            });
            return;
        }
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([responseString hasPrefix:@"\""]) {
            responseString = [responseString substringFromIndex: 1];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block) block(json, nil);
            });
            return;
        }
    }
    NSString* errorString = @"Unknown Server Error, kindly contect OTR Capital for assitanace.";
    if (data){
        errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    if(errorString.length > 0) {
        if([[errorString substringToIndex:1] isEqualToString:@"\""]) errorString = [errorString substringFromIndex:1];
        if([[errorString substringFromIndex:errorString.length - 1] isEqualToString:@"\""]) errorString = [errorString substringToIndex:errorString.length - 1];
    }
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: errorString,
                               NSLocalizedFailureReasonErrorKey: errorString
                               };
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:userInfo];
    [[CrashlyticsManager sharedManager] logException:error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(block) block(nil, error);
    });
}



#pragma mark - Inner Functions


- (void)appendAuthInfoToRequestTypeGet: (NSMutableURLRequest*)request{
    [request setHTTPMethod:@"GET"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [OTRDefaults getUserName], [OTRDefaults getPasswordDecoded]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"Fiddler" forHTTPHeaderField:@"User-Agent"];
    [request setValue:OTR_SERVER_URL forHTTPHeaderField:@"Host"];
}


- (void)appendAuthInfoToRequestTypePost: (NSMutableURLRequest*)request{
    [request setHTTPMethod:@"POST"];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [OTRDefaults getUserName], [OTRDefaults getPasswordDecoded]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"Fiddler" forHTTPHeaderField:@"User-Agent"];
    [request setValue:OTR_SERVER_URL forHTTPHeaderField:@"Host"];
}

@end
