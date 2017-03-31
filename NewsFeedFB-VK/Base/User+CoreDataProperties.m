//
//  User+CoreDataProperties.m
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic userID;
@dynamic firstName;
@dynamic lastName;
@dynamic isOnline;
@dynamic isMobileOnline;
@dynamic photoURL;
@dynamic hasItem;

@end
