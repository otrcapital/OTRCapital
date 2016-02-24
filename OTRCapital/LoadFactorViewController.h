//
//  LoadFactorViewController.h
//  ORTCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImagePickerController.h"

@interface LoadFactorViewController : UIViewController<UINavigationControllerDelegate, MAImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UIAlertViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSDictionary *data;

@end
