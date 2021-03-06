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
#import "Reachability.h"

@implementation VKAPI

+ (BOOL)isInternetAvailable {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)setupReachability {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (![[self class] isInternetAvailable]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_internet_connection_lost
                                                                object:nil];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)getUserWithUsersIDs:(NSString *)usersIDs
                 completion:(void (^)(NSArray * array))completion {
    VKRequest * getName = [VKRequest requestWithMethod:@"users.get" parameters:@{VK_API_USER_IDS : usersIDs}];
    [getName executeWithResultBlock:^(VKResponse * response) {
        if (response.json) {
            NSArray * array = response.json;
            PERFORM_BLOCK(completion, array);
        }
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
            PERFORM_BLOCK(completion, nil);
        }
    }];
}

+ (void)getDataWithCompletion:(void (^)(NSError * error))completion {
    
    VKRequest * getWall = [VKRequest requestWithMethod:@"newsfeed.get" parameters:@{VK_API_OWNER_ID : @"-1"}];
    
    [getWall executeWithResultBlock:^(VKResponse * response) {
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
    
    if (json[@"items"]) {
        for (NSDictionary * item in json[@"items"]) {
            NSMutableArray * mediaURLs = [NSMutableArray new];
            NSString * text = @"";
            NSString * likeCount = @"";
            NSString * reposted = @"";
            NSString * postID = [item[@"post_id"] stringValue];
            
            if ([item[@"type"] isEqualToString:@"post"]) {
                text = item[@"text"];
                likeCount = [item[@"likes"][@"count"] stringValue];
                reposted = [item[@"reposts"][@"count"] stringValue];
                
                NSArray * attachments = item[@"attachments"];
                if (attachments.count > 0) {
                    for (NSArray * obj in attachments) {
                        if ([[obj valueForKey:@"type"] isEqualToString:@"photo"]) {
                            [mediaURLs addObject:obj];
                        }
                    }
                }
                if (mediaURLs.count > 0) {
                    [Item itemWithPostID:postID
                                    date:[self dateFormatted:item[@"date"]]
                                    text:text
                                    type:item[@"type"]
                               mediaURLs:mediaURLs
                                   likes:likeCount
                                reposted:reposted
                                   owner:[item[@"source_id"] stringValue]];
                }
            } else {
                if ([item[@"type"] isEqualToString:@"photo"]) {
                    NSArray * photos = item[@"photos"];
                    if (photos.count > 0) {
                        for (NSArray * obj in item[@"photos"][@"items"]) {
                            [mediaURLs addObject:obj];
                            text = [obj valueForKey:@"text"];
                        }
                    }
                }
                if ([item[@"type"] isEqualToString:@"photo_tag"]) {
                    //NSString * text = @"";
                    NSArray * photos = item[@"photo_tags"];
                    if (photos.count > 0) {
                        for (NSArray * obj in item[@"photo_tags"][@"items"]) {
                            [mediaURLs addObject:obj];
                            text = [obj valueForKey:@"text"];
                        }
                    }
                }
                if ([item[@"type"] isEqualToString:@"wall_photo"]) {
                    NSArray * photos = item[@"photos"];
                    if (photos.count > 0) {
                        for (NSArray * obj in item[@"photos"][@"items"]) {
                            [mediaURLs addObject:obj];
                            text = [obj valueForKey:@"text"];
                        }
                    }
                }
                if ([item[@"type"] isEqualToString:@"friend"]) {
                    text = @"Added:";
                    postID = @"";
                    NSArray * friends = item[@"friends"];
                    if (friends.count > 0) {
                        for (NSArray * obj in item[@"friends"][@"items"]) {
                            [mediaURLs addObject:[[obj valueForKey:@"user_id"] stringValue]];
                        }
                    }
                }
                [Item itemWithPostID:postID
                                date:[self dateFormatted:item[@"date"]]
                                text:text
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:likeCount
                            reposted:reposted
                               owner:[item[@"source_id"] stringValue]];
            }
        }
    }
    if (json[@"profiles"]) {
        for (NSDictionary * profile in json[@"profiles"]) {
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
            [Group groupWithID:[group[@"id"] stringValue]
                          name:group[@"name"]
                          type:group[@"type"]
                      photoURL:group[@"photo_100"]];
        }
    }
    return YES;
}

+ (NSDate *)dateFormatted:(NSNumber*)time {
    return [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
}

@end
