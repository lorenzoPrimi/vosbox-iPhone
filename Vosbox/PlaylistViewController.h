//
//  PlaylistViewController.h
//  Vosbox
//
//  Created by Lorenzo Primiterra on 15/04/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NSString+MD5.h"

@interface PlaylistViewController : UIViewController {
    AppDelegate *delegate;
}

- (IBAction)cancel:(id)sender;

@end
