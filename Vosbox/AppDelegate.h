//
//  AppDelegate.h
//  Vosbox
//
//  Created by Lorenzo Primiterra on 25/03/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceManager.h"
#import "NSString+MD5.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSUserDefaults *settings;
    NSMutableArray *playlist;
    NSMutableDictionary *covers;
    NSMutableArray *playlistsList;
    UITabBarController *tabBarController;
    int currentSongINDEX;
    NSString *custom_srv;
    NSString *srv_addr;
    NSMutableArray *searchArray;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSUserDefaults *settings;
@property (nonatomic, retain) NSMutableArray *playlist;
@property (nonatomic, retain) NSMutableArray *playlistsList;
@property (nonatomic, retain) NSMutableDictionary *covers;
@property (nonatomic) int currentSongINDEX;
@property (nonatomic, retain) NSString *srv_addr;
@property (nonatomic, retain) NSMutableArray *searchArray;

- (void)play_current_song:(int)index:(BOOL)change;
- (void)play_current_song:(int)index;
- (NSString*) getUrl;
- (void)stopPlaying;
- (void)checkPaused;
- (void)resetSearchBar;
@end
