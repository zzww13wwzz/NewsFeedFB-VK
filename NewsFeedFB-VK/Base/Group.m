//
//  Group+CoreDataClass.m
//
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "Group.h"
#import "Item.h"
@implementation Group

+ (Group *) groupWithID:(NSString *)groupID
                   name:(NSString *)name
                   type:(NSString *)type
               photoURL:(NSString *)photoURL
{
    Group * group = [Group MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"groupID == %@", groupID]];
    
    if (!group) {
        group = [Group MR_createEntity];
    }
    group.groupID = groupID;
    group.name = name;
    if (photoURL) {
        group.photoURL = photoURL;
    }
    group.type = type;
    
    return group;
}

@end
