//
//  AppDelegate.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/28/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <VKSdk.h>
//#import <VKSdopenURLk.h>
//#import <VKSdkFramework/VKSdkFramework.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    [self setupDB];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}


#pragma mark - DataBase

- (void) setupDB {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:[self dbStore]];
}

- (NSString *) dbStore {
    return [NSString stringWithFormat:@"%@.sqlite", @"TwitterApp"];
}

- (void) saveDB {
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSLog(@"applicationDidEnterBackground: Saving finished");
    }];
}

- (void) cleanAndResetupDB
{
    NSString * dbStore = [self dbStore];
    NSError * error = nil;
    
    [MagicalRecord cleanUp];
    
    if ([[NSFileManager defaultManager] removeItemAtURL:[NSPersistentStore MR_urlForStoreName:dbStore]
                                                  error:&error]){
        [self setupDB];
    }
    else {
        NSLog(@"An error has occurred while deleting %@", dbStore);
        NSLog(@"Error description: %@", error.description);
    }
}


- (void) showMBProgressHUDWithTitle:(NSString *)title
                           subTitle:(NSString *)subtitle
                               view:(UIView *)view
{
    [_mbprogressHUD hideAnimated:NO];
    
    _mbprogressHUD = [MBProgressHUD showHUDAddedTo:view == nil ? PICKER_PRESENTATION_VIEW : view
                                          animated:YES];
    if (ValidString(title)) {
        _mbprogressHUD.mode = MBProgressHUDModeIndeterminate;
        _mbprogressHUD.label.text = title;
        if (ValidString(subtitle)) {
            _mbprogressHUD.detailsLabel.font = _mbprogressHUD.label.font;
            _mbprogressHUD.detailsLabel.text = subtitle;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}

@end
