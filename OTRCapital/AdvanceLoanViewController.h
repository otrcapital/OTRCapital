//
//  AdvanceLoanViewController.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImagePickerController.h"

@interface AdvanceLoanViewController : UIViewController <UINavigationControllerDelegate, MAImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, retain) NSDictionary *data;

@end
