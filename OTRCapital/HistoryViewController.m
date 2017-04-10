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
#import "AsyncImageView.h"

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
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSString *folderName = [filePathsArray  objectAtIndex:i];
        
        [dic setObject:folderName forKey:KEY_DIR_NAME];
        
        NSString *directoryPath = [NSString stringWithFormat:@"%@/%@", rootDirectoryPath, folderName];
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
        
        if (!directoryContent || directoryContent.count == 0) {
            continue;
        }
        
        [dic setObject:directoryPath forKey:KEY_DIR_PATH];
        [dic setObject:directoryContent forKey:KEY_DIR_CONTENT];
        
        NSString *imagePath = nil;
        @try {
            imagePath = [NSString stringWithFormat:@"%@/%@", directoryPath,[directoryContent objectAtIndex:0]];
        } @catch (NSException *exception) {}
        
        if (imagePath) {
            [dic setObject:imagePath forKey:KEY_IMAGE];
        }
        
        NSDictionary *otrData = [[OTRManager sharedManager] getOtrInfoWithKey:folderName];
        if (otrData) {
            [dic setObject:otrData forKey:KEY_OTR_INFO];
            NSString *title = [otrData objectForKey:KEY_BROKER_NAME];
            if(title) [dic setObject:title forKey:KEY_TITLE];
            NSString *email = [otrData objectForKey:KEY_LOGIN_USER_NAME];
            if(email) [dic setObject:email forKey:KEY_EMAIL];
            NSString *status = [otrData objectForKey:KEY_OTR_INFO_STATUS];
            if(status) [dic setObject:status forKey:KEY_STATUS];
            NSString *loadNo = [otrData objectForKey:KEY_LOAD_NO];
            if(loadNo) [dic setObject:loadNo forKey:KEY_LOAD_NO];
            NSString *invoiceString = [otrData objectForKey:KEY_INVOICE_AMOUNT];
            [dic setObject:invoiceString forKey:KEY_INVOICE_AMOUNT];
            NSString *advReqAmount = [otrData objectForKey:KEY_ADV_REQ_AMOUT];
            if (advReqAmount) {
                [dic setObject:advReqAmount forKey:KEY_ADV_REQ_AMOUT];
            }
        }
        
        NSDate *date =  [NSDate dateWithTimeIntervalSince1970:[folderName doubleValue]];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        [dic setObject:dateString forKey:KEY_TIME];
        
        [tableData addObject:dic];
    }
    [self setTableData: tableData];
    [self.tableView reloadData];
}

- (void) removeDataOfIndex: (int)index{
    NSDictionary *dic = [self.tableData objectAtIndex:index];
    NSString *folderName = [dic objectForKey:KEY_DIR_NAME];
    [[OTRManager sharedManager] removeObjectForKey:folderName];
    [self.tableData removeObjectAtIndex:index];
    [self.tableView reloadData];
}

- (void) refreshView{
    
    for (int i = 0; i < self.tableData.count; i++) {
        NSDictionary *dic = [self.tableData objectAtIndex:i];
        NSString *folderName = [dic objectForKey:KEY_DIR_NAME];
        NSDictionary *otrData = [[OTRManager sharedManager] getOtrInfoWithKey:folderName];
        NSString *status = [otrData objectForKey:KEY_OTR_INFO_STATUS];
        [dic setValue:status forKey:KEY_STATUS];
    }
    
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"HistoryTableViewCell";
    
    HistoryTableViewCell *cell = (HistoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:cell.image.frame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = IMAGE_VIEW_TAG;
        [cell addSubview:imageView];
    }
    
    NSDictionary *dic = [self.tableData  objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:KEY_TITLE];
    NSString *email = [dic objectForKey:KEY_EMAIL];
    NSString *imagePath = [dic objectForKey:KEY_IMAGE];
    NSString *status = [dic objectForKey:KEY_STATUS];
    NSString *time  = [dic objectForKey:KEY_TIME];
    NSString *loadNo = [dic objectForKey:KEY_LOAD_NO];
    NSString *invoiceAmount = [dic objectForKey:KEY_INVOICE_AMOUNT];
    NSString *advReqAmount = [dic objectForKey:KEY_ADV_REQ_AMOUT];
    
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
    
    NSString *folderName = [dic objectForKey:KEY_DIR_NAME];
    
    cell.directoryContents = [dic objectForKey:KEY_DIR_CONTENT];
    cell.directoryPath = [dic objectForKey:KEY_DIR_PATH];;
    cell.parentNavigationController = self.navigationController;
    cell.parent = self;
    cell.index = (int) indexPath.row;
    NSDictionary *otrDataFixed = [dic objectForKey:KEY_OTR_INFO];
    NSMutableDictionary *otrDataChangable = [NSMutableDictionary dictionaryWithDictionary:otrDataFixed];
    cell.otrInfo = otrDataChangable;
    cell.directoryName = folderName;
    [cell initCellInfo];
    
    AsyncImageView *imageView = (AsyncImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView];
    imageView.imageURL = [NSURL fileURLWithPath:imagePath];
    
    return cell;
}

@end
