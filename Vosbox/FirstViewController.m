//
//  FirstViewController.m
//  Vosbox
//
//  Created by Lorenzo Primiterra on 25/03/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import "FirstViewController.h"


@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - 
#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [delegate.searchArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    UILabel *album = (UILabel *)[cell viewWithTag:2];
    UILabel *time = (UILabel *)[cell viewWithTag:3];
    UIImageView *image = (UIImageView *)[cell viewWithTag:4];
    
    NSDictionary *dictionary = [delegate.searchArray objectAtIndex: indexPath.row];
    NSString *titleValue = [NSString stringWithFormat: @"%@ - %@",[dictionary objectForKey:@"artist"], [dictionary objectForKey:@"title"]];
    NSString *timeValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"time"]];
    NSString *albumValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"album"]];
    NSString *albumArtIdValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"albumArtId"]];
    
    // Set up the cell
    [title setText:titleValue];
    [time setText:timeValue];
    [album setText:albumValue];
    UIImage *thumbnail;
        if ([albumArtIdValue length] == 32){
            if ([delegate.covers objectForKey:albumArtIdValue] != nil){
                thumbnail = [delegate.covers objectForKey:albumArtIdValue];
            }
            else{
                NSString *url = [NSString stringWithFormat: @"http://%@/api/albumArt.php?id=%@", [delegate getUrl], albumArtIdValue];
                
                thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                [delegate.covers setObject:thumbnail forKey:albumArtIdValue];
            }
        }
    else thumbnail = [UIImage imageNamed:@"no_cover.png"];
    [image setImage:thumbnail];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [delegate.searchArray objectAtIndex: indexPath.row];
    [delegate.playlist addObject:obj];
    
    UITableViewCell *cella = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *image = (UIImageView *)[cella viewWithTag:5];
    [image setHidden:FALSE];
    [self performSelector:@selector(untick:) withObject:cella afterDelay:1.0];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)untick:(UITableViewCell *) cell {
    
        UIImageView *image = (UIImageView *)[cell viewWithTag:5];
        [image setHidden:TRUE];
    
}

#pragma mark - 
#pragma mark Search 

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *) searchBar 
{ 
    //NSLog ( @"search: %@", searchBar.text);
    searchString = searchBar.text;
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(121.0f, 50.0f, 37.0f, 37.0f);
    [activityView startAnimating];
    
    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Loading...", @"") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView addSubview:activityView];
    [alertView show];
    [searchBar resignFirstResponder];
    [NSThread detachNewThreadSelector:@selector(vosSearch) toTarget:self withObject:nil];
}

-(void) vosSearch {
    
    searchString = [searchString stringByReplacingOccurrencesOfString:@" "
                                                           withString:@"%20"];
    
    NSString *url = [NSString stringWithFormat: @"http://%@/api/search.php?keywords=%@", [delegate getUrl], searchString];
    
    NSLog(@"URL: %@",url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
    [request setTimeoutInterval:30];
    [request setHTTPMethod: @"GET"];
    
    NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    NSString *stringResponse = [[NSString alloc] initWithData: response encoding: NSUTF8StringEncoding];
    //NSLog(@"my string = %@",response);
    //NSLog(@"my response string = %@",stringResponse);
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    if(response == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", @"") message:NSLocalizedString(@"Connection timeout", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
        [alert show];
    }
    else if([stringResponse length]  < 3){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry!", @"") message:NSLocalizedString(@"Search returned no results", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
        [alert show];
    }
    else {
        
        NSError* error;
        
        delegate.searchArray = [NSJSONSerialization 
                     JSONObjectWithData:response
                                options:NSJSONReadingMutableContainers 
                     error:&error];
        //jsonArray = [stringResponse JSONValue];
        //NSLog(@"array  = %@",jsonArray);
        startText.hidden = YES;
        [tableView1 reloadData];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [tableView1 reloadData];
    if ([delegate.searchArray count] == 0) startText.hidden = NO;
    else startText.hidden = YES;
}
- (void)resetSearchBar {
     mySearchBar.text = @"";
}

#pragma mark - 
#pragma mark Dealloc 

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}*/
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
