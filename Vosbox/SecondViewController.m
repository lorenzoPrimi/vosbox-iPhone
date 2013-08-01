//
//  SecondViewController.m
//  Vosbox
//
//  Created by Lorenzo Primiterra on 25/03/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import "SecondViewController.h"


@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[tableView2 setEditing:TRUE];
    //tableView2.allowsSelectionDuringEditing = YES;
}


#pragma mark - 
#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1)
	return [delegate.playlist count];
    else return 1;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 0;
}*/

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	CGFloat height;
	
	if([indexPath section] == 0){
		height = 44.0;
	}
	if([indexPath section] == 1){
		height = 60.0;
	}
	
    return height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
      static NSString *CellIdentifier = @"Toolbar";  
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        return cell;
    }
    else {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    UILabel *album = (UILabel *)[cell viewWithTag:2];
    UILabel *time = (UILabel *)[cell viewWithTag:3];
    UIImageView *image = (UIImageView *)[cell viewWithTag:4];
    UIImageView *imageplay = (UIImageView *)[cell viewWithTag:5];
    
    NSDictionary *dictionary = [delegate.playlist objectAtIndex: indexPath.row];
    NSString *titleValue = [NSString stringWithFormat: @"%@ - %@",[dictionary objectForKey:@"artist"], [dictionary objectForKey:@"title"]];
    NSString *timeValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"time"]];
    NSString *albumValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"album"]];
    NSString *albumArtIdValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"albumArtId"]];
    
    // Set up the cell
    [title setText:titleValue];
    [time setText:timeValue];
    [album setText:albumValue];
    if (indexPath.row == delegate.currentSongINDEX) [imageplay setHidden:FALSE];
    else [imageplay setHidden:TRUE];
    
    cell.showsReorderControl = YES;
    
    /*UIImage *thumbnail;
    if([albumArtIdValue length] == 32){
        if ([delegate.covers objectForKey:albumArtIdValue] != nil){
            thumbnail = [delegate.covers objectForKey:albumArtIdValue];
        }
    }
        else{
            thumbnail = [UIImage imageNamed:@"no_cover.png"];            
        }
        [image setImage:thumbnail];*/
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
}

- (void)setPlayStatus {
    
    UITableViewCell *cell;    
    NSIndexPath *index;
    
    for (int i = 0 ; i < [delegate.playlist count]; i++) {
        index = [NSIndexPath indexPathForRow:i inSection:0];
        cell = [tableView2 cellForRowAtIndexPath:index];
        UIImageView *image = (UIImageView *)[cell viewWithTag:5];
        [image setHidden:TRUE];
    }
    
    if (delegate.currentSongINDEX != -1){
    NSIndexPath *index2 = [NSIndexPath indexPathForRow:delegate.currentSongINDEX inSection:0];
    UITableViewCell *cella = [tableView2 cellForRowAtIndexPath:index2];
    UIImageView *image = (UIImageView *)[cella viewWithTag:5];
    [image setHidden:FALSE];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [delegate play_current_song:indexPath.row:TRUE];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==1){
    if ([tableView isEditing])
    return UITableViewCellEditingStyleDelete;
    else
    return UITableViewCellEditingStyleNone;
    }
    else return UITableViewCellEditingStyleNone;
}


/*- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
}*/


- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];
        int count = [delegate.playlist count];
        [delegate.playlist removeObjectAtIndex:row];
        
        if (row == delegate.currentSongINDEX) {
            if (count == 1) [delegate stopPlaying];
            else {
                if (delegate.currentSongINDEX == count - 1) delegate.currentSongINDEX = 0;
                [delegate play_current_song:delegate.currentSongINDEX:FALSE];
                [self setPlayStatus];
            }
        }
        [tableView reloadData];
    } 
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==1) return YES;
    else return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *stringToMove = [delegate.playlist objectAtIndex:sourceIndexPath.row];
    [delegate.playlist removeObjectAtIndex:sourceIndexPath.row];
    [delegate.playlist insertObject:stringToMove atIndex:destinationIndexPath.row];
    if (sourceIndexPath.row == delegate.currentSongINDEX) delegate.currentSongINDEX = destinationIndexPath.row;
    else if (destinationIndexPath.row == delegate.currentSongINDEX) delegate.currentSongINDEX = sourceIndexPath.row;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
return NO;
}


#pragma mark - 
#pragma mark Funct 

- (void)viewWillAppear:(BOOL)animated {
    [tableView2 reloadData];
    if ([delegate.playlist count] == 0) empty.hidden = NO;
        else {
            empty.hidden = YES;
            [self setPlayStatus];
        }
}

- (IBAction)edit {
    if ([delegate.playlist count] > 0){
    if ([tableView2 isEditing]) {
        [tableView2 setEditing:FALSE];
        [editButton setTitle:NSLocalizedString(@"Edit", nil)];
    }
    else {
        [tableView2 setEditing:TRUE];
        [editButton setTitle:NSLocalizedString(@"Done", nil)];
    }
    }
}

- (IBAction) shufflePlaylist {
    if ([delegate.playlist count] > 1){
        NSUInteger count = [delegate.playlist count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            int nElements = count - i;
            int n = (random() % nElements) + i;
            [delegate.playlist exchangeObjectAtIndex:i withObjectAtIndex:n];
            if (i == delegate.currentSongINDEX) delegate.currentSongINDEX = n;
            else if (n == delegate.currentSongINDEX) delegate.currentSongINDEX = i;
        }
    [tableView2 reloadData];
    [self setPlayStatus];
    }
}

- (IBAction) emptyPlaylist {
    if ([delegate.playlist count] > 0){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Empty playlist", nil) message:NSLocalizedString(@"Player will be stopped and playlist cleared", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert setTag:2];
    [alert show];
    }
}

//TOREMOVE
- (IBAction) moreActions { 
    UIActionSheet *sheet;
    sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"More actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Share on Facebook", nil), NSLocalizedString(@"Share on Twitter", nil), nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}


- (IBAction)savePlaylist {    
    if ([delegate.playlist count] > 0){
        myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Playlist name", nil) message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Save", nil), nil];
        [myAlertView setTag:1];
        myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [myTextField setBackgroundColor:[UIColor whiteColor]];
        [myAlertView addSubview:myTextField];
        [myAlertView show];
        [myTextField becomeFirstResponder];
    }
    else {
        myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Playlist is empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil ];
        [myAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==1){
    if (buttonIndex==1){
        if ([myTextField.text length] > 0){
            NSDictionary *dictionary;
            NSMutableString *ids = [[NSMutableString alloc] init];
            for (int i = 0; i < [delegate.playlist count]; i++){
                dictionary = [delegate.playlist objectAtIndex: i];
                NSString *idValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"id"]];
                [ids appendString:[NSString stringWithFormat:@"%@,",idValue]];
            }
            NSString *url = [NSString stringWithFormat: @"http://%@/api/playlist.php?save=%@", [delegate getUrl], [ids substringToIndex:[ids length] - 1]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
            [request setTimeoutInterval:30];
            [request setHTTPMethod: @"GET"];
            
            NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
            if(response == nil){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", @"") message:NSLocalizedString(@"Connection timeout", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
                [alert show];
            }
            else {
            NSError* error;
            NSDictionary* jsonArray = [NSJSONSerialization 
                                  JSONObjectWithData:response
                                  options:kNilOptions 
                                  error:&error];
            NSArray* responseID = [jsonArray objectForKey:@"id"]; 
            
            NSMutableDictionary *currentPlaylist = [NSMutableDictionary dictionary];
                
            [currentPlaylist setObject:responseID forKey:@"ID"];
            //[currentPlaylist setObject:[NSString stringWithFormat:@"%@ciao", responseID] forKey:@"ID"];
            [currentPlaylist setObject:myTextField.text forKey:@"NAME"];
                
            [delegate.playlistsList addObject:currentPlaylist];
            [self writeToDisk];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Playlist Saved", nil) message:[NSString stringWithFormat:@"%@", responseID] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil ];
            [alert show];
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No name entered", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil ];
            [alert show];
        }
    }
}
    else if (alertView.tag == 2) {
        if (buttonIndex==1){
        [delegate stopPlaying];
        [delegate.playlist removeAllObjects];
        [tableView2 reloadData];
        }
    }    
}

- (void)writeToDisk {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[[delegate getUrl] MD5]];
    
    [delegate.playlistsList writeToFile:arrayPath atomically:YES];
}

#pragma mark - 
#pragma mark Dealloc

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
