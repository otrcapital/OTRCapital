//
//  DocumentEditViewController.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentEditViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)onDoneButtonPressed:(id)sender;
- (IBAction)onDiscardButtonPressed:(id)sender;
- (IBAction)onRotateLeftButtonPressed:(id)sender;
- (IBAction)onRotateRightButtonPressed:(id)sender;

- (void) setImage: (UIImage *)pImage;

@end
