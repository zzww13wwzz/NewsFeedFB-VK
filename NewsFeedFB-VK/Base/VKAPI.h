//
//  VKAPI.h
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/30/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKAPI : NSObject

//+ (void)getVKAccessTokenWithURL:(NSURL *)url
//                     completion:(void (^)(NSString * message))completion;
//
//+ (void)getJsonVKWithCompletion:(void (^)(NSError * error))completion;
+ (void)getDataWithCompletion:(void (^)(NSError * error))completion;
+ (BOOL)parseJson:(NSDictionary*)json;
+ (NSDate *)dateFormatted:(NSNumber*)time;
@end
