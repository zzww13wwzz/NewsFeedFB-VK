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

@interface FeedTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl * refreshControl;
@property (strong, nonatomic) NSMutableArray * itemsArray;
@property (nonatomic, strong) VKAPI *vkapi;

@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150.0;
    [self pulToRefreash];
    [self reloadItems];
}
- (void)pulToRefreash {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor darkGrayColor];
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
    [ApplicationDelegate cleanAndResetupDB];
    
    [self.vkapi getJsonVKWithCompletion:^(NSError *error) {
        if (error) {
            [self showAlertWithString:nil withError:error];
        } else {
            [self reloadItems];
        }
    }];
    
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    cell.item = _itemsArray[indexPath.row];
    [cell updateConstraintsIfNeeded];
    return cell;
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
