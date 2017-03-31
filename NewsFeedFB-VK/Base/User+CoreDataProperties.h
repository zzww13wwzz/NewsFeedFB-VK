//
//  User+CoreDataProperties.h
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "User.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *userID;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *isOnline;
@property (nullable, nonatomic, retain) NSNumber *isMobileOnline;
@property (nullable, nonatomic, copy) NSString *photoURL;
@property (nullable, nonatomic, retain) NSSet<Item *> *hasItem;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addHasItemObject:(Item *)value;
- (void)removeHasItemObject:(Item *)value;
- (void)addHasItem:(NSSet<Item *> *)values;
- (void)removeHasItem:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END
