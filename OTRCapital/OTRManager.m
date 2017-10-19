//
//  OTRManager.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTRManager.h"
#import <stdio.h>
#import "CrashlyticsManager.h"
#import "DBHelper.h"

#define fuelAdvanceListKey @"KEY_FUEL_ADVANCE_PREBUILD"

@interface OTRManager()

@property int documentCount;
@property (nonatomic, retain) NSString* currentDocumentFolder;
@property (nonatomic,retain) NSMutableDictionary *otrInfo;
@property (nonatomic, retain) NSMutableDictionary *imageCache;
@end

@implementation OTRManager

+ (id) sharedManager {
    static OTRManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id) init{
    if ([super init]) {
        self.imageCache = [NSMutableDictionary new];
    }
    return self;
}

- (void) initOTRInfo
{
    [self setOtrInfo: [NSMutableDictionary new]];
    [self initDocumnetCount];
    [self setCurrentDocumentFolder:TimeStamp];
    [self setOTRInfoValueOfTypeString:self.currentDocumentFolder forKey:KEY_IMAGE_FILE_NAME];
}

- (void) createDirectoryAtCurrentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:self.currentDocumentFolder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
}

- (NSDictionary*) getOTRInfo
{
    return self.otrInfo;
}

- (void) setOTRInfoValueOfTypeData: (NSData *)value forKey: (NSString*)key
{
    [self.otrInfo setObject:value forKey:key];
}
- (void) setOTRInfoValueOfTypeString: (NSString *)value forKey: (NSString*)key
{
    [self.otrInfo setObject:value forKey:key];
}
- (void) setOTRInfoValueOfTypeArray: (NSArray *)value forKey: (NSString*)key
{
    [self.otrInfo setObject:value forKey:key];
}

- (void) setOTRInfoValueOfTypeDouble: (double)value forKey: (NSString*)key
{
    [self.otrInfo setObject:[NSNumber numberWithDouble:value] forKey:key];
}

- (NSData *) getOTRInfoValueOfTypeDataForKey: (NSString*)key
{
    return [self.otrInfo objectForKey:key];
}
- (NSString *) getOTRInfoValueOfTypeStringForKey: (NSString*)key
{
    return [self.otrInfo objectForKey:key];
}
- (NSArray *) getOTRInfoValueOfTypeArrayForKey: (NSString*)key
{
    return [self.otrInfo objectForKey:key];
}

- (void) saveImage: (UIImage *)image
{
    [self createDirectoryAtCurrentPath];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagePath = [NSString stringWithFormat:@"%@/%d.jpeg", self.currentDocumentFolder, self.documentCount];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imagePath];
    [UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
}


- (void) removeObjectForKey: (NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
    [self deleteFolderAtPath:key];
}

- (void) saveOTRInfo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.otrInfo forKey:self.currentDocumentFolder];
    [defaults synchronize];
}
- (void) updateOTRInfo: (NSDictionary *)otrInfo forKey: (NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:otrInfo forKey:key];
    [defaults synchronize];
}


- (void) saveToFuelAdvanceOrPrebuildInfoList {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* dict = [defaults dictionaryForKey:fuelAdvanceListKey];
    NSMutableDictionary *mDict = dict ? [dict mutableCopy] : [NSMutableDictionary new];
    [mDict setValue:self.otrInfo forKey:self.currentDocumentFolder];
    
    [defaults setObject:mDict forKey:fuelAdvanceListKey];
    [defaults synchronize];
}

- (NSArray *) getFuelAdvanceOrPrebuildInfoList {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* dict = [defaults dictionaryForKey:fuelAdvanceListKey];
    NSMutableArray *mPrebuildInfoList = [NSMutableArray new];
    
    for (NSString *note in [dict allKeys]) {
        [mPrebuildInfoList addObject:dict[note]];
    }
    return mPrebuildInfoList;
}

- (NSDictionary *) getOtrInfoWithKey: (NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

- (NSData *) makePDFOfImagesOfFolder: (NSString*)folderName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    
    if (!directoryContent || !directoryContent.count) {
        return nil;
    }
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", directoryPath,[directoryContent objectAtIndex:0]];
    
    double pageWidth = IMAGE_SIZE.width;
    double pageHeight = IMAGE_SIZE.height;
    
    NSMutableData *pdfFile = [[NSMutableData alloc] init];
    CGDataConsumerRef pdfConsumer =
    CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfFile);
    CGRect mediaBox = CGRectMake(0, 0, pageWidth, pageHeight);
    CGContextRef pdfContext = CGPDFContextCreate(pdfConsumer, &mediaBox, NULL);
    
    for (int i = 0; i < directoryContent.count; i++) {
        
        imagePath = [NSString stringWithFormat:@"%@/%@", directoryPath,[directoryContent objectAtIndex:i]];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        
        NSData *jpgImageData = UIImageJPEGRepresentation(image, 0);
        image = [UIImage imageWithData:jpgImageData];
        mediaBox = CGRectMake(0, 0, pageHeight * (image.size.width / image.size.height), pageHeight);
        if(pageWidth < CGRectGetWidth(mediaBox)) {
            mediaBox.size.width = pageWidth;
            mediaBox.size.height = pageWidth * (image.size.height / image.size.width);
        }
        
        CGContextBeginPage(pdfContext, &mediaBox);
        
        switch (image.imageOrientation) {
            case UIImageOrientationDown:
                CGContextTranslateCTM(pdfContext, mediaBox.size.width, mediaBox.size.height);
                CGContextScaleCTM(pdfContext, -1, -1);
                break;
            case UIImageOrientationLeft:
                CGContextTranslateCTM(pdfContext, mediaBox.size.width, 0);
                CGContextRotateCTM(pdfContext, M_PI / 2);
                mediaBox.size.width = mediaBox.size.height;
                mediaBox.size.height = pageWidth;
                break;
            case UIImageOrientationRight:
                CGContextTranslateCTM(pdfContext, 0, mediaBox.size.height);
                CGContextRotateCTM(pdfContext, -M_PI / 2);
                mediaBox.size.width = mediaBox.size.height;
                mediaBox.size.height = pageWidth;
                break;
            case UIImageOrientationUp:
            default:
                break;
        }
        
        CGContextDrawImage(pdfContext, mediaBox, [image CGImage]);
        CGContextEndPage(pdfContext);
    }
    CGContextRelease(pdfContext);
    CGDataConsumerRelease(pdfConsumer);

    return pdfFile;

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    
    CGFloat ws = newSize.width / image.size.width;
    CGFloat hs = newSize.height / image.size.height;
    
    if (ws > hs) {
        ws = hs / ws;
        hs = 1.0;
    } else {
        hs = ws / hs;
        ws = 1.0;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, newSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(newSize.width / 2 - (newSize.width * ws) / 2,
                                           newSize.height / 2 - (newSize.height * hs) / 2, newSize.width * ws,
                                           newSize.height * hs), image.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(UIImage *)drawImageWithImage: (UIImage *)badge size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath* p = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,size.width,size.height)];
    [[UIColor whiteColor] setFill];
    [p fill];
    UIImage* im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(im.size, NO, 0.0f);
    [im drawInRect:CGRectMake(0, 0, im.size.width, im.size.height)];
    [badge drawInRect:CGRectMake(0, 0, badge.size.width, badge.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (NSData *) makePDFOfCurrentImages{
    return [self makePDFOfImagesOfFolder:self.currentDocumentFolder];
}

- (NSString *) getPDFFileName{
    return [NSString stringWithFormat:@"%@.pdf", self.currentDocumentFolder];
}

- (void) initDocumnetCount{
    self.documentCount = 1;
}
- (void) incrementDocumentCount{
    self.documentCount++;
}
- (int) getDocumentCount{
    return self.documentCount;
}
- (BOOL) isImageSavedOfCurrnetPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.currentDocumentFolder];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    
    if (!directoryContent || !directoryContent.count) {
        return NO;
    }
    return YES;
}
- (void) deleteFolderAtPath: (NSString *)path{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];

}

- (void) deleteCurrentFoler{
    [self deleteFolderAtPath:self.currentDocumentFolder];
}


- (void) cacheUIImage: (UIImage*)image withKey:(NSString*)key{
    [self.imageCache setObject:image forKey:key];
}
- (UIImage*) getUIImageForKey: (NSString*) key{
    return [self.imageCache objectForKey:key];
}


#pragma mark STATIC METHODS

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
