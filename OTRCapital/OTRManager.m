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

#define TAG_SPINNER_VIEW    99
#define ORT_CUSTOMER_DATA_FILE_NAME         @"otr_customer_data"

@interface OTRManager()

@property int documentCount;
@property (nonatomic, retain) NSString* currentDocumentFolder;
@property (nonatomic,retain) NSMutableDictionary *otrInfo;
@property (nonatomic, retain) NSMutableDictionary *brokerInfo;
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
        self.brokerInfo = [NSMutableDictionary new];
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

- (void)setDelegate:(id<OTRManagerDelegate>)delegate {
    _delegate = delegate;
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

- (void) infoSendCallbackWithStatus: (BOOL)isSuccess{
    if (isSuccess) {
        [self onOTRRequestSuccessWithData:nil];
    }
    else {
        [self onOTRRequestFailWithError:nil];
    }
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

- (NSArray *) getBrokersList{
    NSArray *brokerList = [self.brokerInfo allKeys];
    return brokerList;
}

- (void) cacheUIImage: (UIImage*)image withKey:(NSString*)key{
    [self.imageCache setObject:image forKey:key];
}
- (UIImage*) getUIImageForKey: (NSString*) key{
    return [self.imageCache objectForKey:key];
}

- (UIActivityIndicatorView*) getSpinnerViewWithPosition:(CGPoint)centerPoint{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(centerPoint.x - 25, centerPoint.y - 25, 50, 50)];
    spinner.color = [UIColor blueColor];
    [spinner startAnimating];
    [spinner setTag:TAG_SPINNER_VIEW];
    return spinner;
}
- (void) removeSpinnerViewFromView:(UIView *)view{
    [[view viewWithTag:TAG_SPINNER_VIEW] removeFromSuperview];
}

- (UIView*) getSpinnerViewBlockerWithPosition: (CGPoint) centerPoint{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIView* baseView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [baseView setBackgroundColor:[UIColor blackColor]];
    baseView.userInteractionEnabled = YES;
    baseView.alpha = 0.5;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(centerPoint.x - 25, centerPoint.y - 25, 50, 50)];
    spinner.color = [UIColor blueColor];
    [spinner startAnimating];
    
    [baseView setTag:TAG_SPINNER_VIEW];
    [baseView addSubview:spinner];
    
    return baseView;
}
- (void) removeSpinnerViewBlockerFromView: (UIView*)view{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [[view viewWithTag:TAG_SPINNER_VIEW] removeFromSuperview];
}

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


- (void) sendDataToServer: (NSDictionary *)otrInfo withPDF: (NSData *)pdfData{
#ifdef DEBUG
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"doc.pdf"];
        [pdfData writeToFile:dataPath atomically:YES];
    });
#endif
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *mcn = [otrInfo objectForKey:KEY_MC_NUMBER];
    NSString *loadNumber = [otrInfo objectForKey:KEY_LOAD_NO];
    NSString *invoiceAmount = [otrInfo objectForKey:KEY_INVOICE_AMOUNT];
    NSNumber *pKey = [otrInfo objectForKey:KEY_PKEY];
    NSString *advReqAmount = [otrInfo objectForKey:KEY_ADV_REQ_AMOUT];
    NSString *textComcheckPhoneNumber = [otrInfo objectForKey:KEY_TEXT_COMCHECK_PHONE_NUMBER];
    
    NSMutableDictionary *apiInvoiceDataJson = [NSMutableDictionary new];
    
    [apiInvoiceDataJson setObject:mcn forKey:@"CustomerMCNumber"];
    [apiInvoiceDataJson setObject:loadNumber forKey:@"PoNumber"];
    [apiInvoiceDataJson setObject:pKey forKey:@"CustomerPKey"];
    [apiInvoiceDataJson setObject:invoiceAmount forKey:@"InvoiceAmount"];
    [apiInvoiceDataJson setObject:[OTRDefaults getUserName] forKey:@"ClientLogin"];
    [apiInvoiceDataJson setObject:[OTRDefaults getPasswrodEncoded] forKey:@"ClientPassword"];
    [apiInvoiceDataJson setObject:[otrInfo objectForKey:KEY_ADVANCED_REQUEST_TYPE] forKey:KEY_ADVANCED_REQUEST_TYPE];
    if (textComcheckPhoneNumber != nil) {
        [apiInvoiceDataJson setObject:textComcheckPhoneNumber forKey:KEY_TEXT_COMCHECK_PHONE_NUMBER];
    }
    
    if (advReqAmount) {
        [apiInvoiceDataJson setObject:advReqAmount forKey:@"AdvanceRequestAmount"];
    }
    
    NSString *invioceString = [apiInvoiceDataJson jsonStringWithPrettyPrint:false];
    
    [params setObject:invioceString forKey:@"apiInvoiceDataJson"];
    
    NSArray *docTypes = [otrInfo objectForKey:KEY_DOC_PROPERTY_TYPES_LIST];
    [params setObject:docTypes forKey:@"DocumentType"];
    [params setObject:@"iOS" forKey:@"mType"];
    
    NSString *factorType = [otrInfo objectForKey:KEY_FACTOR_TYPE];
    
    if (!factorType) {
        factorType = @"N/A";
    }
    
    [params setObject:factorType forKey:@"FactorType"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
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
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        DLog(@"Request Send Successfully");
    }
    
}

- (void) findBrokerInfoByPkey: (NSString *) pKey{
    NSString *url = [NSString stringWithFormat:@"%@api/BrokerCheck/%@/%@/%@",OTR_SERVER_BASE_URL,[OTRDefaults getUserName], [OTRDefaults getPasswrodEncoded], pKey];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    [self appendAuthInfoToRequestTypeGet:request];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) {
        DLog(@"Request Send Successfully");
    }

}

- (void) saveCustomerDataDictionary: (NSDictionary*) data{
    if (![data count]) {
        return;
    }
    [self.brokerInfo setValuesForKeysWithDictionary:data];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:ORT_CUSTOMER_DATA_FILE_NAME];
    [self.brokerInfo writeToFile:filePath atomically:YES];
}
- (void) loadCustomerDataDictionary{
    if ([self.brokerInfo count]) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:ORT_CUSTOMER_DATA_FILE_NAME];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if(data) self.brokerInfo = [data mutableCopy];
}

- (NSString *) getMCNumberByBrokerName: (NSString*)brokerName{
    NSDictionary *otrInfoObj = [self.brokerInfo objectForKey:brokerName];
    NSString *mcNumber = [otrInfoObj objectForKey:KEY_OTR_RESPONSE_MC_NUMBER];
    return mcNumber ? mcNumber : @"";
}

- (NSString *) getPKeyByBrokerName: (NSString*)brokerName{
    NSDictionary *otrInfoObj = [self.brokerInfo objectForKey:brokerName];
    DLog(@"%@", [NSString stringWithFormat: @"MCNumber: %@", [otrInfoObj objectForKey:KEY_OTR_RESPONSE_MC_NUMBER]]);
    NSString *pKey = [otrInfoObj objectForKey:KEY_OTR_RESPONSE_PKEY];
    return pKey;
}

- (NSString *) getPkeyByMCNumber: (NSString*)mcNumber{
    NSArray *otrInfo = [self.brokerInfo allValues];
    NSString *pKey = nil;
    for (NSDictionary *otrInfoObj in otrInfo) {
        NSString *mcn = [otrInfoObj objectForKey:KEY_OTR_RESPONSE_MC_NUMBER];
        if ([mcn isEqualToString:mcNumber]) {
            pKey = [otrInfoObj objectForKey:KEY_OTR_RESPONSE_PKEY];
            break;
        }
    }
    return pKey;
}

#pragma mark DELTEGATE METHODS
- (void) onOTRRequestSuccessWithData: (NSDictionary *)data{
    if ([self.delegate respondsToSelector:@selector(onOTRRequestSuccessWithData:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate onOTRRequestSuccessWithData:data];
        });
    }
}
- (void) onOTRRequestFailWithError: (NSString *)error;{
    if ([self.delegate respondsToSelector:@selector(onOTRRequestFailWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate onOTRRequestFailWithError:error];
        });
    }
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

@implementation NSDictionary (OTRJSONString)

-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        DLog(@"%@", [NSString stringWithFormat: @"jsonStringWithPrettyPrint: error: %@", error.localizedDescription]);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@implementation NSArray (OTRJSONString)
-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        DLog(@"%@", [NSString stringWithFormat: @"jsonStringWithPrettyPrint: error: %@", error.localizedDescription]);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
