//
//  OTRDocument+DB.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 17.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRDocument+DB.h"

@implementation OTRDocument (Database)

+ (NSArray *)list {
    return [OTRDocument MR_findAllSortedBy:@"date" ascending:NO];
}

+ (OTRDocument *)create {
    OTRDocument *document = [OTRDocument MR_createEntity];
    document.date = [NSDate date];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%f",[document.date timeIntervalSince1970]]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    document.folderPath = dataPath;
    
    [document.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return document;
}

+ (void)clearTemporaryNotes {
    [OTRDocument MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"factorType == 'N/A'"]];
}

@end
