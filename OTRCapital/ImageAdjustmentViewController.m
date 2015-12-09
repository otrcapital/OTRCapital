//
//  ImageAdjustmentViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "ImageAdjustmentViewController.h"
#import "OTRManager.h"

@interface ImageAdjustmentViewController ()

@property (nonatomic) UIImage *editedImage;
@property (nonatomic) UIImage *adjustedImage;

@end

@implementation ImageAdjustmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Adjust Document";
    if (self.editedImage)
    {
        [[self imageView] setImage:[self editedImage]];
        self.adjustedImage = self.editedImage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setImage: (UIImage *)pImage
{
    self.editedImage = pImage;
}

- (IBAction)onBrightnessChanged:(id)sender {
    
    UISlider *slider = (UISlider*) sender;
    float brightnessFactor = [slider value];
    
    brightnessFactor /= 4;
    
    CGImageRef imgRef = [self.editedImage CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    
    uint8_t* rawData = malloc(totalBytes);
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0,roundf(*red + (*red * brightnessFactor))));
        *green = MIN(255,MAX(0,roundf(*green + (*green * brightnessFactor))));
        *blue = MIN(255,MAX(0,roundf(*blue + (*blue * brightnessFactor))));
        
    }
    
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    UIImage* image = [UIImage imageWithCGImage:newImg];
    [[self imageView] setImage:image];
    self.adjustedImage = image;
    CGImageRelease(newImg);
}

- (IBAction)onContrastChange:(id)sender {

    UISlider *slider = (UISlider*) sender;
    float contrastFactor = [slider value];
    
    contrastFactor *= 4;
    
    CGImageRef imgRef = [self.editedImage CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    
    uint8_t* rawData = malloc(totalBytes);
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0, roundf(contrastFactor*(*red - 127.5f)) + 128));
        *green = MIN(255,MAX(0, roundf(contrastFactor*(*green - 127.5f)) + 128));
        *blue = MIN(255,MAX(0, roundf(contrastFactor*(*blue - 127.5f)) + 128));
        
    }
    
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    UIImage* image = [UIImage imageWithCGImage:newImg];
    self.adjustedImage = image;
    [[self imageView] setImage:image];
    CGImageRelease(newImg);
}

- (IBAction)onResetButtonPressed:(id)sender {
    [[self imageView] setImage:self.editedImage];
    [[self sliderBrightness] setValue:0];
    [[self sliderContrast] setValue:0];
}

- (IBAction)onDoneButtonPressed:(id)sender {
    
    int currentDocumentCount = [[OTRManager sharedManager] getDocumentCount];
    [[OTRManager sharedManager] saveImage:self.adjustedImage];
    if (currentDocumentCount == 1) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DocumentOptionalPropertiesViewController"];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        UINavigationController *navController = self.navigationController;
        NSMutableArray *controllers=[[NSMutableArray alloc] initWithArray:navController.viewControllers] ;
        [controllers removeLastObject];
        [navController setViewControllers:controllers];
        [navController pushViewController:vc animated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
