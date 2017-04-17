//
//  OTRDocument+DB.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 17.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OTRDocument.h"

@interface OTRDocument (Database)

+ (NSArray *)list;

+ (OTRDocument *)create;

+ (void)clearTemporaryNotes;

@end
