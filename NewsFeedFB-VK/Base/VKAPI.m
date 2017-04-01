//
//  VKAPI.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/30/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "VKAPI.h"
#import "Group.h"
#import "Item.h"
#import "User.h"
#import <VKSdk.h>

@implementation VKAPI



//+ (void)getVKAccessTokenWithURL:(NSURL *)url
//                     completion:(void (^)(NSString * message))completion
//{
//    NSString *currentURL = url.absoluteString;
//    NSRange textRange =[[currentURL lowercaseString] rangeOfString:[@"access_token" lowercaseString]];
//    
//    if(textRange.location != NSNotFound) {
//        NSArray* data = [currentURL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
//        //NSString
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[data objectAtIndex:1] forKey:@"VKAccessToken"];
//        [[NSUserDefaults standardUserDefaults] setObject:[data objectAtIndex:5] forKey:@"VKAccessUserId"];
//        [[NSUserDefaults standardUserDefaults] setObject:[data objectAtIndex:3] forKey:@"expires_in"];
//
//        
//        PERFORM_BLOCK(completion, nil);
//        
//    } else {
//        textRange =[[currentURL lowercaseString] rangeOfString:[@"access_denied" lowercaseString]];
//        
//        if (textRange.location != NSNotFound) {
//            PERFORM_BLOCK(completion, @"Access denied.");
//        }
//    }
//}

//+ (void)getJsonVKWithCompletion:(void (^)(NSError * error))completion {
//    NSError *error = nil;
//    NSHTTPURLResponse *responseCode = nil;
//    
//    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"];
//    
//    
//    NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/newsfeed.get?PARAMETERS&access_token=%@&v=5.63", token];
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setHTTPMethod:@"GET"];
//    [request setURL:[NSURL URLWithString:url]];
//    
//    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request
//                                                  returningResponse:&responseCode
//                                                              error:&error];
//    
//    if([responseCode statusCode] != 200){
//        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
//        PERFORM_BLOCK(completion, error);
//    }
//    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:oResponseData
//                                                         options:kNilOptions
//                                                           error:&error];
//    [self parserJson:json];
//    
//    if (error) {
//        PERFORM_BLOCK(completion, error);
//    } else {
//        PERFORM_BLOCK(completion, nil);
//    }
//}


+ (void)getDataWithCompletion:(void (^)(NSError * error))completion {
    
    VKRequest * getWall = [VKRequest requestWithMethod:@"newsfeed.get" parameters:@{VK_API_OWNER_ID : @"-1"}];
    
    [getWall executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        if (response.json) {
            BOOL isDoneParse = [self parseJson:response.json];
            if (isDoneParse) {
                [ApplicationDelegate saveDB];
            }
            
            PERFORM_BLOCK(completion, nil);
        }
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
            PERFORM_BLOCK(completion, error);
        }
    }];
}

+ (BOOL)parseJson:(NSDictionary*)json {

        if (json[@"profiles"]) {
            for (NSDictionary * profile in json[@"profiles"]) {
                
                //                NSLog(@"[profile string] = %@, %@, %@, %@, %@, %@",[profile[@"id"] stringValue], profile[@"first_name"], profile[@"last_name"], profile[@"online"], profile[@"online_mobile"], profile[@"photo_100"] );
                
                [User userWithID:[profile[@"id"] stringValue]
                       firstName:profile[@"first_name"]
                        lastName:profile[@"last_name"]
                        isOnline:profile[@"online"]
                  isMobileOnline:profile[@"online_mobile"]
                        photoURL:profile[@"photo_100"]];
            }
        }
        if (json[@"groups"]) {
            for (NSDictionary * group in json[@"groups"]) {
                
                //                NSLog(@"group = %@", group);
                [Group groupWithID:[group[@"id"] stringValue]
                              name:group[@"name"]
                              type:group[@"type"]
                          photoURL:group[@"photo_100"]];
            }
        }
        if (json[@"items"]) {
            for (NSDictionary * item in json[@"items"]) {
                NSMutableArray * mediaURLs = [NSMutableArray new];
                if ([item[@"type"] isEqualToString:@"post"]) {
                    //NSLog(@"item = %@", item);
                    NSArray * attachments = item[@"attachments"];
                    if (attachments.count > 0) {
                        for (NSArray * obj in attachments) {
                            if ([[obj valueForKey:@"type"] isEqualToString:@"photo"]) {
                                [mediaURLs addObject:[obj valueForKey:@"photo"]];
                            }
                        }
                    }
                    NSLog(@"MEDIA = %@", mediaURLs);
                    
                    [Item itemWithPostID:[item[@"post_id"] stringValue]
                                    date:[self dateFormatted:item[@"date"]]
                                    text:item[@"text"]
                                    type:item[@"type"]
                               mediaURLs:mediaURLs
                                   likes:[item[@"likes"][@"count"] stringValue]
                                reposted:[item[@"reposts"][@"count"] stringValue]
                                   owner:[item[@"source_id"] stringValue]];
                }
                
                if ([item[@"type"] isEqualToString:@"photo"]) {
                    
                    //                    [Item itemWithPostID:[item[@"id"] stringValue]
                    //                                    date:[self dateFormatted:item[@"date"]]
                    //                                    text:item[@"text"]
                    //                                    type:item[@"type"]
                    //                               mediaURLs:mediaURLs
                    //                                   likes:[item[@"likes"][@"count"] stringValue]
                    //                                reposted:[item[@"reposts"][@"count"] stringValue]
                    //                                   owner:[item[@"source_id"] stringValue]];
                }
            }
        }
    return YES;
}

+ (NSDate *)dateFormatted:(NSNumber*)time {
    return [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
}

@end
