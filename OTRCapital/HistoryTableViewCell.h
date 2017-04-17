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
#import "OTRDocument+DB.h"

@protocol HistoryTableViewCellDelegate

- (void)emailDocumentPressed:(OTRDocument *)document;

- (void)deleteDocumentPress:(OTRDocument *)document;

- (void)resendDocumentPress:(OTRDocument *)document;

@end


@interface HistoryTableViewCell : UITableViewCell <UIAlertViewDelegate>

@property (nonatomic, strong) OTRDocument *document;

@property (nonatomic, weak) id<HistoryTableViewCellDelegate> delegate;

@end
