//
//  OTRApi.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 07.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if (OTR_BUILD_TYPE == 1)
#define OTR_SERVER_URL  @"mobileportal.otrcapital.com"
#else
#define OTR_SERVER_URL @"customer.otrcapital.com"
#endif

#define OTR_SERVER_BASE_URL @"http://" OTR_SERVER_URL @"/"

typedef void(^OTRAPICompletionBlock)(NSDictionary* responseData, NSError *error);

@interface OTRApi : NSObject

+ (id)instance;

+ (BOOL)hasConnection;

- (void)loginWithUsername: (NSString*)username encodedPassword: (NSString*)password completionBlock:(OTRAPICompletionBlock)block;

- (void)loginWithUsername: (NSString*)username andPassword: (NSString*)password completionBlock:(OTRAPICompletionBlock)block;

- (void)fetchCustomerDetails:(NSString *)lastFetchDate withCompletion:(OTRAPICompletionBlock)block;

- (void)sendDataToServer: (NSDictionary *)otrInfo withPDF: (NSData *)pdfData completionBlock:(OTRAPICompletionBlock)block;

- (void)findBrokerInfoByPkey:(NSString *)pKey completionBlock:(OTRAPICompletionBlock)block;

@end
