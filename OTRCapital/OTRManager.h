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

@interface OTRManager : NSObject

+ (id)sharedManager;

- (void) initOTRInfo;
- (NSDictionary*) getOTRInfo;

- (void) setOTRInfoValueOfTypeData: (NSData *)value forKey: (NSString*)key;
- (void) setOTRInfoValueOfTypeString: (NSString *)value forKey: (NSString*)key;
- (void) setOTRInfoValueOfTypeArray: (NSArray *)value forKey: (NSString*)key;
- (void) setOTRInfoValueOfTypeDouble: (double)value forKey: (NSString*)key;

- (void) saveImage: (UIImage *)image;
- (void) saveOTRInfo;
- (void) setCurrentOTRInfo:(NSDictionary *)info;
- (void) saveToFuelAdvanceOrPrebuildInfoList;
- (void) updateOTRInfo: (NSDictionary *)otrInfo forKey: (NSString*)key;
- (NSDictionary *) getOtrInfoWithKey: (NSString *)key;
- (NSArray *) getFuelAdvanceOrPrebuildInfoList;

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

- (void) cacheUIImage: (UIImage*)image withKey:(NSString*)key;
- (UIImage*) getUIImageForKey: (NSString*) key;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
