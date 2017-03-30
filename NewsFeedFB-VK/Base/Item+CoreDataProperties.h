//
//  Item+CoreDataProperties.h
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "Item.h"


NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *postID;
@property (nullable, nonatomic, copy) NSString *owner;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, retain) NSObject *mediaURLs;
@property (nullable, nonatomic, copy) NSString *likes;
@property (nullable, nonatomic, copy) NSString *reposted;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, retain) User *hasUser;
@property (nullable, nonatomic, retain) Group *hasGroup;

@end

NS_ASSUME_NONNULL_END
