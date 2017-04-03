//
//  FeedTableViewCell.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/30/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "FeedTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FRHyperLabel.h"
#import <VKSdk.h>

@interface  FeedTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet FRHyperLabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaContentViewConstraint;

@end

@implementation FeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:false animated:false];
    
}

- (void) setItem:(Item *)item {
    _item = item;
    
    [self fillOwnerInfo];
    [self fillLikeAndRepostInfo];
    [self fillTextInfoOfPost];
    
    

    
    
//            if ([_item.type isEqualToString:@"post"]) {
//                for (int i = 0; i < _item.mediaURLs.count; i++) {
//                    NSArray * link = [self.item.mediaURLs objectAtIndex:i];
//                    if ([[link valueForKey:@"type"] isEqualToString:@"photo"]) {
//                        NSArray *data = [link valueForKey:@"photo"];
//                        [[_infoView.subviews objectAtIndex:i] sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"photo_604"]]];
//                    }
//                    if ([[link valueForKey:@"type"] isEqualToString:@"link"]) {
//                        //                    NSArray *data = [link valueForKey:@"link"];
//                    }
//    
//                }
//            }
    //        for (NSArray * link in _item.mediaURLs) {
    //                if ([[link valueForKey:@"type"] isEqualToString:@"video"]) {
    //                    //                    NSArray *data = [link valueForKey:@"video"];
    //                }
    //                if ([[link valueForKey:@"type"] isEqualToString:@"link"]) {
    //                    //                    NSArray *data = [link valueForKey:@"link"];
    //                }
    
    //            if ([[link valueForKey:@"type"] isEqualToString:@"photo"]) {
    //                NSArray *data = [link valueForKey:@"photo"];
    //                NSUInteger index = [self.item.mediaURLs indexOfObject:link];
    //                [[_infoView.subviews objectAtIndex:index] sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"photo_604"]]];
    //                //                    [view sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"photo_604"]]];
    //
    //
    //
    //            }
    
    
    //                    NSArray *data = [link valueForKey:@"photo"];
    
    //NSString * text = [data valueForKey:@"text"];
    //    [self imageViewCreator:[link valueForKey:@"photo"] withSize:@"604"];
    //                    NSUInteger index = [self.item.mediaURLs indexOfObject:link];
    //                    if(NSNotFound == index) {
    //                    [self imageViewCreator:[link valueForKey:@"photo"] withSize:@"604" withCount:_item.mediaURLs.count];
    //                    } else {
    //                        [self imageViewCreator:[link valueForKey:@"photo"] withSize:@"604" withIndex:index];
    
    //        }
    
    
    
    //    }
}


# pragma mark - fillTextInfoOfPost

- (void)fillTextInfoOfPost {

    _infoLabel.text = _item.text;
    
    if (_item.mediaURLs.count > 1) {
        _moreLabel.hidden = NO;
    }

    if ( _infoView.subviews.count > 0) {
        for (UIImageView *view in [_infoView subviews]){
            [view removeFromSuperview];
        }
    }
    if (_item.mediaURLs.count > 0) {

        NSURL * url = nil;
        if ([_item.type isEqualToString:@"post"] ||
            [_item.type isEqualToString:@"photo"] ||
            [_item.type isEqualToString:@"wall_photo"] ||
            [_item.type isEqualToString:@"photo_tag"]) {
            NSArray * link = [self.item.mediaURLs objectAtIndex:0];
            if ([[link valueForKey:@"type"] isEqualToString:@"photo"]) {
                NSArray *data = [link valueForKey:@"photo"];
                url = [NSURL URLWithString:[data valueForKey:@"photo_604"]];
                CGRect frame = CGRectMake(0,
                                          0,
                                          self.frame.size.width - _infoView.frame.origin.x*2,
                                          _infoView.frame.size.height);
                
                UIImageView *view =[[UIImageView alloc] initWithFrame:frame];
                view.contentMode = UIViewContentModeScaleAspectFit;
                view.backgroundColor = [UIColor redColor];
                [view sd_setImageWithURL:url];
                [_infoView addSubview:view];
            }
        }
        if ([_item.type isEqualToString:@"video"]) {
            NSLog(@"%@", _item);
            NSString *accessKey = @"";
            for (NSArray * arr in self.item.mediaURLs) {
                _infoLabel.text = [arr valueForKey:@"description"];
                accessKey = [arr valueForKey:@"access_key"];
                [VKAPI getVideoWithAccess:accessKey completion:^(NSArray *json) {
                    NSLog(@"ARRAY = %@", json);
                }];
            }
            
//            NSArray *data = [link valueForKey:@"photo"];
//            url = [NSURL URLWithString:[data valueForKey:@"photo_604"]];
        }
        
        
        
        if ([_item.type isEqualToString:@"friend"]) {
            NSLog(@"%@", _item);
            for (NSString * nameID in _item.mediaURLs) {
                [VKAPI getUserWithNameID:nameID completion:^(NSString *name) {
                    _item.text = [NSString stringWithFormat:@"%@ %@" , _item.text, name];
                }];
            }
            _infoLabel.text = _item.text;
            
            
        }
        
        
        _infoView.hidden = NO;
       
    } else {
        _infoView.hidden = YES;
        self.mediaContentViewConstraint.constant = 0;
    }
}

- (NSString *)parserMessageForLink {
    NSString *match = nil;
    NSString * source = _item.text;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"
                                                                                options:NSRegularExpressionCaseInsensitive error:NULL];
    
    if (!(([expression rangeOfFirstMatchInString:source options:NSMatchingReportCompletion range:NSMakeRange(0, [source length])]).location == NSNotFound)) {
        match = [source substringWithRange:[expression rangeOfFirstMatchInString:source options:NSMatchingReportCompletion range:NSMakeRange(0, [source length])]];
    }
    
    return match;
}

- (CGFloat)optimizationInfoTexteHeight {
    CGSize constraint = CGSizeMake(_infoLabel.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [_infoLabel.text boundingRectWithSize:constraint
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:_infoLabel.font}
                                                       context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
    NSLog(@"Selected: %@", substring);
};


# pragma mark - fillOwnerInfo

- (void)fillOwnerInfo {
    NSString *imageLink = nil;
    
    if (([_item.owner rangeOfString:@"-"].location == NSNotFound)) {
        User * owner = [User MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userID == %@", _item.owner]];
        imageLink = owner.photoURL;
        _nameLabel.text = [NSString stringWithFormat:@"%@ %@", owner.firstName, owner.lastName];
        
    } else {
        NSString *ownerID = [_item.owner stringByReplacingOccurrencesOfString:@"-" withString:@""];
        Group * owner = [Group MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"groupID == %@", ownerID]];
        imageLink = owner.photoURL;
        _nameLabel.text = owner.name;
    }
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"h:mm a - dd MMM yyyy";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    _timeLabel.text = [dateFormatter stringFromDate:_item.date];
    
    _titleImageView.layer.cornerRadius = _titleImageView.frame.size.height /2;
    _titleImageView.layer.masksToBounds = YES;
    _titleImageView.layer.borderWidth = 0;
    
    if (ValidString(imageLink)) {
        [_titleImageView sd_setImageWithURL:[NSURL URLWithString:imageLink]
                           placeholderImage:nil];
    }
    else {
        _titleImageView.backgroundColor = [UIColor grayColor];
    }
}

# pragma mark - fillLikeAndRepostInfo

- (void)fillLikeAndRepostInfo {
    if ((![_item.likes isEqualToString:@""]) && (![_item.reposted isEqualToString:@""])){
        _likeLabel.text = [NSString stringWithFormat:@"%@ likes", _item.likes];
        _repostLabel.text = [NSString stringWithFormat:@"%@ reposted", _item.reposted];
    } else {
        _bottomView.hidden = YES;
        _bottomView.frame = CGRectMake(_bottomView.frame.origin.x,
                                       _bottomView.frame.origin.y,
                                       _bottomView.frame.size.width,
                                       0);
    }
}



//- (void)imageViewCreator:(NSArray*)link
//                withSize:(NSString *)size
//               withCount:(NSUInteger)count
//{
//
//    CGRect infoFrame = _infoView.frame;
//    CGFloat height = [[link valueForKey:@"height"] floatValue];
//    //CGFloat width = [[link valueForKey:@"width"] floatValue];
//    if (height > infoFrame.size.width) {
//        height = infoFrame.size.width;
//    }
//
//    //    CGRect lastObjFrame =  [_infoView.subviews lastObject].frame;
//    if (count == 1) {
//        CGRect frame = CGRectMake(infoFrame.origin.x,
//                                  height *_infoView.subviews.count,
//                                  infoFrame.size.width - infoFrame.origin.x*2,
//                                  height);
//    } else if (count >1 && count<5) {
//
//    }
//
//    CGRect frame = CGRectMake(infoFrame.origin.x,
//                              height *_infoView.subviews.count,
//                              infoFrame.size.width - infoFrame.origin.x*2,
//                              height);
//
//
//    UIImageView *view =[[UIImageView alloc] initWithFrame:frame];
//    view.contentMode = UIViewContentModeScaleAspectFit;
//    view.backgroundColor = [UIColor redColor];
//    //    [view sd_setImageWithURL:[NSURL URLWithString:[link valueForKey:[NSString stringWithFormat:@"photo_%@", size]]]];
//
//    [_infoView addSubview:view];
//}
/*
 - (void)createImageViewWithCount:(NSUInteger) count {
 CGRect frame = _infoView.frame;
 int divisorX = 1;
 int divisorY = 1;
 
 if (count == 2) {
 divisorX = 2;
 } else if ((count > 2) && (count < 5)) {
 divisorX = 2;
 divisorY = 2;
 } else if ((count > 4) && (count < 7)) {
 divisorX = 3;
 divisorY = 2;
 } else if ((count > 6) && (count < 9)) {
 divisorX = 4;
 divisorY = 2;
 } else {
 divisorX = 5;
 divisorY = 2;
 }
 
 
 for (int i = 0; i < count; i++) {
 CGFloat width = _infoView.frame.size.width / divisorX;
 CGFloat height = _infoView.frame.size.height / divisorY;
 
 
 frame = CGRectMake(0 + i * width,
 i * height,
 width,
 height);
 
 UIImageView *view =[[UIImageView alloc] initWithFrame:frame];
 view.contentMode = UIViewContentModeScaleAspectFit;
 [_infoView addSubview:view];
 }
 
 
 //    for (int i = 1; i < count+1; i++) {
 //        frame = CGRectMake(0,
 //                           (_infoView.frame.size.height) * count,
 //                           self.frame.size.width - _infoView.frame.origin.x*2,
 //                           _infoView.frame.size.height);
 //    }
 //    frame = CGRectMake(0,
 //                       (_infoView.frame.size.height) * count,
 //                       self.frame.size.width - _infoView.frame.origin.x*2,
 //                       _infoView.frame.size.height);
 //
 //    frame = CGRectMake(0,
 //                       (_infoView.frame.size.height) * count,
 //                       self.frame.size.width - _infoView.frame.origin.x*2,
 //                       _infoView.frame.size.height);
 
 
 }*/



//            if ([_item.type isEqualToString:@"photo"]) {
//                heightContent = [self imageViewCreator:[link valueForKey:@"photo"] withSize:@"604"];
//            }
//            if ([_item.type isEqualToString:@"photo_tag"]) {
//                heightContent = [self imageViewCreator:[link valueForKey:@"photo"] withSize:@"604"];
//            }
//            if ([_item.type isEqualToString:@"wall_photo"]) {
//                heightContent = [self imageViewCreator:[link valueForKey:@"photo"] withSize:@"604"];
//            }
//            if ([_item.type isEqualToString:@"friend"]) {
//                NSLog(@"%@", _item);
//                NSLog(@"%@", link);
//                for (NSString * nameID in _item.mediaURLs) {
//                    [VKAPI getUserWithNameID:nameID completion:^(NSString *name) {
//                        _item.text = [NSString stringWithFormat:@"%@ %@" , _item.text, name];
//                    }];
//                }
//
//
//            }
//            if ([_item.type isEqualToString:@"audio"]) {
//
//            }
//            if ([_item.type isEqualToString:@"video"]) {
//                heightContent = [self imageViewCreator:link withSize:@"640"];
//
//            }
//            if ([_item.type isEqualToString:@"note"]) {
//
//            }
//}
//        heightContent = _item.mediaURLs.count * heightContent;

//        _infoView.frame = CGRectMake(_infoView.frame.origin.x,
//                                     _infoView.frame.origin.y,
//                                     _infoView.frame.size.width,
//                                     heightContent);

//self.mediaContentViewConstraint.constant = [_infoView.subviews lastObject].frame.size.height * _infoView.subviews.count;

//}

@end
