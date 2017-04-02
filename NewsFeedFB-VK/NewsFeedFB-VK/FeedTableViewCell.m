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

@interface  FeedTableViewCell ()<UIGestureRecognizerDelegate> {
    UITapGestureRecognizer *tap;
    BOOL isFullScreen;
    CGRect prevFrame;
}

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet FRHyperLabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostLabel;

@end

@implementation FeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //    isFullScreen = false;
    //    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgToFullScreen)];
    //    tap.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:false animated:false];
    
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
//{
//    BOOL shouldReceiveTouch = YES;
//
//    if (gestureRecognizer == tap) {
//        shouldReceiveTouch = (touch.view == yourImageView);
//    }
//    return shouldReceiveTouch;
//}
//
//
//-(void)imgToFullScreen{
//    if (!isFullScreen) {
//        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
//            //save previous frame
//            prevFrame = yourImageView.frame;
//            [yourImageView setFrame:[[UIScreen mainScreen] bounds]];
//        }completion:^(BOOL finished){
//            isFullScreen = true;
//        }];
//        return;
//    } else {
//        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
//            [yourImageView setFrame:prevFrame];
//        }completion:^(BOOL finished){
//            isFullScreen = false;
//        }];
//        return;
//    }
//}

- (void) setItem:(Item *)item
{
    _item = item;
    
    [self fillOwnerInfo];
    [self fillLikeAndRepostInfo];
    [self fillTextInfoOfPost];
    
    if ((_item.mediaURLs.count == 0) && (!ValidString(_item.text))) {
        _infoView.hidden = YES;
    }
    
    //    if (_item.mediaURLs.count > 0) {
    //        CGFloat viewHeight = _infoLabel.frame.size.height;
    //        for (NSArray * link in _item.mediaURLs) {
    //            CGRect infoFrame = _infoLabel.frame;
    //            CGFloat height = [[link valueForKey:@"height"] floatValue];
    //
    //            CGRect frame = CGRectMake(infoFrame.origin.x,
    //                                      infoFrame.size.height + infoFrame.size.height * [_item.mediaURLs indexOfObject:link] +10,
    //                                      infoFrame.size.width,
    //                                      height);
    //
    //            UIImageView *view =[[UIImageView alloc] initWithFrame:frame];
    //            view.contentMode = UIViewContentModeScaleAspectFit;
    //            [view sd_setImageWithURL:[NSURL URLWithString:[link valueForKey:@"photo_604"]]];
    //            viewHeight = viewHeight + height;
    //            [_infoView addSubview:view];
    //        }
    //        _infoView.frame = CGRectMake(_infoView.frame.origin.x,
    //                                     _infoView.frame.origin.y,
    //                                     _infoView.frame.size.width,
    //                                     viewHeight);
    //
    //    }
}

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

- (void)fillTextInfoOfPost {
    if (!ValidString(_item.text)) {
        _infoLabel.hidden = YES;
    } else {
        _infoLabel.frame  = CGRectMake(_infoLabel.frame.origin.x,
                                       _infoLabel.frame.origin.y,
                                       _infoLabel.frame.size.width,
                                       [self optimizationInfoTexteHeight]);
        
        NSString * match = [self parserMessageForLink];
        
        if (ValidString(match)) {
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]};
            
            _infoLabel.attributedText = [[NSAttributedString alloc]initWithString:_item.text attributes:attributes];
            
            [_infoLabel setLinkForSubstring:match withLinkHandler:^(FRHyperLabel *label, NSString *substring){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:match]];
            }];
        } else {
            _infoLabel.text = _item.text;
        }
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

void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
    NSLog(@"Selected: %@", substring);
};

@end
