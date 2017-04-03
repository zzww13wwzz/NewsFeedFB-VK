//
//  VKAPI.h
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/30/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface VKAPI : NSObject

+ (BOOL)isInternetAvailable;
+ (void)setupReachability;

+ (void)getDataWithCompletion:(void (^)(NSError * error))completion;
+ (BOOL)parseJson:(NSDictionary*)json;
+ (NSDate *)dateFormatted:(NSNumber*)time;
+ (void)getUserWithNameID:(NSString *)nameID
               completion:(void (^)(NSString * name))completion;

@end
