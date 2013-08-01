//
//  FirstViewController.h
//  Vosbox
//
//  Created by Lorenzo Primiterra on 25/03/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FirstViewController : UIViewController <UISearchBarDelegate>
{
    IBOutlet UITableView *tableView1;
    UIAlertView *alertView;
    NSString *searchString;
    AppDelegate *delegate;
    NSMutableArray *listTitle;
    NSMutableArray *listAlbum;
    NSMutableArray *listArtist;
    NSMutableArray *listTime;
    NSMutableArray *listObjects;
    IBOutlet UISearchBar *mySearchBar;
    IBOutlet UILabel *startText;
}
- (void) vosSearch;
- (void)resetSearchBar;
@end
