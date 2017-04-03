//
//  FeedTableViewController.m
//  NewsFeedFB-VK
//
//  Created by Viktoriia Vovk on 3/31/17.
//  Copyright © 2017 Viktoriia Vovk. All rights reserved.
//

#import "FeedTableViewController.h"
#import "FeedTableViewCell.h"
#import "VKAPI.h"
#import "DetailViewController.h"

@interface FeedTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl * refreshControl;
@property (strong, nonatomic) NSMutableArray * itemsArray;


@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:false animated:YES];
    self.navigationController.title = @"Feed";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onBackButtonItemTap)];
    
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //    self.tableView.estimatedRowHeight = 150.0;
    [self pulToRefreash];
    [self loadData];
}

- (void)loadData {
    if ([VKAPI isInternetAvailable]){
        [ApplicationDelegate cleanAndResetupDB];
        
        [ApplicationDelegate showMBProgressHUDWithTitle:nil
                                               subTitle:nil
                                                   view:self.view];
        [VKAPI getDataWithCompletion:^(NSError *error) {
            [ApplicationDelegate.mbprogressHUD hideAnimated:NO];
            if (error) {
                [self showAlertWithString:nil withError:error];
            } else {
                [self reloadItems];
            }
        }];
    } else {
        [self reloadItems];
        
    }
    
}

- (void)onBackButtonItemTap {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)pulToRefreash {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(loadFeed)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:(self.refreshControl)];
}

- (void)loadFeed {
    if (self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
    [self loadData];
}


- (void)reloadItems {
    
    _itemsArray = [[[Item MR_findAll] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                                                  ascending:NO]]] mutableCopy];
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Item *item = _itemsArray[indexPath.row];
    CGFloat height = 136;
    if (item.text.length > 0){
        height = height + 64;
    }
    
    if (item.mediaURLs.count == 0) {
        return height;
    } else {
        if ([item.type isEqualToString:@"photo"] ||
            [item.type isEqualToString:@"wall_photo"] ||
            [item.type isEqualToString:@"photo_tag"]) {
            height = height + 200;
            return height;
        }
        if ([item.type isEqualToString:@"post"]) {
            NSArray * link = [item.mediaURLs objectAtIndex:0];
            if ([[link valueForKey:@"type"] isEqualToString:@"photo"]) {
                height = height + 200;
                return height;
            }
        }
        return height;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    
    if(!cell){
        cell = [[FeedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FeedCell"];
    }
    
    cell.item = _itemsArray[indexPath.row];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
    detailVC.item = _itemsArray[indexPath.row];
    
    [self.navigationController pushViewController:detailVC
                                         animated:YES];
}

- (void)showAlertWithString:(NSString *)string
                  withError:(NSError *)error  {
    NSString *title = nil;
    if (string == nil){
        string = [error localizedDescription];
        title = @"Error";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:string
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
