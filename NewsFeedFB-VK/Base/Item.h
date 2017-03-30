//
//  Item+CoreDataClass.h
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, NSObject, User;

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSManagedObject
+ (Item *) itemWithPostID:(NSString *)postID
                     date:(NSDate *)date
                     text:(NSString *)text
                     type:(NSString *)type
                mediaURLs:(NSArray *)mediaURLs
                    likes:(NSString *)likes
                 reposted:(NSString *)reposted
                    owner:(NSString *)owner;
@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"
