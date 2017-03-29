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
//#import <VKSdk.h>

@interface ViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.fbLoginButton.readPermissions = @[@"public_profile", @"user_posts"];
    [self fetchUserInfo];
    
    self.webView.hidden = true;
}

- (IBAction)signInAction:(id)sender {
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Access to facebook");
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"]) {
        NSLog(@"Access to vkontakte");
        [self requestVK];
        
//        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedVC"]
//                                             animated:YES];
        
    }
    
    
    // https://api.vk.com/method/newsfeed.get?PARAMETERS&access_token=ACCESS_TOKEN&v=V
    
    else {
        [self showAlertWithString:@"NOT LOGED IN!!!" withError:nil];
    }
}

- (void)requestVK {
    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"];
    
    NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/newsfeed.get?PARAMETERS&access_token=%@&v=5.63", token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);

    }
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:kNilOptions
                                                           error:&error];
    
    //NSString * new = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

- (IBAction)signInVKAction:(id)sender {
    
    self.webView.delegate = self;
    self.webView.hidden = false;
    
    NSString *authLink = [NSString stringWithFormat:@"http://api.vk.com/oauth/authorize?client_id=5953151&scope=wall,photos,friends&redirect_uri=http://api.vk.com/blank.html&display=touch&response_type=token"];
    NSURL *url = [NSURL URLWithString:authLink];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self.view.window makeKeyAndVisible];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *currentURL = webView.request.URL.absoluteString;
    NSRange textRange =[[currentURL lowercaseString] rangeOfString:[@"access_token" lowercaseString]];
    
    if(textRange.location != NSNotFound){
        
        NSArray* data = [currentURL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:[data objectAtIndex:1] forKey:@"VKAccessToken"];
        [[NSUserDefaults standardUserDefaults] setObject:[data objectAtIndex:5] forKey:@"VKAccessUserId"];
        self.webView.hidden = true;
        
        NSLog(@"vkWebView response: %@",[[[webView request] URL] absoluteString]);
        
    }
    else {
        textRange =[[currentURL lowercaseString] rangeOfString:[@"access_denied" lowercaseString]];
        if (textRange.location != NSNotFound) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ooops! something gonna wrong..." message:@"Check your internet connection and try again!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            self.webView.hidden = true;
        }
    }
}

-(void)fetchUserInfo {
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

@end
