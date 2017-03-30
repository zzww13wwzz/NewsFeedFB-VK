//
//  Item+CoreDataProperties.m
//  
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Item"];
}

@dynamic type;
@dynamic postID;
@dynamic text;
@dynamic mediaURLs;
@dynamic likes;
@dynamic reposted;
@dynamic date;
@dynamic hasUser;
@dynamic hasGroup;
@dynamic owner;

@end
