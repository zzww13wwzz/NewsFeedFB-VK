//
//  FeedTableViewCell.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/30/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "FeedTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface  FeedTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostLabel;

@end

@implementation FeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:false animated:false];
    
}

- (void) setItem:(Item *)item
{
    _item = item;
    
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
    _likeLabel.text = [NSString stringWithFormat:@"%@ likes", _item.likes];
    _repostLabel.text = [NSString stringWithFormat:@"%@ reposted", _item.reposted];
    
    
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
    

        _infoLabel.frame  = CGRectMake(_infoLabel.frame.origin.x,
                                          _infoLabel.frame.origin.y,
                                          _infoLabel.frame.size.width,
                                          [self optimizationInfoTexteHeight]);
    
//      if (!ValidString(_item.text)) {
//          _infoLabel.hidden = YES;
//      }
    
    _infoLabel.text = _item.text;
    if ((_item.mediaURLs.count == 0) && (!ValidString(_item.text))) {
        _infoView.hidden = YES;
    }

    
//    
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

@end
