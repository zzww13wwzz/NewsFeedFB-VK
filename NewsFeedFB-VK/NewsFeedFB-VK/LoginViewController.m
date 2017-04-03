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
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic, assign) BOOL isAsseptAutologin;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.fbLoginButton.readPermissions = @[@"public_profile", @"user_posts"];
    
    VKSdk *sdkInstance = [VKSdk initializeWithAppId:@"5953151"];
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    self.isAsseptAutologin = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"];
    [self updateUIButtonWithState:NO];
    
    [self fetchFacebookState];
    [self fetchVkState];
}

- (void) fetchVkState {
    
    if (self.isAsseptAutologin) {
        [ApplicationDelegate showMBProgressHUDWithTitle:nil
                                               subTitle:nil
                                                   view:self.view];
        
        NSArray *scope = @[@"friends", @"wall", @"photos", @"video"];
        if (![VKSdk isLoggedIn]) {
            [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *error) {
                if (state == VKAuthorizationAuthorized) {
                    [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
                    [self updateUIButtonWithState:YES];
                    
                }  else if (state == VKAuthorizationInitialized){
                    [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
                    [self updateUIButtonWithState:YES];
                    [VKSdk authorize:scope];
                    
                } else {
                    [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"]) {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessToken"];
                    }
                    NSLog(@"VKAuthorizationError");
                }
                
            }];
        } else {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessToken"];
            }
            [self updateUIButtonWithState:NO];
            [VKSdk forceLogout];
            [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
        }
    }
}


- (void)updateUIButtonWithState:(BOOL)isLogin {
    
    if (![VKAPI isInternetAvailable]){
        self.messageLabel.text = @"Please check your internet connection for sign in";
    } else {
        self.messageLabel.text = @"Please sign in:";
    }
    
    if (isLogin) {
        [self.vkLoginButton setTitle:@"Logout" forState:UIControlStateNormal];
        self.nextButton.userInteractionEnabled = true;
        self.nextButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.2 alpha:1.0];
        self.messageLabel.text = @"You can go next";
    } else {
        self.nextButton.userInteractionEnabled = false;
        self.nextButton.backgroundColor = [UIColor grayColor];
        [self.vkLoginButton setTitle:@"Login VK" forState:UIControlStateNormal];
    }
}

#pragma mark VKONTAKTE

- (IBAction)vkontakteAction:(id)sender {
    
    self.isAsseptAutologin = true;
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
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed"
                                           parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
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
    if (result.token.accessToken) {
        [[NSUserDefaults standardUserDefaults] setObject:result.token.accessToken forKey:@"VKAccessToken"];
    } else if (result.error) {
        [self showAlertWithString:nil withError:result.error];
    }
}

- (void)vkSdkUserAuthorizationFailed {
    [self showAlertWithString:@"Authorization failed, please try again later." withError:nil];
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
    
}

@end
