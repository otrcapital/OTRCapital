//
//  BrokerDetailViewController.h
//  OTRCapital
//
//  Created by OTRCapital on 18/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface BrokerDetailViewController : UIViewController <TTTAttributedLabelDelegate>
@property (nonatomic, retain) NSDictionary* data;
@end
