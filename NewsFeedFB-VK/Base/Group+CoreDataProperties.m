//
//  Group+CoreDataProperties.m
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "Group+CoreDataProperties.h"

@implementation Group (CoreDataProperties)

+ (NSFetchRequest<Group *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Group"];
}

@dynamic groupID;
@dynamic name;
@dynamic type;
@dynamic photoURL;
@dynamic hasItem;

@end
