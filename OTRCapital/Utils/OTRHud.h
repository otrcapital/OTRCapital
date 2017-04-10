//
//  OTRHud.h
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 07.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

@interface OTRHud : NSObject

+ (OTRHud*)hud;
- (void)show;
- (void)hide;

@end
