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

@protocol OTRManagerDelegate <NSObject, NSURLConnectionDelegate>

@required
- (void) onOTRRequestSuccessWithData: (NSDictionary *)data;
- (void) onOTRRequestFailWithError: (NSString *)error;

@end

@interface OTRManager : NSObject

@property (nonatomic, weak) id<OTRManagerDelegate> delegate;

+ (id)sharedManager;

- (NSString *) saveImage: (UIImage *)image atPath:(NSString *)path;
- (void) updateOTRInfo: (NSDictionary *)otrInfo forKey: (NSString*)key;

- (NSData *) makePDFOfImagesOfFolder: (NSString*)folderName;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

- (void) deleteFolderAtPath: (NSString *)path;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
