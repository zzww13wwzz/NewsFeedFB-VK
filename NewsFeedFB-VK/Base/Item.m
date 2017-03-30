//
//  Item+CoreDataClass.m
//
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "Item.h"
#import "Group.h"
#import "User.h"
@implementation Item


+ (Item *) itemWithPostID:(NSString *)postID
                     date:(NSDate *)date
                     text:(NSString *)text
                     type:(NSString *)type
                mediaURLs:(NSArray *)mediaURLs
                    likes:(NSString *)likes
                 reposted:(NSString *)reposted
                    owner:(NSString *)owner
{
    Item * item = [Item MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"postID == %@", postID]];
    
    if (!item) {
        item = [Item MR_createEntity];
    }
    item.postID = postID;
    item.date = date;
    item.type = type;
    item.mediaURLs = mediaURLs;
    item.text = text;
    item.likes = likes;
    item.reposted = reposted;
    item.owner = owner;

    return item;
}


@end
