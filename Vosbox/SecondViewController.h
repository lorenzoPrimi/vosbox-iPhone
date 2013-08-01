//
//  SecondViewController.h
//  Vosbox
//
//  Created by Lorenzo Primiterra on 25/03/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AppDelegate.h"
#import "PlaylistViewController.h"
#import "NSString+MD5.h"

@interface SecondViewController : UIViewController <UIActionSheetDelegate>
{
    IBOutlet UITableView *tableView2;
    AppDelegate *delegate;
    NSMutableArray *listTitle;
    NSMutableArray *listAlbum;
    NSMutableArray *listArtist;
    NSMutableArray *listTime;
    NSMutableArray *listObjects;
    UIAlertView *myAlertView;
    UITextField *myTextField;
    AppDelegate *appDelegate;
    IBOutlet UILabel *empty;
    IBOutlet UIBarButtonItem *editButton;
}


- (IBAction) savePlaylist;

- (IBAction) moreActions;

- (void)setPlayStatus;
- (IBAction)edit;
- (IBAction) emptyPlaylist;
- (IBAction) shufflePlaylist;

@end
