//
//  VideoTrackView.h
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ABUtils.h"
#import <QuartzCore/QuartzCore.h>

@protocol VideoTrackDelegate;

@interface VideoTrackView : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<VideoTrackDelegate> delegate;

/// Timer for hiding the details on the track
@property (strong, nonatomic) NSTimer *hideTimer;

/// View which shows how much of the video has loaded
@property (strong, nonatomic) UIView *bufferView;

/// View which shows progress of watchineg the video
@property (strong, nonatomic) UIView *progressView;

/// View which shows background for bars
@property (strong, nonatomic) UIView *barBackgroundView;

/// Label which displays current time for video
@property (strong, nonatomic) UILabel *currentTimeLabel;

/// Label which displays total time for video
@property (strong, nonatomic) UILabel *totalTimeLabel;

/// Current progress for streaming video
@property (strong, nonatomic) NSNumber *progress;

/// Duration of the clip
@property float duration;

/// Height for the track and buffer bars
@property float barHeight;

/// Determines whether seeking is allowed
@property BOOL canSeek;

/// Toggles to functionality to show the video's remaining time on the right side of the track, instead of total time
@property BOOL showRemainingTime;

/// Current buffer for streaming video
@property (strong, nonatomic) NSNumber *buffer;

/// Recognizes when a user is trying to scrub through video
@property (strong, nonatomic) UIPanGestureRecognizer *scrubRecognizer;

/// Recognizes when a user taps the track
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

/// Update progress for the streaming video
- (void) setProgress:(NSNumber *)progress withDuration: (CGFloat) duration;

/// Update buffer for the streaming video
- (void) setBuffer:(NSNumber *)buffer withDuration: (CGFloat) duration;

/// Updates UI to reflect current progress
- (void) updateProgress;

/// Updates UI to reflect current buffer
- (void) updateBuffer;

/// Update UI for bar background
- (void) updateBarBackground;

@end

@protocol VideoTrackDelegate <NSObject>

@optional

/// Seek to a time
- (void) seekToTime: (float) time;

@end
