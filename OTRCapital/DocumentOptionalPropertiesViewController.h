//
//  DocumentOptionalPropertiesViewController.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "OTRManager.h"
#import "MAImagePickerController.h"

@class OTRDocument;

@interface DocumentOptionalPropertiesViewController : UIViewController<UINavigationControllerDelegate, MAImagePickerControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong, setter=setDocument:) OTRDocument *mDocument;

- (IBAction)onUploadDocumentButtonPressed:(id)sender;
- (IBAction)onScanMoreDocumentButtonPressed:(id)sender;
- (void) initLoadFactor;
- (void) initAdvanceLoan;

@end
