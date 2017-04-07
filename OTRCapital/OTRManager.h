//
//  OTRManager.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]
#define IMAGE_SIZE CGSizeMake(595, 842)
#define OTR_CONTACT_NO                          @"tel:7708820124"

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

- (void) setOTRInfoValueOfTypeData: (NSData *)value forKey: (NSString*)key;
- (void) setOTRInfoValueOfTypeString: (NSString *)value forKey: (NSString*)key;
- (void) setOTRInfoValueOfTypeArray: (NSArray *)value forKey: (NSString*)key;

- (void) saveImage: (UIImage *)image;
- (void) saveOTRInfo;
- (void) updateOTRInfo: (NSDictionary *)otrInfo forKey: (NSString*)key;
- (NSDictionary *) getOtrInfoWithKey: (NSString *)key;

- (NSData *) getOTRInfoValueOfTypeDataForKey: (NSString*)key;
- (NSString *) getOTRInfoValueOfTypeStringForKey: (NSString*)key;
- (NSArray *) getOTRInfoValueOfTypeArrayForKey: (NSString*)key;

- (NSData *) makePDFOfCurrentImages;
- (NSData *) makePDFOfImagesOfFolder: (NSString*)folderName;
- (NSString *) getPDFFileName;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

- (void) initDocumnetCount;
- (void) incrementDocumentCount;
- (int) getDocumentCount;
- (BOOL) isImageSavedOfCurrnetPath;
- (void) deleteCurrentFoler;
- (void) deleteFolderAtPath: (NSString *)path;


- (NSArray *) getBrokersList;

- (void) cacheUIImage: (UIImage*)image withKey:(NSString*)key;
- (UIImage*) getUIImageForKey: (NSString*) key;

- (UIActivityIndicatorView*) getSpinnerViewWithPosition: (CGPoint) centerPoint;
- (void) removeSpinnerViewFromView: (UIView*)view;

- (UIView*) getSpinnerViewBlockerWithPosition: (CGPoint) centerPoint;
- (void) removeSpinnerViewBlockerFromView: (UIView*)view;

- (void) sendDataToServer: (NSDictionary *)otrInfo withPDF: (NSData *)pdfData;
- (void) findBrokerInfoByPkey: (NSString *) pKey;


- (void) saveCustomerDataDictionary: (NSDictionary*) data;
- (void) loadCustomerDataDictionary;

- (NSString *) getMCNumberByBrokerName: (NSString*)brokerName;
- (NSString *) getPKeyByBrokerName: (NSString*)brokerName;
- (NSString *) getPkeyByMCNumber: (NSString*)mcNumber;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end

@interface NSDictionary (OTRJSONString)
-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@interface NSArray (OTRJSONString)
- (NSString *)jsonStringWithPrettyPrint:(BOOL)prettyPrint;
@end
