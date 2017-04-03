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
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;

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
    _moreLabel.hidden = YES;

    [self fillOwnerInfo];
    [self fillLikeAndRepostInfo];
    [self fillTextInfoOfPost];
}


# pragma mark - fillTextInfoOfPost

- (void)fillTextInfoOfPost {
//    if ( _infoView.subviews.count > 0) {
//        for (UIImageView *view in [_infoView subviews]){
//            [view removeFromSuperview];
//        }
//        for (UILabel *view in [_infoView subviews]){
//            [view removeFromSuperview];
//        }
//    }
    
    _infoLabel.text = _item.text;
    NSArray * arr = _item.mediaURLs;
    if ((_item.mediaURLs.count > 1) ||
        ([_item.type isEqualToString:@"video"]) ||
        ([_item.type isEqualToString:@"audio"])){
        _moreLabel.hidden = NO;
    } else {
        _moreLabel.hidden = YES;
    }
    
    if (_item.mediaURLs.count > 0) {
        NSLog(@"_item.type = %@", _item.type);
        NSURL * url = nil;
        if ([_item.type isEqualToString:@"post"] ||
            [_item.type isEqualToString:@"photo"] ||
            [_item.type isEqualToString:@"wall_photo"] ||
            [_item.type isEqualToString:@"photo_tag"]) {

            
            NSArray * link = [self.item.mediaURLs objectAtIndex:0];
            if ([[link valueForKey:@"type"] isEqualToString:@"photo"]) {
                
                NSArray *data = [link valueForKey:@"photo"];
                url = [NSURL URLWithString:[data valueForKey:@"photo_604"]];
//                CGRect frame = CGRectMake(0,
//                                          0,
//                                          self.frame.size.width - _infoView.frame.origin.x*2,
//                                          _infoView.frame.size.height);
//                
//                UIImageView *view =[[UIImageView alloc] initWithFrame:frame];
//                view.contentMode = UIViewContentModeScaleAspectFit;
                [_postImageView sd_setImageWithURL:url];
//                [_infoView addSubview:view];
            }
            
//            if ([[link valueForKey:@"type"] isEqualToString:@"doc"]) {
//                
//                UILabel * gif = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - _infoView.frame.origin.x*2, 40)];
//                gif.textAlignment = NSTextAlignmentCenter;
//                gif.text = @"Tap to see gif";
//                [_infoView addSubview:gif];
//                self.mediaContentViewConstraint.constant = 40;
////                NSArray * fields = [link valueForKey:@"doc"];
////                NSString * gifLink = [fields valueForKey:@"url"];
////                
////                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:gifLink]]];
////                FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
////                imageView.animatedImage = image;
////                CGRect frame = CGRectMake(0,
////                                          0,
////                                          self.frame.size.width - _infoView.frame.origin.x*2,
////                                          _infoView.frame.size.height);
////                
////                imageView.frame = frame;
////                [_infoView addSubview:imageView];
//            }
            if ([_item.type isEqualToString:@"wall_photo"]){
                NSLog(@"%@", _item);
                url = [NSURL URLWithString:[link valueForKey:@"photo_604"]];
//                CGRect frame = CGRectMake(0,
//                                          0,
//                                          self.frame.size.width - _infoView.frame.origin.x*2,
//                                          _infoView.frame.size.height);
//                
//                UIImageView *view =[[UIImageView alloc] initWithFrame:frame];
//                view.contentMode = UIViewContentModeScaleAspectFit;
//                [view sd_setImageWithURL:url];
//                [_infoView addSubview:view];
                [self.postImageView sd_setImageWithURL:url];
            }
            
            if ([[link valueForKey:@"type"] isEqualToString:@"video"] || [[link valueForKey:@"type"] isEqualToString:@"link"] || [[link valueForKey:@"type"] isEqualToString:@"doc"]) {
                _moreLabel.hidden = NO;
                _infoView.hidden = YES;
                self.mediaContentViewConstraint.constant = 0;
                
            }
        }
        //        if ([_item.type isEqualToString:@"video"]) {
        //            NSLog(@"%@", _item);
        //            NSString *accessKey = @"";
        //            for (NSArray * arr in self.item.mediaURLs) {
        //                _infoLabel.text = [arr valueForKey:@"description"];
        //                accessKey = [arr valueForKey:@"access_key"];
        //
        //                [VKAPI getVideoWithAccess:accessKey completion:^(NSArray *json) {
        //                    NSLog(@"ARRAY = %@", json);
        //                }];
        //            }
        //        }
        
        if ([_item.type isEqualToString:@"friend"]) {
            NSLog(@"%@", _item);
            for (NSString * nameID in _item.mediaURLs) {
                [VKAPI getUserWithNameID:nameID completion:^(NSString *name) {
                    _infoLabel.text = [NSString stringWithFormat:@"%@ %@" , _item.text, name];
                }];
            }
        }
        
        if (([_item.type isEqualToString:@"video"]) ||
            ([_item.type isEqualToString:@"audio"])) {
            _infoView.hidden = YES;
            self.mediaContentViewConstraint.constant = 0;
        } else {
            _infoView.hidden = NO;
        }
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

@end
