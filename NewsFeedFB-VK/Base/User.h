//
//  User+CoreDataClass.h
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

+ (User *) userWithID:(NSString *)userID
            firstName:(NSString *)firstName
             lastName:(NSString *)lastName
             isOnline:(NSNumber *)isOnline
       isMobileOnline:(NSNumber *)isMobileOnline
             photoURL:(NSString *)photoURL
            accessKey:(NSString *)accessKey;
@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
