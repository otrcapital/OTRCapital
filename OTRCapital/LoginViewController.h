//
//  LoginViewController.h
//  ORTCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "OTRManager.h"
#import "CrashlyticsManager.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate, OTRManagerDelegate>
- (IBAction)loginButtonPressed:(id)sender;

@property(nonatomic, retain) NSString *email;
@end
