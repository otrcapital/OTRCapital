//
//  OTRNote.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 10.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTRNote : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *loadNo;
@property (nonatomic, strong) NSString *invoiceAmount;
@property (nonatomic, strong) NSString *advReqAmount;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *directoryPath;
@property (nonatomic, strong) NSArray *directoryContents;
@property (nonatomic, strong) NSDictionary *otrDataFixed;

@end
