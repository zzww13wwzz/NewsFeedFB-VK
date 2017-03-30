//
//  ViewController.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/28/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "VKAPI.h"

@interface ViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) VKAPI *vkapi;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.fbLoginButton.readPermissions = @[@"public_profile", @"user_posts"];
    [self fetchUserInfo];
    
    self.vkapi = [VKAPI new];
    self.webView.hidden = true;
    
    [self changeStateVKButton];
}

- (void)changeStateVKButton {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"]) {
        self.vkLoginButton.userInteractionEnabled = false;
        [self.vkLoginButton setTitle:@"Logged in VK" forState:UIControlStateNormal];
        self.vkLoginButton.backgroundColor = [UIColor grayColor];
    } else {
        [self.vkLoginButton setTitle:@"Login VK" forState:UIControlStateNormal];
    }
}

#pragma mark VKONTAKTE

- (IBAction)vkontakteAction:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://api.vk.com/oauth/authorize?client_id=5953151&scope=wall,photos,friends&redirect_uri=http://api.vk.com/blank.html&display=touch&response_type=token"];
    
    self.webView.hidden = false;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view.window makeKeyAndVisible];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    [self.vkapi getVKAccessTokenWithURL:webView.request.URL completion:^(NSString * message) {
        
        if (ValidString(message)) {
            [self showAlertWithString:message withError:nil];
        } else {
            [self changeStateVKButton];
        }
        self.webView.hidden = true;
    }];
}

#pragma mark NEXT
- (IBAction)signInAction:(id)sender {
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Access to facebook");
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"]) {
        NSLog(@"Access to vkontakte");
        
        [self.vkapi getJsonVKWithCompletion:^(NSError *error) {
            if (error) {
                [self showAlertWithString:nil withError:error];
            }
        }];
        
        //        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"]
        //                                             animated:YES];
        
    } else {
        [self showAlertWithString:@"NOT LOGED IN!!!" withError:nil];
    }
}


#pragma mark FACEBOOK
-(void)fetchUserInfo {
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
        
        [ApplicationDelegate showMBProgressHUDWithTitle:nil
                                               subTitle:nil
                                                   view:self.view];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed"
                                           parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
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

@end
