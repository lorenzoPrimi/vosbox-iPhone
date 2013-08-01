//
//  PlayerViewController.h
//  Vosbox
//
//  Created by Lorenzo Primiterra on 16/04/2012.
//  Copyright (c) 2012 Lorenzo Primiterra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AudioStreamer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@class AudioStreamer;

@interface PlayerViewController : UIViewController {
	IBOutlet UILabel *artist_label, *album_label, *song_label, *time_elapsed, *time_song;
	IBOutlet UIImageView *album_art;
    IBOutlet UIButton *playButton;
    NSTimer *volumeTimer;
	NSDictionary *current_song;
	AppDelegate *delegate;
	int song_time;
    BOOL playON, playerON;
    int currentSongINDEX;
    
    IBOutlet UIView *waitingView;
    IBOutlet UIActivityIndicatorView *activity;
    
	IBOutlet UIView *volumeSlider;
	IBOutlet UILabel *positionLabel;
	IBOutlet UISlider *progressSlider;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
}

- (void)play_current_song:(int)index;
- (IBAction)play;
- (IBAction)prevSong;
- (IBAction)nextSong;
- (void)stopPlaying;
- (void)updateProgress:(NSTimer *)aNotification;
- (IBAction)sliderMoved:(UISlider *)aSlider;
- (void)checkPaused;

@end

