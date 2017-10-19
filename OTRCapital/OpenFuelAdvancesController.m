//
//  OpenFuelAdvances.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 19.10.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OpenFuelAdvancesController.h"
#import "OTRManager.h"
#import "OpenFuelAdvanceCell.h"
#import "OTRNote.h"

@interface OpenFuelAdvancesController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *loadList;

@end

@implementation OpenFuelAdvancesController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableArray *mNoteList = [NSMutableArray new];
    for (NSDictionary *info in [[OTRManager sharedManager] getFuelAdvanceOrPrebuildInfoList]) {
        [mNoteList addObject:[OTRNote createFromInfo:info]];
    }

    self.loadList = mNoteList;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 10;
    [self.tableView registerNib:[UINib nibWithNibName: @"OpenFuelAdvanceCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"OpenFuelAdvanceCell"];
    [self.tableView reloadData];
}


#pragma mark - UITableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loadList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"OpenFuelAdvanceCell";
    
    OpenFuelAdvanceCell *cell = (OpenFuelAdvanceCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"[OpenFuelAdvanceCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    OTRNote *info = self.loadList[indexPath.row];
    [cell setLoadInfo:info];

    return cell;
}

@end
