//
//  OTRHud.m
//  OTRCapital
//
//  Created by Nikita Kalpashchykau on 07.04.17.
//  Copyright © 2017 SIMAQ Inc. All rights reserved.
//

#import "OTRHud.h"
#import "AppDelegate.h"

@interface OTRHud ()

@property (nonatomic) int counter;
@property (nonatomic, strong) UIView *spinnerView;

@end

@implementation OTRHud

+ (OTRHud*)hud {
    static dispatch_once_t once;
    static OTRHud *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [self new];
    });
    return sharedView;
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinnerView removeFromSuperview];
        self.spinnerView = nil;
        self.spinnerView = [self createView];
        
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows)
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self.spinnerView];
                break;
            }
    });
//    if (![[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
//        //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    }
    self.counter ++;
}

- (void)hide {
    self.counter --;
    if(self.counter <= 0) {
        self.counter = 0;
        if(self.spinnerView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView removeFromSuperview];
                self.spinnerView = nil;
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        });   
    }
}

- (UIView *)createView {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIView* baseView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [baseView setBackgroundColor:[UIColor blackColor]];
    baseView.userInteractionEnabled = YES;
    baseView.alpha = 0.5;
    
    UIActivityIndicatorView *spinner = [UIActivityIndicatorView new];
    spinner.color = [UIColor whiteColor];
    [spinner startAnimating];
    [spinner setCenter:baseView.center];
    [baseView addSubview:spinner];
    
    return baseView;
}

@end
