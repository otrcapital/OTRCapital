//
//  BrokerCheckViewController.m
//  OTRCapital
//
//  Created by OTRCapital on 12/07/2015.
//  Copyright (c) 2015 OTRCapital LLC. All rights reserved.
//

#import "BrokerCheckViewController.h"
#import "OTRManager.h"
#import "BrokerDetailViewController.h"

@interface BrokerCheckViewController ()
{
    NSMutableArray *muary_Interest_Main;
    NSMutableArray *muary_Interest_Sub;
    UITableView *tbl_Search;
    UITapGestureRecognizer *tapper;
}
@property (strong, nonatomic) IBOutlet UILabel *lblBrokerName;
@property (strong, nonatomic) IBOutlet UITextField *txtFdBrokerName;
@property (strong, nonatomic) IBOutlet UITextField *txtFdMCNumber;
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) NSArray *brokerList;
@property int tblSearchX;
@property int tblSearchY;
- (IBAction)onVerifyButtonPressed:(id)sender;

@end

@implementation BrokerCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Broker Check";    
    self.txtFdBrokerName.delegate = self;
    self.txtFdMCNumber.delegate = self;
    
    self.originalCenter = self.view.center;
    self.brokerList = [[OTRManager sharedManager] getBrokersList];
    
    tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    muary_Interest_Main = [NSMutableArray arrayWithArray:self.brokerList];
    muary_Interest_Sub = [[NSMutableArray alloc]init];
    
    self.tblSearchX = [self.lblBrokerName convertPoint:self.lblBrokerName.frame.origin toView:nil].x + 10;
    self.tblSearchY = [self.txtFdBrokerName convertPoint:self.txtFdBrokerName.frame.origin toView:self.view].y + self.txtFdBrokerName.frame.size.height;
    tbl_Search = [[UITableView alloc] initWithFrame:
                  CGRectMake(self.tblSearchX, self.tblSearchY, self.lblBrokerName.frame.size.width + self.txtFdBrokerName.frame.size.width * 1.15, 150) style:UITableViewStylePlain];
    tbl_Search.delegate = self;
    tbl_Search.dataSource = self;
    tbl_Search.scrollEnabled = YES;
    
    [tbl_Search registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:tbl_Search];
    [tbl_Search setHidden:TRUE];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[OTRManager sharedManager] setDelegate:self];
}
- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[OTRManager sharedManager] setDelegate:nil];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtFdBrokerName) {
        [self searchText:textField replacementString:@"Begin"];
    }
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y * 0.75);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.center = self.originalCenter;
    tbl_Search.hidden = TRUE;
    tapper.enabled = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtFdBrokerName) {
        [self searchText:textField replacementString:string];
    }
    return YES;
}

-(void) searchText:(UITextField *)textField replacementString:(NSString *)string
{
    NSString *str_Search_String=[NSString stringWithFormat:@"%@",textField.text];
    if([string isEqualToString:@"Begin"])
        str_Search_String = [NSString stringWithFormat:@"%@",textField.text];
    else if([string isEqualToString:@""])
        str_Search_String = [str_Search_String substringToIndex:[str_Search_String length] - 1];
    else
        str_Search_String = [str_Search_String stringByAppendingString:string];
    
    muary_Interest_Sub=[[NSMutableArray alloc] init];
    if(str_Search_String.length > 0)
    {
        NSInteger counter = 0;
        for(NSString *name in muary_Interest_Main)
        {
            NSRange r = [name rangeOfString:str_Search_String options:NSCaseInsensitiveSearch];
            if(r.length > 0)
            {
                [muary_Interest_Sub addObject:name];
            }
            
            counter++;
            
        }
        
        if (muary_Interest_Sub.count > 0)
        {
            tbl_Search.hidden = FALSE;
            tapper.enabled = NO;
            [tbl_Search reloadData];
        }
        else
        {
            tbl_Search.hidden = TRUE;
            tapper.enabled = YES;
        }
    }
    else
    {
        [tbl_Search setHidden:TRUE];
        tapper.enabled = YES;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [muary_Interest_Sub count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
    }
    cell.textLabel.text = [muary_Interest_Sub objectAtIndex:indexPath.row];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if (!muary_Interest_Sub.count && muary_Interest_Sub.count < indexPath.row) {
        return;
    }
    self.txtFdBrokerName.text = [muary_Interest_Sub objectAtIndex:indexPath.row];
    self.txtFdMCNumber.text = [[OTRManager sharedManager] getMCNumberByBrokerName:self.txtFdBrokerName.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onVerifyButtonPressed:(id)sender {
    if (![self isValidInfo]) {
        [self showAlertViewWithTitle:@"Information Missing" andWithMessage:@"Please provide one of the required info. Both Broker Name and MC Number are emtpy."];
    }else {

        [[OTRHud hud] show];

        NSString *pKey = nil;
        
        if(![self.txtFdBrokerName.text isEqualToString:@""])
            pKey = [[OTRManager sharedManager] getPKeyByBrokerName:self.txtFdBrokerName.text];
        if(pKey == nil && ![self.txtFdMCNumber.text isEqualToString:@""])
            pKey = [[OTRManager sharedManager] getPkeyByMCNumber:self.txtFdMCNumber.text];
        if (pKey) {
            [[OTRManager sharedManager] findBrokerInfoByPkey:pKey];
        }
        else{
            [self showAlertViewWithTitle:@"Information Missing" andWithMessage:@"Both Broker Name and MC Number are not valid. Please varify it to proceed."];
        }
    }
}

- (BOOL) isValidInfo{
    
    NSString *brokerName = self.txtFdBrokerName.text;
    NSString *mcNo = self.txtFdMCNumber.text;
    if ([brokerName  isEqual: @""] && [mcNo  isEqual: @""]) {
        return NO;
    }
    
    return YES;
}

- (void) showAlertViewWithTitle: (NSString*)title andWithMessage: (NSString*) msg{
    [[OTRHud hud] hide];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark OTRDelegate Methods
- (void) onOTRRequestSuccessWithData:(NSDictionary *)data{
    [[OTRHud hud] hide];
    if (data) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BrokerDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"BrokerDetailViewController"];
        vc.data = data;
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void) onOTRRequestFailWithError:(NSString *)error{
    [self showAlertViewWithTitle:@"Sorry" andWithMessage:@"There is some error, please try later"];
}

@end
