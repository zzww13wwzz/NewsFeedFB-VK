//
//  DetailViewController.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 4/3/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FRHyperLabel.h"


@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet FRHyperLabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaContentHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fillOwnerInfo];
    [self fillLikeAndRepostInfo];
    [self fillTextInfoOfPost];
    [self fillContent];
    
}
# pragma mark - fillContent

-(void)fillContent {
    if (_item.mediaURLs.count > 0) {
        
    }
}


# pragma mark - fillTextInfoOfPost

- (void)fillTextInfoOfPost {
    
    _messageLabel.text = _item.text;
    _messageLabel.frame  = CGRectMake(_messageLabel.frame.origin.x,
                                      _messageLabel.frame.origin.y,
                                      _messageLabel.frame.size.width,
                                      [self optimizationInfoTexteHeight]);
    
    NSString * match = [self parserMessageForLink];
    if (ValidString(match)) {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]};
        
        _messageLabel.attributedText = [[NSAttributedString alloc]initWithString:_item.text attributes:attributes];
        
        [_messageLabel setLinkForSubstring:match withLinkHandler:^(FRHyperLabel *label, NSString *substring){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:match]];
        }];
    } else {
        _messageLabel.text = _item.text;
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
    CGSize constraint = CGSizeMake(_messageLabel.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [_messageLabel.text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:_messageLabel.font}
                                                          context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
