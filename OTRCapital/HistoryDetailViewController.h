//
//  HistoryDetailViewController.h
//  OTRCapital
//
//  Created by OTRCapital on 17/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "HistoryViewController.h"
#import "OTRManager.h"

@interface HistoryDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *items;

@end
