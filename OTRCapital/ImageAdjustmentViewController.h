//
//  ImageAdjustmentViewController.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageAdjustmentViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISlider *sliderBrightness;
@property (strong, nonatomic) IBOutlet UISlider *sliderContrast;

- (IBAction)onBrightnessChanged:(id)sender;
- (IBAction)onContrastChange:(id)sender;
- (IBAction)onResetButtonPressed:(id)sender;
- (IBAction)onDoneButtonPressed:(id)sender;

- (void) setImage: (UIImage *)pImage;

@end
