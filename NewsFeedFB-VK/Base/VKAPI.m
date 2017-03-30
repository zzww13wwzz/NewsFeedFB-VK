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


@implementation VKAPI

- (void)getVKAccessTokenWithURL:(NSURL *)url
                     completion:(void (^)(NSString * message))completion
{
    NSString *currentURL = url.absoluteString;
    NSRange textRange =[[currentURL lowercaseString] rangeOfString:[@"access_token" lowercaseString]];
    
    if(textRange.location != NSNotFound) {
        NSArray* data = [currentURL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:[data objectAtIndex:1] forKey:@"VKAccessToken"];
        [[NSUserDefaults standardUserDefaults] setObject:[data objectAtIndex:5] forKey:@"VKAccessUserId"];
        
        PERFORM_BLOCK(completion, nil);
        
    } else {
        textRange =[[currentURL lowercaseString] rangeOfString:[@"access_denied" lowercaseString]];
        
        if (textRange.location != NSNotFound) {
            PERFORM_BLOCK(completion, @"Access denied.");
        }
    }
}

- (void)getJsonVKWithCompletion:(void (^)(NSError * error))completion {
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"];
    
    NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/newsfeed.get?PARAMETERS&access_token=%@&v=5.63", token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&responseCode
                                                              error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        PERFORM_BLOCK(completion, error);
    }
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:kNilOptions
                                                           error:&error];
    [self parserJson:json];
    
    if (error) {
        PERFORM_BLOCK(completion, error);
    } else {
        PERFORM_BLOCK(completion, nil);
    }
    //NSString * new = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}


- (void)parserJson:(NSDictionary *)json {
    //    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    //    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy";
    //    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    //
    //    BOOL isPhoto = NO;
    //    NSMutableArray * mediaUrls = [NSMutableArray new];
    
    //    if (tweet[@"extended_entities"]) {
    //        if (tweet[@"extended_entities"][@"media"]) {
    //            for (NSDictionary *media in tweet[@"extended_entities"][@"media"]) {
    //
    //                isPhoto = [media[@"type"] isEqualToString:@"photo"];
    //                if (isPhoto) {
    //                    NSString * url = media[@"media_url_https"];
    //                    [mediaUrls addObject:url];
    //                } else {
    //                    NSArray * variants = media[@"video_info"][@"variants"];
    //                    for (NSArray * var in variants) {
    //                        if ([[var valueForKey:@"content_type"] isEqualToString:@"video/mp4"]) {
    //                            [mediaUrls addObject:[var valueForKey:@"url"]];
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    if (json[@"response"]) {
        for (NSDictionary * profile in json[@"response"][@"profiles"]) {
            NSLog(@"profile = %@", profile);
            NSNumber * isMobileOnline = false;
            if (profile[@"online_mobile"]) {
                isMobileOnline = profile[@"online_mobile"];
            }
            
            [User userWithID:[profile[@"id"] stringValue]
                   firstName:profile[@"first_name"]
                    lastName:profile[@"last_name"]
                    isOnline:profile[@"online"]
              isMobileOnline:isMobileOnline
                    photoURL:profile[@"photo_100"]
                   accessKey:@""];
        }
        for (NSDictionary * group in json[@"response"][@"groups"]) {
            NSLog(@"group = %@", group);
            [Group groupWithID:[group[@"id"] stringValue]
                          name:group[@"name"]
                          type:group[@"type"]
                      photoURL:group[@"photo_100"]];
        }
        for (NSDictionary * item in json[@"response"][@"items"]) {
            NSArray * mediaURLs = nil;
            if (item[@"attachments"]) {
                if ([item[@"attachments"][@"type"] isEqualToString:@"photo"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"posted_photo"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"video"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"audio"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"doc"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"graffiti"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"link"]) {
                    //mediaURLs =item[@"attachments"][@"link"];
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"note"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"app"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"poll"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"page"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"album"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"photos_list"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"market"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"market_album"]) {
                    
                } else if ([item[@"attachments"][@"type"] isEqualToString:@"sticker"]) {
                    
                }
                
                
            }
            NSLog(@"groitemup = %@", item);
            if ([item[@"type"] isEqualToString:@"post"]) {
                [Item itemWithPostID:[item[@"post_id"] stringValue]
                                date:[self dateFormatted:item[@"date"]]
                                text:item[@"text"]
                                type:item[@"type"]
                           mediaURLs:mediaURLs
                               likes:item[@"likes"][@"count"]
                            reposted:item[@"reposts"][@"count"]
                               owner:item[@"source_id"]];
            }
            if ([item[@"type"] isEqualToString:@"photo"]) {
                
            }
            if ([item[@"type"] isEqualToString:@"photo_tag"]) {
                
            }
            if ([item[@"type"] isEqualToString:@"wall_photo"]) {
                
            }
            
            if ([item[@"type"] isEqualToString:@"friend"]) {
                
            }
            
            if ([item[@"type"] isEqualToString:@"note"]) {
                
            }
            
            if ([item[@"type"] isEqualToString:@"audio"]) {
                
            }
            
            if ([item[@"type"] isEqualToString:@"video"]) {
                
            }
            
            
            
            //            post — новые записи со стен;
            //            photo — новые фотографии;
            //            photo_tag — новые отметки на фотографиях;
            //            wall_photo — новые фотографии на стенах;
            //            friend — новые друзья;
            //            note — новые заметки;
            //            audio — записи сообществ и друзей, содержащие аудиозаписи, а также новые аудиозаписи, добавленные ими;
            //            video — новые видеозаписи.
            
            //            if (item[@"attachments"]) {
            //
            //            }
            
            
            //            [Item itemWithPostID:item[@"post_id"]
            //                            date:item[@"date"]
            //                            text:item[@"text"]
            //                            type:item[@"type"]
            //                       mediaURLs:item[@""]
            //                           likes:item[@"likes"][@"count"]
            //                        reposted:item[@"reposts"][@"count"]
            //                           owner:item[@""]];
        }
        
    }
    
}

- (NSDate *)dateFormatted:(NSNumber*)time {
    return [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
}

@end
