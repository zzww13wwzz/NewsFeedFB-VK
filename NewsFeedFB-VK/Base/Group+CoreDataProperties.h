//
//  Group+CoreDataProperties.h
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "Group.h"


NS_ASSUME_NONNULL_BEGIN

@interface Group (CoreDataProperties)

+ (NSFetchRequest<Group *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *groupID;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *photoURL;
@property (nullable, nonatomic, retain) NSSet<Item *> *hasItem;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addHasItemObject:(Item *)value;
- (void)removeHasItemObject:(Item *)value;
- (void)addHasItem:(NSSet<Item *> *)values;
- (void)removeHasItem:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END
