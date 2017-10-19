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
#import "LoadFactorViewController.h"

@interface OpenFuelAdvancesController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *loadList;
@property (nonatomic, strong) NSArray *loadInfoList;
@property (nonatomic, strong) NSDictionary *selectedInfo;

@end

@implementation OpenFuelAdvancesController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[OTRManager sharedManager] initOTRInfo];
    
    NSMutableArray *mNoteList = [NSMutableArray new];
    NSMutableArray *mNoteInfoList = [NSMutableArray new];
    
    for (NSDictionary *info in [[OTRManager sharedManager] getFuelAdvanceOrPrebuildInfoList]) {
        [mNoteList addObject:[OTRNote createFromInfo:info]];
        [mNoteInfoList addObject:info];
    }
    self.loadList = mNoteList;
    self.loadInfoList = mNoteInfoList;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 10;
    [self.tableView registerNib:[UINib nibWithNibName: @"OpenFuelAdvanceCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier: @"OpenFuelAdvanceCell"];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.selectedInfo = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"LoadFactorViewController"]) {
        if (self.selectedInfo) {
            [[OTRManager sharedManager] setCurrentOTRInfo:self.selectedInfo];
            LoadFactorViewController *controller = segue.destinationViewController;
            
            if ([controller isKindOfClass: [LoadFactorViewController class]]) {
                controller.data = self.selectedInfo;
                [controller setOTRInfo: [OTRNote createFromInfo:self.selectedInfo]];
            }
        }
    }
}


#pragma mark - UITableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loadList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedInfo = self.loadInfoList[indexPath.row];
    [self performSegueWithIdentifier:@"LoadFactorViewController" sender:self];
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
