//
//  AppDelegate.h
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/28/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) MBProgressHUD * mbprogressHUD;

- (void) showMBProgressHUDWithTitle:(NSString *)title
                           subTitle:(NSString *)subtitle
                               view:(UIView *)view;

- (void) saveDB;
- (void) cleanAndResetupDB;


@end

