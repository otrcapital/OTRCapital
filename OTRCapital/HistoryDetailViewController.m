//
//  HistoryDetailViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 17/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "HistoryDetailViewController.h"
#import "HistoryDetailCell.h"
#import "OTRManager.h"


@implementation HistoryDetailViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items ? self.items.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = (UIImage *)self.items[indexPath.row];
    float sw = [[UIScreen mainScreen] bounds].size.width;
    return sw * (image.size.height / image.size.width);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"HistoryDetailCell";
    
    HistoryDetailCell *cell = (HistoryDetailCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryDetailCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.image.image = self.items[indexPath.row];
    
    return cell;
}

@end
