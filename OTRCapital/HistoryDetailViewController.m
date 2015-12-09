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

@interface HistoryDetailViewController ()

@end

@implementation HistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directoryContents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 451;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"HistoryDetailCell";
    
    HistoryDetailCell *cell = (HistoryDetailCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryDetailCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", self.directoryPath,[self.directoryContents objectAtIndex:indexPath.row]];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    cell.image.image = image;
    
    return cell;
}

@end
