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

extern const NSNotificationName ABMediaViewWillRotateNotification;
extern const NSNotificationName ABMediaViewDidRotateNotification;

@interface ABMediaView : UIImageView <VideoTrackDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<ABMediaViewDelegate> delegate;

- (instancetype) initWithMediaView: (ABMediaView *) mediaView;

/// Shared Manager, which keeps track of mediaViews
+ (id)sharedManager;

/// Queue which holds an array of mediaViews to be displayed
@property (strong, nonatomic) NSMutableArray *mediaViewQueue;

/// Main window which the mediaView will be added to
@property (strong, nonatomic) UIWindow *mainWindow;

/// Track which shows the progress of the video being played
@property (strong, nonatomic) VideoTrackView *track;

/// URL endpoint for image
@property (strong, nonatomic) NSString *imageURL;

/// Image cached after loading
@property (strong, nonatomic) UIImage *imageCache;

/// URL endpoint for video
@property (strong, nonatomic) NSString *videoURL;

/// Video location on disk that was cached after loading
@property (strong, nonatomic) NSString *videoCache;


/// Theme color which will show on the play button and progress track for videos
@property (strong, nonatomic) UIColor *themeColor;

/// Determines whether the video playerLayer should be set to aspect fit mode
@property BOOL videoAspectFit;

/// Determines whether the progress track should be shown for video
@property BOOL showTrack;

/// Determines if the video is already loading
@property BOOL isLoadingVideo;

/// Determines if the video should be looped when it reaches completion
@property BOOL allowLooping;

/// Determines whether or not the mediaView is being used in a reusable view
@property BOOL imageViewNotReused;

/// Determines whether the mediaView can be minimized into the bottom right corner, and then dismissed by swiping right on the minimized version
@property BOOL isMinimizable;

/// Determines whether the video occupies the full screen when displayed
@property BOOL shouldDisplayFullscreen;

/// (DON'T MODIFY) Determines whether the content's original size is full screen. If you are looking to make it so that when a mediaView is selected from another view, that it opens up in full screen, then set the property 'shouldDisplayFullScreen'
@property BOOL isFullScreen;

/// Recognizer which keeps track of whether the user taps the view to play or pause the video
@property (strong, nonatomic) UITapGestureRecognizer *playRecognizer;

/// Indicator which shows that the video is being loaded
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

/// Play button imageView which shows in the center of the video, notifies the user that a video can be played
@property (strong, nonatomic) UIImageView *videoIndicator;

/// AVPlayer which will handle video playback
@property (strong, nonatomic) AVPlayer *player;

/// AVPlayerLayer which will display video
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

/// Timer for animating the videoIndicator, to show that the video is loading
@property (strong, nonatomic) NSTimer *animateTimer;

/// Rect that specifies where the mediaView's frame will originate from when presenting, and needs to be converted into its position in the mainWindow
@property CGRect originRect;

/// Rect that specifies where the mediaView's frame will originate from when presenting, and is already converted into its position in the mainWindow
@property CGRect originRectConverted;

/// Allows functionality to change the videoGravity to aspectFit on the fly
- (void) changeVideoToAspectFit: (BOOL) videoAspectFit;

/// Download the image, display the image, and give completion block
- (void) setImageURL:(NSString *)imageURL withCompletion: (ImageCompletionBlock) completion;

/// Set the url for the image
- (void) setVideoURL:(NSString *)videoURL;

/// Loads the video, saves to disk, and decides whether to play the video
- (void) loadVideoWithPlay: (BOOL)play withCompletion: (VideoDataCompletionBlock) completion;

/// Show that the video is loading with animation
- (void) loadVideoAnimate;

/// Stop video loading animation
- (void) stopVideoAnimate;

/// Update the frame of the playerLayer
- (void) updatePlayerFrame;

/// Remove observers for player
- (void) removeObservers;

/// Selector to play the video from the playRecognizer
- (void) playVideoFromRecognizer;

/// Returns whether the view has a video
- (BOOL) hasVideo;

/// Returns whether the view is already playing video
- (BOOL) isPlayingVideo;

/// Toggle functionality for remaining time to show on right track label rather than showing total time
- (void) setShowRemainingTime: (BOOL) showRemainingTime;

/// Determines whether the mediaView can be minimized into the bottom right corner, and then dismissed
- (void) setCanMinimize: (BOOL) canMinimize;

/// Add a mediaView to the queue of mediaViews that will be displayed. If no mediaView is currently showing, this will display that new mediaView
- (void) queueMediaView: (ABMediaView *) mediaView;

/// Will remove the currently displaying mediaView and then display the next in the queue
- (void) showNextMediaView;

/// Present a mediaView by adding it to the main window, and removing whatever previous mediaView was being shown
- (void) presentMediaView:(ABMediaView *) mediaView;

/// Remove a mediaView from the queue
- (void) removeFromQueue:(ABMediaView *) mediaView;

/// Dismiss the mediaView by moving it offscreen and removing it from the queue
- (void) dismissMediaView;

/// Change font for track labels
- (void) setTrackFont: (UIFont *) font;

/// Resets variables from mediaView, removing image and video data
- (void) resetVariables;

@end

@protocol ABMediaViewDelegate <NSObject>

@optional

/// When the mediaView begins playing a video
- (void) mediaViewDidPlayVideo: (ABMediaView *) mediaView;

/// When the mediaView pauses a video
- (void) mediaViewDidPauseVideo: (ABMediaView *) mediaView;

@end
