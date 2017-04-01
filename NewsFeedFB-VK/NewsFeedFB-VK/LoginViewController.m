//
//  ViewController.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/28/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "VKSdk.h"
#import "FeedTableViewController.h"


@interface LoginViewController () <VKSdkDelegate, VKSdkUIDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.fbLoginButton.readPermissions = @[@"public_profile", @"user_posts"];
    
    [self fetchFacebookState];
    [self fetchVkState];
}

- (void) fetchVkState {
    [ApplicationDelegate showMBProgressHUDWithTitle:nil
                                           subTitle:nil
                                               view:self.view];
    
    VKSdk *sdkInstance = [VKSdk initializeWithAppId:@"5953151"];
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    
    
    self.nextButton.userInteractionEnabled = false;
    self.nextButton.backgroundColor = [UIColor grayColor];
    [self.vkLoginButton setTitle:@"Login VK" forState:UIControlStateNormal];
    [self.nextButton setTitle:@"need login to vk" forState:UIControlStateNormal];
    
    NSArray *scope = @[@"friends", @"wall", @"photos"];
    if (![VKSdk isLoggedIn]) {
        [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *error) {
            if (state == VKAuthorizationAuthorized) {
                [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
                [self.vkLoginButton setTitle:@"Logged in VK" forState:UIControlStateNormal];
                self.vkLoginButton.backgroundColor = [UIColor lightGrayColor];
                self.vkLoginButton.userInteractionEnabled = false;
                self.nextButton.userInteractionEnabled = true;
                self.nextButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.2 alpha:1.0];
                [self.nextButton setTitle:@"Go" forState:UIControlStateNormal];
                
                

                
            }  else if (state == VKAuthorizationInitialized){
                [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
                [VKSdk authorize:scope];
                
            } else {
                [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
                NSLog(@"VKAuthorizationError");
            }
            
        }];
    } else {
        
    }
    
    //    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"]) {
    //        self.vkLoginButton.userInteractionEnabled = false;
    //        [self.vkLoginButton setTitle:@"Logged in VK" forState:UIControlStateNormal];
    //        self.vkLoginButton.backgroundColor = [UIColor grayColor];
    //    } else {
    //        [self.vkLoginButton setTitle:@"Login VK" forState:UIControlStateNormal];
    //    }
}

#pragma mark VKONTAKTE

- (IBAction)vkontakteAction:(id)sender {
    [self fetchVkState];
}

#pragma mark NEXT
- (IBAction)signInAction:(id)sender {
    
    FeedTableViewController * newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}


#pragma mark FACEBOOK
-(void)fetchFacebookState {
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
        
        //        [ApplicationDelegate showMBProgressHUDWithTitle:@"Facebook account state updating..."
        //                                               subTitle:nil
        //                                                   view:self.view];
        //
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed"
                                           parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             //             [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
             if (!error) {
                 NSLog(@"result = %@",result);
             } else {
                 NSLog(@"Error %@",error);
             }
         }];
    }
}

- (void)showAlertWithString:(NSString *)string
                  withError:(NSError *)error  {
    NSString *title = nil;
    if (string == nil){
        string = [error localizedDescription];
        title = @"Error";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:string
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma VKSdkDelegate

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        [[NSUserDefaults standardUserDefaults] setObject:result.token forKey:@"VKAccessToken"];
    } else if (result.error) {
        [self showAlertWithString:nil withError:result.error];
    }
}

- (void)vkSdkUserAuthorizationFailed {
    [self showAlertWithString:@"Authorization failed, please try again later." withError:nil];
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

@end
