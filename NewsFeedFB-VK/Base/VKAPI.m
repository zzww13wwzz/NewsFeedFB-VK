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

+ (void)getUserWithNameID:(NSString *)nameID
               completion:(void (^)(NSString * name))completion {
    VKRequest * getName = [VKRequest requestWithMethod:@"users.get" parameters:@{VK_API_USER_ID : nameID}];
    [getName executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        if (response.json) {
            
            NSString * name = @"";
            for (NSArray * info in response.json) {
                NSString *firstname = [info valueForKey:@"first_name"];
                NSString *lastName = [info valueForKey:@"last_name"];
                name = [NSString stringWithFormat:@"%@ %@ %@;",name, firstname, lastName];
            }
            PERFORM_BLOCK(completion, name);
        }
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
            PERFORM_BLOCK(completion, nameID);
        }
    }];
}

+ (void)getVideoWithAccess:(NSString *)accessKey
                completion:(void (^)(NSArray * json))completion {
    VKRequest * getName = [VKRequest requestWithMethod:@"video.get" parameters:@{VK_API_ACCESS_KEY : accessKey}];
    [getName executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        if (response.json) {
            //            NSArray * userInfo = response.json;
            //            NSString * name = [NSString stringWithFormat:@"%@ %@", [userInfo valueForKey:@"first_name"], [userInfo valueForKey:@"last_name"]];
            PERFORM_BLOCK(completion, response.json);
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
        //NSLog(@"Json result: %@", response.json);
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
            
            if ([item[@"type"] isEqualToString:@"post"]) {
                NSArray * attachments = item[@"attachments"];
                if (attachments.count > 0) {
                    for (NSArray * obj in attachments) {
                        if (![[obj valueForKey:@"type"] isEqualToString:@"photo"] &&
                            [[obj valueForKey:@"type"] isEqualToString:@"video"] &&
                            [[obj valueForKey:@"type"] isEqualToString:@"link"]) {
                            
                        }
                        
                        [mediaURLs addObject:obj];
                    }
                }
                if (mediaURLs.count == 0) {
                    NSLog(@"AHTUNG!!!post");
                }
                
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
                NSString * text = @"";
                NSArray * photos = item[@"photos"];
                if (photos.count > 0) {
                    for (NSArray * obj in item[@"photos"][@"items"]) {
                        [mediaURLs addObject:obj];
                        text = [obj valueForKey:@"text"];
                    }
                }
                
                if (mediaURLs.count == 0) {
                    NSLog(@"AHTUNG!!!photo");
                }
                [Item itemWithPostID:[item[@"post_id"] stringValue]
                                date:[self dateFormatted:item[@"date"]]
                                text:text
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:@""
                            reposted:@""
                               owner:[item[@"source_id"] stringValue]];
            }
            if ([item[@"type"] isEqualToString:@"photo_tag"]) {
                NSString * text = @"";
                NSArray * photos = item[@"photo_tags"];
                if (photos.count > 0) {
                    for (NSArray * obj in item[@"photo_tags"][@"items"]) {
                        [mediaURLs addObject:obj];
                        text = [obj valueForKey:@"text"];
                    }
                }
                if (mediaURLs.count == 0) {
                    NSLog(@"AHTUNG!!!photo_tag");
                }
                
                [Item itemWithPostID:[item[@"post_id"] stringValue]
                                date:[self dateFormatted:item[@"date"]]
                                text:text
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:@""
                            reposted:@""
                               owner:[item[@"source_id"] stringValue]];
            }
            if ([item[@"type"] isEqualToString:@"wall_photo"]) {
                NSString * text = @"";
                NSArray * photos = item[@"photos"];
                if (photos.count > 0) {
                    for (NSArray * obj in item[@"photos"][@"items"]) {
                        [mediaURLs addObject:obj];
                        text = [obj valueForKey:@"text"];
                    }
                }
                if (mediaURLs.count == 0) {
                    NSLog(@"AHTUNG!!!wall_photo");
                }
                
                [Item itemWithPostID:[item[@"post_id"] stringValue]
                                date:[self dateFormatted:item[@"date"]]
                                text:text
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:@""
                            reposted:@""
                               owner:[item[@"source_id"] stringValue]];
            }
            if ([item[@"type"] isEqualToString:@"friend"]) {
                
                NSArray * friends = item[@"friends"];
                if (friends.count > 0) {
                    for (NSArray * obj in item[@"friends"][@"items"]) {
                        [mediaURLs addObject:[[obj valueForKey:@"user_id"] stringValue]];
                    }
                }
                
                if (mediaURLs.count == 0) {
                    NSLog(@"AHTUNG!!!friend");
                }

                [Item itemWithPostID:@""
                                date:[self dateFormatted:item[@"date"]]
                                text:@"Added:"
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:@""
                            reposted:@""
                               owner:[item[@"source_id"] stringValue]];
            }
            if ([item[@"type"] isEqualToString:@"note"]) {
                /*
                 NSArray * photos = item[@"photos"];
                 if (photos.count > 0) {
                 for (NSArray * obj in item[@"photos"][@"items"]) {
                 [mediaURLs addObject:obj];
                 }
                 }
                 
                 [Item itemWithPostID:[item[@"post_id"] stringValue]
                 date:[self dateFormatted:item[@"date"]]
                 text:@""
                 type:item[@"type"]
                 mediaURLs:mediaURLs
                 likes:@""
                 reposted:@""
                 owner:[item[@"source_id"] stringValue]];
                 */
            }
            if ([item[@"type"] isEqualToString:@"audio"]) {
                
                NSArray * audio = item[@"audio"];
                if (audio.count > 0) {
                    for (NSArray * obj in item[@"audio"][@"items"]) {
                        [mediaURLs addObject:obj];
                    }
                }
                
                [Item itemWithPostID:[item[@"post_id"] stringValue]
                                date:[self dateFormatted:item[@"date"]]
                                text:@""
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:@""
                            reposted:@""
                               owner:[item[@"source_id"] stringValue]];
                
            }
            if ([item[@"type"] isEqualToString:@"video"]) {
                
                NSArray * video = item[@"video"];
                if (video.count > 0) {
                    for (NSArray * obj in item[@"video"][@"items"]) {
                        [mediaURLs addObject:obj];
                    }
                }
                
                if (mediaURLs.count == 0) {
                    NSLog(@"AHTUNG!!!video");
                }
                
                [Item itemWithPostID:@""
                                date:[self dateFormatted:item[@"date"]]
                                text:@""
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:@""
                            reposted:@""
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
