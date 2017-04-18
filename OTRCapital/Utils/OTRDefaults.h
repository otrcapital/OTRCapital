//
//  OTRDefaults.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 07.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_LOGIN_USER_NAME                     @"user_name"
#define KEY_LOGIN_PASSWORD                      @"password"
#define KEY_OTR_INFO                            @"otr_info"
#define KEY_FACTOR_TYPE                         @"factor_type"
#define KEY_OTR_INFO_STATUS                     @"info_status"
#define DATA_TYPE_LOAD_FACTOR                   @"FAC"
#define DATA_TYPE_ADVANCE_LOAN                  @"ADV"
#define KEY_BROKER_NAME                         @"broker_name"
#define KEY_LOAD_NO                             @"load_no"
#define KEY_TOTAL_PAY                           @"total_pay"
#define KEY_TOTAL_DEDUCTION                     @"total_deduction"
#define KEY_ADV_REQ_AMOUT                       @"adv_req_amount"
#define KEY_INVOICE_AMOUNT                      @"invoiceAmount"
#define KEY_MC_NUMBER                           @"mc_number"
#define KEY_PKEY                                @"PKey"
#define KEY_ADVANCED_REQUEST_TYPE               @"AdvanceRequestType"
#define KEY_TEXT_COMCHECK_PHONE_NUMBER          @"Phone"
#define KEY_DOC_PROPERTY_DELIVERY_PROOF         @"delivery_proof"
#define KEY_DOC_PROPERTY_LANING_BILL            @"landing_bill"
#define KEY_DOC_PROPERTY_FREIGHT_BILL           @"freight_bill"
#define KEY_DOC_PROPERTY_LOG                    @"property_log"
#define KEY_DOC_PROPERTY_FUEL_RECEIPT           @"fuel_receipt"
#define KEY_DOC_PROPERTY_SCALE_RECEIPT          @"scale_receipt"
#define KEY_DOC_PROPERTY_INVOICE                @"invoice"
#define KEY_DOC_PROPERTY_TYPES_LIST             @"doc_types_list"
#define KEY_OTR_RECORD_FETCH_DATE               @"otr_record_fetch_date"

@interface OTRDefaults : NSObject

+ (void)saveString:(NSString *)value forKey:(NSString *)key;
+ (NSString*)getStringForKey:(NSString*)key;
+ (NSString*)getUserName;
+ (NSString*)getPasswrodEncoded;
+ (NSString*)getPasswordDecoded;

+ (void)saveRecordFetchDate;

@end
