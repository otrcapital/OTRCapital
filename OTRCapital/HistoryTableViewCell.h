//
//  HistoryTableViewCell.h
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "OTRManager.h"
#import "HistoryViewController.h"

@interface HistoryTableViewCell : UITableViewCell <MFMailComposeViewControllerDelegate, OTRManagerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *loadNo;
@property (strong, nonatomic) IBOutlet UILabel *rate;

@property (strong, nonatomic) NSArray *directoryContents;
@property (strong, nonatomic) NSString *directoryPath;
@property (strong, nonatomic) NSString *directoryName;
@property (strong) UINavigationController *parentNavigationController;
@property (strong) HistoryViewController *parent;
@property int index;
@property (strong) NSMutableDictionary *otrInfo;

- (IBAction)onCellClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *cellButton;

- (void) initCellInfo;

@end
