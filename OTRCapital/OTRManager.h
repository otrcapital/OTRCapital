//
//  OTRManager.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_LOGIN_USER_NAME                     @"user_name"
#define KEY_LOGIN_PASSWORD                      @"password"
#define KEY_OTR_INFO                            @"otr_info"
#define KEY_FACTOR_TYPE                         @"factor_type"
#define KEY_OTR_INFO_STATUS                     @"info_status"
#define OTR_INFO_STATUS_SUCCESS                 @"success"
#define OTR_INFO_STATUS_FAILED                  @"failed"
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
#define KEY_IMAGE_FILE_NAME                     @"image_name"
#define KEY_DOC_PROPERTY_DELIVERY_PROOF         @"delivery_proof"
#define KEY_DOC_PROPERTY_LANING_BILL            @"landing_bill"
#define KEY_DOC_PROPERTY_FREIGHT_BILL           @"freight_bill"
#define KEY_DOC_PROPERTY_LOG                    @"property_log"
#define KEY_DOC_PROPERTY_FUEL_RECEIPT           @"fuel_receipt"
#define KEY_DOC_PROPERTY_SCALE_RECEIPT          @"scale_receipt"
#define KEY_DOC_PROPERTY_INVOICE                @"invoice"
#define KEY_DOC_PROPERTY_TYPES_LIST             @"doc_types_list"
#define KEY_OTR_RESPONSE_TYPE                   @"otr_response_key"
#define KEY_OTR_RESPONSE_BROKER_NAME            @"Name"
#define KEY_OTR_RESPONSE_MC_NUMBER              @"McNumber"
#define KEY_OTR_RESPONSE_PKEY                   @"PKey"

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]
#define IMAGE_SIZE CGSizeMake(595, 842)
#define OTR_CONTACT_NO                          @"tel:7708820124"
#define OTR_BROKER_INFO_FETCH_DEFAULT_DATE      @"2015/10/18"

#define OTR_BUILD_TYPE      2

#if (OTR_BUILD_TYPE == 1)
#define OTR_SERVER_URL  @"mobileportal.otrcapital.com"
#else
#define OTR_SERVER_URL @"customer.otrcapital.com"
//#define OTR_SERVER_URL @"stgportal.otrcapital.com"
#endif

#define OTR_SERVER_BASE_URL @"http://" OTR_SERVER_URL @"/"

@protocol OTRManagerDelegate <NSObject, NSURLConnectionDelegate>

@required
- (void) onOTRRequestSuccessWithData: (NSDictionary *)data;
- (void) onOTRRequestFailWithError: (NSString *)error;

@end

@interface OTRManager : NSObject

@property (nonatomic, weak) id<OTRManagerDelegate> delegate;

+ (id)sharedManager;

- (void) initOTRInfo;
- (NSDictionary*) getOTRInfo;

- (NSString*) getUserName;

- (void) setOTRInfoValueOfTypeData: (NSData *)value forKey: (NSString*)key;
- (void) setOTRInfoValueOfTypeString: (NSString *)value forKey: (NSString*)key;
- (void) setOTRInfoValueOfTypeArray: (NSArray *)value forKey: (NSString*)key;

- (void) saveImage: (UIImage *)image;
- (void) saveString: (NSString*)value withKey: (NSString*)key;
- (NSString*) getStringForKey: (NSString*)key;
- (void) removeObjectForKey: (NSString*)key;
- (void) saveOTRInfo;
- (void) updateOTRInfo: (NSDictionary *)otrInfo forKey: (NSString*)key;
- (NSDictionary *) getOtrInfoWithKey: (NSString *)key;

- (NSData *) getOTRInfoValueOfTypeDataForKey: (NSString*)key;
- (NSString *) getOTRInfoValueOfTypeStringForKey: (NSString*)key;
- (NSArray *) getOTRInfoValueOfTypeArrayForKey: (NSString*)key;

- (NSData *) makePDFOfCurrentImages;
- (NSData *) makePDFOfImagesOfFolder: (NSString*)folderName;
- (NSString *) getPDFFileName;

- (void) initDocumnetCount;
- (void) incrementDocumentCount;
- (int) getDocumentCount;
- (BOOL) isImageSavedOfCurrnetPath;
- (void) deleteCurrentFoler;
- (void) deleteFolderAtPath: (NSString *)path;
- (void) loginWithUserName: (NSString*)userName andEncodedPassword: (NSString*)password;
- (void) loginWithUserName: (NSString*)userName andPassword: (NSString*)password;

- (NSArray *) getBrokersList;

- (void) cacheUIImage: (UIImage*)image withKey:(NSString*)key;
- (UIImage*) getUIImageForKey: (NSString*) key;

- (UIActivityIndicatorView*) getSpinnerViewWithPosition: (CGPoint) centerPoint;
- (void) removeSpinnerViewFromView: (UIView*)view;

- (UIView*) getSpinnerViewBlockerWithPosition: (CGPoint) centerPoint;
- (void) removeSpinnerViewBlockerFromView: (UIView*)view;

- (void) sendDataToServer: (NSDictionary *)otrInfo withPDF: (NSData *)pdfData;
- (void) findBrokerInfoByPkey: (NSString *) pKey;
- (void) fetchCustomerDetail;

- (NSString*) getLastRecordsFetchDate;
- (void) saveRecordFetchDate;

- (void) saveCustomerDataDictionary: (NSDictionary*) data;
- (void) loadCustomerDataDictionary;

- (NSString *) getMCNumberByBrokerName: (NSString*)brokerName;
- (NSString *) getPKeyByBrokerName: (NSString*)brokerName;
- (NSString *) getPkeyByMCNumber: (NSString*)mcNumber;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (void) logDebug: (NSString*) msg;

@end

@interface NSDictionary (OTRJSONString)
-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@interface NSArray (OTRJSONString)
- (NSString *)jsonStringWithPrettyPrint:(BOOL)prettyPrint;
@end
