//
//  ABMediaView.h
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "ABUtils.h"
#import "VideoTrackView.h"

typedef void (^ImageCompletionBlock)(UIImage *image, NSError *error);
typedef void (^VideoDataCompletionBlock)(NSString *video, NSError *error);

@protocol ABMediaViewDelegate;

@interface ABMediaView : UIImageView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<ABMediaViewDelegate> delegate;

/// Track which show video progress
@property (strong, nonatomic) VideoTrackView *track;

/// URL endpoint for image
@property (strong, nonatomic) NSString *imageURL;

/// URL endpoint for video
@property (strong, nonatomic) NSString *videoURL;

/// Theme color
@property (strong, nonatomic) UIColor *themeColor;

/// Open video player in aspect fit mode
@property BOOL videoAspectFit;

/// Determines whether track should be shown
@property BOOL showTrack;

/// If the video is already loading
@property BOOL isLoadingVideo;

/// If the video can be looped
@property BOOL allowLooping;

/// If the video can be looped
@property BOOL imageViewNotReused;

/// Play video recognizer
@property (strong, nonatomic) UITapGestureRecognizer *playRecognizer;

/// Shows that the image is loading
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

/// Shows that the content is a video
@property (strong, nonatomic) UIImageView *videoIndicator;

/// Player which will display video
@property (strong, nonatomic) AVPlayer *player;

/// Player layer which will display video
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

/// View for player
@property (strong, nonatomic) UIView *playerView;

/// Timer for animating the video loader
@property (strong, nonatomic) NSTimer *animateTimer;

- (void) changeVideoForAspectFit: (BOOL) videoAspectFit;

/// Load post image, set to cache, and give completion
- (void) setImageURL:(NSString *)imageURL withCompletion: (ImageCompletionBlock) completion;

/// Set the URL for the video, set to cache
- (void) setVideoURL:(NSString *)videoURL;

/// Loads the video, saves to cache, and decides whether to play the video
- (void) loadVideoWithPlay: (BOOL)play andScroll: (BOOL) scroll withCompletion: (VideoDataCompletionBlock) completion;

/// Show that the video is loading with animation
- (void) loadVideoAnimate;

/// Stop video loading animation
- (void) stopVideoAnimate;

/// Update the frame of the playerLayer
- (void) updatePlayerFrame;

/// Remove observers for player
- (void) removeObservers;

/// Play video
- (void) playVideoWithoutScroll: (BOOL) scroll;

/// Returns whether the view has a video
- (BOOL) hasVideo;

/// Returns whether the view is already playing video
- (BOOL) isPlayingVideo;

@end

@protocol ABMediaViewDelegate <NSObject>

@optional

- (void) selection;

- (void) playVideo;

- (void) stopVideo;

- (void) pauseVideo;

- (void) openContent;

@end
