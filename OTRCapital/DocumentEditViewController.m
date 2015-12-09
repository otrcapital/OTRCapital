//
//  DocumentEditViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "DocumentEditViewController.h"
#import "ImageAdjustmentViewController.h"

@interface DocumentEditViewController ()

@property (nonatomic) UIImage *scannedImage;

@end

@implementation DocumentEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = @"EDIT DOCUMENT";
    if (self.scannedImage)
    {
        [[self imageView] setImage:[self scannedImage]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage*)imageByRotatingImage:(UIImage*)initImage toOrientation:(UIImageOrientation)orientation
{
    CGImageRef imgRef = initImage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;
    switch(orient) {
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (bounds.size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * bounds.size.height);
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imgRef);
    context = CGBitmapContextCreate (bitmapData,bounds.size.width,bounds.size.height,8,bitmapBytesPerRow,
                                     colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    if (context == NULL)
        return nil;
    
    CGContextScaleCTM(context, -1.0, -1.0);
    CGContextTranslateCTM(context, -bounds.size.width, -bounds.size.height);
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0,0,width, height), imgRef);
    
    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:initImage.scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef2);
    return image;
}

- (IBAction)onDoneButtonPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageAdjustmentViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ImageAdjustmentViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [vc setImage:[[self imageView] image]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onDiscardButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)onRotateLeftButtonPressed:(id)sender {
    
    UIImage *image = [[self imageView] image];
    UIImage *rotatedImage = [self imageByRotatingImage:image toOrientation:UIImageOrientationLeft];
    [[self imageView] setImage:rotatedImage];
}

- (IBAction)onRotateRightButtonPressed:(id)sender {
    UIImage *image = [[self imageView] image];
    UIImage *rotatedImage = [self imageByRotatingImage:image toOrientation:UIImageOrientationRight];
    [[self imageView] setImage:rotatedImage];
}

- (void) setImage: (UIImage *)pImage
{
    self.scannedImage = pImage;
}

@end
