//
//  AppDelegate.m
//  Vosbox
//
//  Created by Lorenzo Primiterra on 25/03/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize settings;
@synthesize playlist;
@synthesize playlistsList;
@synthesize covers;
@synthesize currentSongINDEX;
@synthesize srv_addr;
@synthesize searchArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    playlist = [[NSMutableArray alloc] init];
    settings = [NSUserDefaults standardUserDefaults];
    covers = [NSMutableDictionary dictionary];
    
    //playlistsList = [[NSMutableArray alloc] init];
    tabBarController = (UITabBarController *) self.window.rootViewController;
    currentSongINDEX = -1;
    
	NSString *server = [settings stringForKey:@"custom_srv"];
	if(!server) {
		// If the default value doesn't exist then we need to manually set them.
		[self registerDefaultsFromSettingsBundle];
		//server = [[NSUserDefaults standardUserDefaults] stringForKey:@"custom_srv"];
	}
    
    custom_srv =  [settings stringForKey:@"custom_srv"];
    srv_addr =  [settings stringForKey:@"srv_addr"];
    
    [self loadPlaylist];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsChanged)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    // Override point for customization after application launch.
    return YES;
}


- (void)loadPlaylist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[[self getUrl] MD5]];
    
    if ([[NSArray arrayWithContentsOfFile:filePath] count] > 0)
        playlistsList = [NSArray arrayWithContentsOfFile:filePath];
    else playlistsList = [[NSMutableArray alloc] init];
}

- (void) defaultsChanged {
    NSString *custom_srv_new =  [settings stringForKey:@"custom_srv"];
    NSString *srv_addr_new =  [settings stringForKey:@"srv_addr"];
    
    if (![custom_srv isEqualToString:custom_srv_new]){
        if ([custom_srv_new isEqualToString:@"0"]) [self reloadSettings];
        else {
            if ([srv_addr_new length] > 0) [self reloadSettings];
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"You specified to use a custom server but you have entered no server address", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
                [alert show];
            }
        }
    }
    else if (![srv_addr isEqualToString:srv_addr_new]) [self reloadSettings];
}

- (void)reloadSettings {
    [self stopPlaying];
    custom_srv =  [settings stringForKey:@"custom_srv"];
    srv_addr =  [settings stringForKey:@"srv_addr"];
    [playlist removeAllObjects];
    [covers removeAllObjects];
    [searchArray removeAllObjects];
    [[[tabBarController viewControllers] objectAtIndex:0] resetSearchBar];
    currentSongINDEX = -1;
    [self loadPlaylist];
    [self checkPlaylists];
    [self writeToDisk];
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings2 = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings2 objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

- (void)checkPlaylists {
    NSMutableArray *garbage= [NSMutableArray array];
    for (NSDictionary *list in playlistsList){
        NSString *url = [NSString stringWithFormat: @"http://%@/api/playlist.php?load=%@", [self getUrl], [list objectForKey:@"ID"]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
        [request setTimeoutInterval:30];
        [request setHTTPMethod: @"GET"];
        
        NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
        if ([response length] == 30) [garbage addObject:list];
    }
    [playlistsList removeObjectsInArray:garbage];
}

- (void)writeToDisk {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[[self getUrl] MD5]];
    
    [playlistsList writeToFile:arrayPath atomically:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //GOES TO PLAYER
    [tabBarController setSelectedIndex:2];
    [[[tabBarController viewControllers] objectAtIndex:2] checkPaused];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //NSUserDefaults *newsettings = [NSUserDefaults standardUserDefaults];
    //NSString *server = [newsettings stringForKey:@"custom_srv"];
    //NSLog(@"setting: %@",server);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)stopPlaying {
    [[[tabBarController viewControllers] objectAtIndex:2] stopPlaying];
}

- (void)play_current_song:(int)index:(BOOL)change {
    if(change) [tabBarController setSelectedIndex:2];
    [[[tabBarController viewControllers] objectAtIndex:2] play_current_song:index];  // now playing
}

- (NSString*) getUrl {
    
    NSString *url;
    if([custom_srv isEqualToString:@"0"]){
        url = [NSString stringWithFormat: @"%@", BASE_URL];
    }
    else {
        url = [NSString stringWithFormat: @"%@", srv_addr];
    }
    return url;
}



@end
