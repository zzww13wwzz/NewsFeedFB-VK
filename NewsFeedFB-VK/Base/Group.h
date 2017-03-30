//
//  Group+CoreDataClass.h
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSManagedObject
+ (Group *) groupWithID:(NSString *)groupID
                   name:(NSString *)name
                   type:(NSString *)type
               photoURL:(NSString *)photoURL;
@end

NS_ASSUME_NONNULL_END

#import "Group+CoreDataProperties.h"
