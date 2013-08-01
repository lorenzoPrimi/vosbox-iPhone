//
//  PlayerViewController.m
//  Vosbox
//
//  Created by Lorenzo Primiterra on 16/04/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import "PlayerViewController.h"

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:volumeSlider.bounds];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];

    // Player is initially off
    playerON = NO;
    // Music is not playing
    playON = NO;
    //delegate.currentSongINDEX = 0;
    [self resetScreen];
}

- (void)play_current_song:(int)index{    
    if (!playerON)
        playerON = YES;
    delegate.currentSongINDEX = index;
    current_song = [delegate.playlist objectAtIndex: delegate.currentSongINDEX];
	[artist_label setText:[current_song objectForKey:@"artist"]];
	[album_label setText:[current_song objectForKey:@"album"]];
	[song_label setText:[current_song objectForKey:@"title"]];
	//STATIC TIME
    [time_song setText:[current_song objectForKey:@"time"]];
    NSString *albumArtIdValue = [NSString stringWithFormat: @"%@",[current_song objectForKey:@"albumArtId"]];
    UIImage *thumbnail;
    if ([delegate.covers objectForKey:albumArtIdValue] != nil)
        thumbnail = [delegate.covers objectForKey:albumArtIdValue];
    else 
        thumbnail = [UIImage imageNamed:@"no_cover_320.png"];
    
        [album_art setImage:thumbnail];

    [self destroyStreamer];
    [self createStreamer];
    [streamer start];
}


- (IBAction)play {
    if ([delegate.playlist count] > 0) {
        if (!playON){
            //[playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            //playON = YES;
            if (!playerON) {
                delegate.currentSongINDEX = 0;
                [self play_current_song:delegate.currentSongINDEX];
                playerON = YES;
            }
            else {
                [self createStreamer];
                [streamer start];
            }
        }
        else {
            [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            playON = NO;
            [streamer pause];
        }
    }
    else [self emptyPlaylist];
}

- (IBAction)nextSong {
    if ([delegate.playlist count] > 0) {
        if ([delegate.playlist count] > 1) {
        if (delegate.currentSongINDEX == [delegate.playlist count]-1) delegate.currentSongINDEX = 0;
        else delegate.currentSongINDEX+=1;
        [self play_current_song:delegate.currentSongINDEX];
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        playON = YES;
    }
    }
    else [self emptyPlaylist];
}

- (IBAction)prevSong {
    if ([delegate.playlist count] > 0) {
        if ([delegate.playlist count] > 1) {
        if (delegate.currentSongINDEX > 0) delegate.currentSongINDEX-=1;
        else delegate.currentSongINDEX = [delegate.playlist count]-1;
        [self play_current_song:delegate.currentSongINDEX];
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        playON = YES;
    }
    }
    else [self emptyPlaylist];
}

- (void)stopPlaying {
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    delegate.currentSongINDEX = -1;
    playON = NO;
    playerON = NO;
    [self destroyStreamer];
    [self resetScreen];
}

- (void)resetScreen {
    [artist_label setText:@""];
	[album_label setText:@""];
	[song_label setText:NSLocalizedString(@"Nothing Playing", @"")];
	//[time_song setText:@""];    
    [album_art setImage:nil];
    [time_elapsed setText:@"0:00"];
    [time_song setText:@"0:00"];
    [progressSlider setValue:0];
}

- (void)emptyPlaylist {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Playlist is empty", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil ];
    [alert show];
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//

- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
	
    NSDictionary *dictionary = [delegate.playlist objectAtIndex:delegate.currentSongINDEX];
    NSString *songIdValue = [NSString stringWithFormat: @"%@",[dictionary objectForKey:@"id"]];
    NSString *songUrl = [NSString stringWithFormat: @"http://%@/api/download.php?id=%@",[delegate getUrl], songIdValue];
    
	NSString *escapedValue =
    (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                         nil,
                                                         (__bridge CFStringRef)songUrl,
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8);
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	NSLog ( @"url: %@", url);
	progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration)
	{
        [progressSlider setEnabled:FALSE];
		double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
		[streamer seekToTime:newSeekTime];
	}
}

// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;

        if (duration > 0)
		{
            //DYNAMIC TIME
            //[time_song setText:[NSString stringWithFormat:@"%@", [self seconds_to_human_readable:duration]]];
            [time_elapsed setText:[NSString stringWithFormat:@"%@", [self seconds_to_human_readable:progress]]];
            /*[positionLabel setText:
             [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
              progress,
              duration]];*/
			//[progressSlider setEnabled:YES]; //should be yes
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		positionLabel.text = @"0:00";
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[waitingView setHidden:FALSE];
        [activity startAnimating];
        [playButton setEnabled:FALSE];
        [progressSlider setEnabled:FALSE];
	}
	else if ([streamer isPlaying])
	{
        [activity stopAnimating];
        [waitingView setHidden:TRUE];
        [playButton setEnabled:TRUE];
        [progressSlider setEnabled:YES];
		[playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
     playON = YES;
	}
	else
    if ([streamer isIdle])
	{
		[self destroyStreamer];
        [progressSlider setEnabled:FALSE];
		[self nextSong];
	}
}

- (NSString *)seconds_to_human_readable:(int)total_seconds{
    int seconds = total_seconds % 60; // get the remainder  
    int minutes = (total_seconds / 60) % 60; // get minutes the same way
    int hours   = total_seconds / 60 / 60;  // this function won't go higher than hours.. shouldn't be a problem
	if (hours == 0) { // don't print hours then
		return [NSString stringWithFormat:@"%2d:%02d", minutes, seconds]; 
	}
	return [NSString stringWithFormat:@"%2d:%02d:%02d", hours, minutes, seconds]; 
}

- (void)checkPaused {
    if ([streamer isPaused])
	{
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        playON = NO;

	}

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
