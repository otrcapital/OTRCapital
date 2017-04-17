//
//  OTRApi.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 07.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OTR_SERVER_URL @"customer.otrcapital.com"

#define OTR_SERVER_BASE_URL @"http://" OTR_SERVER_URL @"/"

@class OTRDocument;

typedef void(^OTRAPICompletionBlock)(NSDictionary* responseData, NSError *error);

@interface OTRApi : NSObject

+ (id)instance;

+ (BOOL)hasConnection;

- (void)loginWithUsername: (NSString*)username encodedPassword: (NSString*)password completionBlock:(OTRAPICompletionBlock)block;

- (void)loginWithUsername: (NSString*)username andPassword: (NSString*)password completionBlock:(OTRAPICompletionBlock)block;

- (void)fetchCustomerDetails:(NSString *)lastFetchDate withCompletion:(OTRAPICompletionBlock)block;

- (void)sendDataToServer:(OTRDocument *)document withPDF:(NSData *)pdfData completionBlock:(OTRAPICompletionBlock)block;

- (void)findBrokerInfoByPkey:(NSString *)pKey completionBlock:(OTRAPICompletionBlock)block;

@end
