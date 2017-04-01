//
//  LaunchViewController.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 4/1/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "LaunchViewController.h"
#import "VKSdk.h"

@interface LaunchViewController () <VKSdkDelegate, VKSdkUIDelegate>

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    VKSdk *sdkInstance = [VKSdk initializeWithAppId:@"5953151"];
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    
    NSArray *scope = @[@"friends", @"wall", @"photos"];
    
    [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            // Authorized and ready to go
        }  else if (state == VKAuthorizationInitialized){
            [VKSdk authorize:scope];
        } else {
            NSLog(@"VKAuthorizationError");
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma VKSdkDelegate

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {

    } else if (result.error) {
        // Пользователь отменил авторизацию или произошла ошибка
    }
}

- (void)vkSdkUserAuthorizationFailed {
    /**
     Notifies about access error. For example, this may occurs when user rejected app permissions through VK.com
     */
    
}

#pragma VKSdkUIDelegate
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    
    [self presentViewController:controller
                       animated:NO
                     completion:nil];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    
}

- (void)vkSdkWillDismissViewController:(UIViewController *)controller {
    /**
     * Called when a controller presented by SDK will be dismissed.
     */

}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
//    
////    [VKSdk initializeWithAppId:@"5953151"];
//        VKSdk *sdkInstance = [VKSdk initializeWithAppId:@"5953151"];
////        [sdkInstance registerDelegate:sselfelf];
//        [sdkInstance setUiDelegate:self];

    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]) {
//        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"]
//                                             animated:NO];
//    } else {
//        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"]
//                           animated:NO
//                         completion:nil];
//    }
}



@end
