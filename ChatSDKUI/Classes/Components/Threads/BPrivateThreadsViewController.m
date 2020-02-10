//
//  BThreadsViewController.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 24/09/2013.
//  Copyright (c) 2013 deluge. All rights reserved.
//

#import "BPrivateThreadsViewController.h"

#import <ChatSDK/Core.h>
#import <ChatSDK/UI.h>

@interface BPrivateThreadsViewController ()

@end

@implementation BPrivateThreadsViewController

-(instancetype) init {
    self = [super initWithNibName:Nil bundle:[NSBundle uiBundle]];
    if (self) {
        self.title = [NSBundle t:bConversations];
        self.tabBarItem.image = [NSBundle uiImageNamed: @"icn_30_chat.png"];
    }

    return self;
}

// we might use later
/* - (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    _editButton = [[UIBarButtonItem alloc] initWithTitle:[NSBundle t:bEdit]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(editButtonPressed:)];
    
//     If we have no threads we don't have the edit button
    self.navigationItem.leftBarButtonItem = _threads.count ? _editButton : nil;
} */

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Add new group button
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                            target:self
                                                                                            action:@selector(createThread)];

    filteredArray = [[NSMutableArray alloc] init];

    // create a new Search Bar and add it to the table view
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
                   setDefaultTextAttributes:@{NSFontAttributeName: BChatSDK.config.threadTitleFont,
                                              NSForegroundColorAttributeName: BChatSDK.config.threadTitleColor}];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 60.0f)];
//    [_searchBar setBarTintColor:[UIColor whiteColor]]; // outer BG
//    [_searchBar setSearchBarStyle:UISearchBarStyleMinimal]; // UISearchBarStyleMinimal (with gray inner BG)
//    [_searchBar setPlaceholder:@"Search"];

    //                                                      iOS 13 (or newer) ObjC code : older code
    /*UITextField *searchTextField = (@available(iOS 13, *)) ? _searchBar.searchTextField : [_searchBar valueForKey:@"_searchField"];
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc]
                                   initWithString:@"Search"
                                       attributes:@{NSForegroundColorAttributeName: BChatSDK.config.threadSubtitleColor}]];
        [searchTextField setTextColor:BChatSDK.config.threadTitleColor];
        [searchTextField.layer setBackgroundColor:[UIColor whiteColor].CGColor]; // inner BG
    }*/
    self.tableView.tableHeaderView = _searchBar;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarSearchButtonClicked:)];
    [tap setCancelsTouchesInView:false];
    [self.view addGestureRecognizer:tap];

    // we need to be the delegate so the cancel button works
    _searchBar.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [_searchBar resignFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_searchBar setText:nil];
    [_searchBar resignFirstResponder];
}

-(void) createThread {
    [self createPrivateThread];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [filteredArray removeAllObjects];
    for (id<PThread> thread in [BChatSDK.core threadsWithType:bThreadFilterPrivateThread includeDeleted:NO]) {
        if ([thread.displayName containsString:searchText]) {
            [filteredArray addObject:thread];
        }
    }

    [self reloadData]; // NSLog(@"filtered ->%@", filteredArray);
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}

-(void) createPrivateThread {
    __weak __typeof__(self) weakSelf = self;

    UINavigationController * nav = [BChatSDK.ui friendsNavigationControllerWithUsersToExclude:@[] onComplete:^(NSArray * users, NSString * groupName){
        __typeof__(self) strongSelf = weakSelf;
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        hud.label.text = [NSBundle t:bCreatingThread];
        
        // Create group with group name
        [BChatSDK.core createThreadWithUsers:users name:groupName threadCreated:^(NSError *error, id<PThread> thread) {
            if (!error) {
                [strongSelf pushChatViewControllerWithThread:thread];
            } else {
                [UIView alertWithTitle:[NSBundle t:bErrorTitle] withMessage:[NSBundle t:bThreadCreationError]];
            }
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        }];
    }];
    
    [self presentViewController:nav animated:YES completion:Nil];
}

-(void) editButtonPressed: (UIBarButtonItem *) item {
    [self toggleEditing];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void) reloadData {
    [_threads removeAllObjects];

    if (_searchBar.text.length == 0) {
        [_threads addObjectsFromArray:[BChatSDK.core threadsWithType:bThreadFilterPrivateThread includeDeleted:NO]];
    } else {
        [_threads addObjectsFromArray:filteredArray];
    }

    [super reloadData];
}

@end
