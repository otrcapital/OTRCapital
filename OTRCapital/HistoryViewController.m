//
//  HistoryViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryTableViewCell.h"
#import "OTRManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "OTRNote.h"

#define KEY_IMAGE       @"image"
#define KEY_TITLE       @"title"
#define KEY_EMAIL       @"email"
#define KEY_TIME        @"time"
#define KEY_STATUS      @"status"
#define KEY_DIR_PATH    @"dir_path"
#define KEY_DIR_CONTENT @"dir_content"
#define KEY_DIR_NAME    @"dir_name"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define IMAGE_VIEW_TAG 199

@interface HistoryViewController ()

@property (nonatomic, retain) NSMutableArray *tableData;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"History";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootDirectoryPath = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootDirectoryPath  error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![evaluatedObject hasSuffix:@".pdf"];
    }];
    
    filePathsArray =  [filePathsArray filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *tableData = [NSMutableArray new];
    
    for (int i = (int) filePathsArray.count - 1; i >= 0 ; i--) {
        OTRNote *note = [OTRNote new];
        NSString *folderName = [filePathsArray  objectAtIndex:i];
        
        note.folderName = folderName;
        
        NSString *directoryPath = [NSString stringWithFormat:@"%@/%@", rootDirectoryPath, folderName];
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
        
        if (!directoryContent || directoryContent.count == 0) {
            continue;
        }
        
        note.directoryPath = directoryPath;
        note.directoryContents = directoryContent;
        
        NSString *imagePath = nil;
        @try {
            imagePath = [NSString stringWithFormat:@"%@/%@", directoryPath,[directoryContent objectAtIndex:0]];
        } @catch (NSException *exception) {}
        
        if (imagePath) {
            note.imagePath = imagePath;
        }
        
        NSDictionary *otrData = [[OTRManager sharedManager] getOtrInfoWithKey:folderName];
        if (otrData) {
            note.otrDataFixed = otrData;
            NSString *title = [otrData objectForKey:KEY_BROKER_NAME];
            if(title) note.title = title;
            NSString *email = [otrData objectForKey:KEY_LOGIN_USER_NAME];
            if(email) note.email = email;
            NSString *status = [otrData objectForKey:KEY_OTR_INFO_STATUS];
            if(status) note.status = status;
            NSString *loadNo = [otrData objectForKey:KEY_LOAD_NO];
            if(loadNo) note.loadNo = loadNo;
            NSString *invoiceString = [otrData objectForKey:KEY_INVOICE_AMOUNT];
            note.invoiceAmount = invoiceString;
            NSString *advReqAmount = [otrData objectForKey:KEY_ADV_REQ_AMOUT];
            if (advReqAmount) {
                note.advReqAmount = advReqAmount;
            }
        }
        
        NSDate *date =  [NSDate dateWithTimeIntervalSince1970:[folderName doubleValue]];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        note.time = dateString;
        
        [tableData addObject:note];
    }
    [self setTableData: tableData];
    [self.tableView reloadData];
}

- (void) removeDataOfIndex: (int)index{
    OTRNote *obj = [self.tableData objectAtIndex:index];
    NSString *folderName = obj.folderName;
    [[OTRManager sharedManager] removeObjectForKey:folderName];
    [self.tableData removeObjectAtIndex:index];
    [self.tableView reloadData];
}

- (void) refreshView {
    for (int i = 0; i < self.tableData.count; i++) {
        OTRNote *obj = [self.tableData objectAtIndex:i];
        NSString *folderName = obj.folderName;
        NSDictionary *otrData = [[OTRManager sharedManager] getOtrInfoWithKey:folderName];
        NSString *status = [otrData objectForKey:KEY_OTR_INFO_STATUS];
        obj.status =status;
    }
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 106;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"HistoryTableViewCell";
    
    HistoryTableViewCell *cell = (HistoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    OTRNote *obj = [self.tableData  objectAtIndex:indexPath.row];
    NSString *title = obj.title;
    NSString *email = obj.email;
    NSString *imagePath = obj.imagePath;
    NSString *status = obj.status;
    NSString *time  = obj.time;
    NSString *loadNo = obj.loadNo;
    NSString *invoiceAmount = obj.invoiceAmount;
    NSString *advReqAmount = obj.advReqAmount;
    
    cell.time.text = time ? time : @"";
    cell.title.text = title ? title : @"";
    cell.address.text = email ? email : @"";
    cell.status.text = status ? [NSString stringWithFormat:@"status: %@", status] : @"";
    cell.loadNo.text =  loadNo ? [NSString stringWithFormat:@"LoadNo: %@", loadNo] : @"";
    if (advReqAmount) {
        cell.rate.text = invoiceAmount ?[NSString stringWithFormat:@"Invoice: %@, Advance: %@", invoiceAmount, advReqAmount] : [NSString stringWithFormat:@"Advance: %@", advReqAmount];
    }
    else {
        cell.rate.text = invoiceAmount ?[NSString stringWithFormat:@"Invoice: %@", invoiceAmount] : @"";
    }
    
    NSString *folderName = obj.folderName;
    
    cell.directoryContents = obj.directoryContents;
    cell.directoryPath = obj.directoryPath;
    cell.parentNavigationController = self.navigationController;
    cell.parent = self;
    cell.index = (int) indexPath.row;
    NSDictionary *otrDataFixed = obj.otrDataFixed;
    NSMutableDictionary *otrDataChangable = [NSMutableDictionary dictionaryWithDictionary:otrDataFixed];
    cell.otrInfo = otrDataChangable;
    cell.directoryName = folderName;
    [cell initCellInfo];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
    [imageView setShowActivityIndicatorView:YES];
    [imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView sd_setImageWithURL:[NSURL fileURLWithPath:imagePath] placeholderImage:nil];
    
    return cell;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
