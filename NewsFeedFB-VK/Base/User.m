//
//  User+CoreDataClass.m
//
//
//  Created by Viktoriia Vovk on 3/30/17.
//
//

#import "User.h"
#import "Item.h"
@implementation User

+ (User *) userWithID:(NSString *)userID
            firstName:(NSString *)firstName
             lastName:(NSString *)lastName
             isOnline:(NSNumber *)isOnline
       isMobileOnline:(NSNumber *)isMobileOnline
             photoURL:(NSString *)photoURL
{
    User * user = [User MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userID == %@", userID]];
    
    if (!user) {
        user = [User MR_createEntity];
    }
    user.userID = userID;
    user.firstName = firstName;
    user.lastName = lastName;
    user.photoURL = photoURL;
    user.isOnline = isOnline;
    user.isMobileOnline = isMobileOnline;
    
    return user;
}


@end
