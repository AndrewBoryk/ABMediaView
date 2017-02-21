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
@class ABPlayer;
#import "VideoTrackView.h"
#import "UIImage+animatedGIF.h"


typedef void (^ImageCompletionBlock)(UIImage *image, NSError *error);
typedef void (^VideoDataCompletionBlock)(NSString *video, NSError *error);

@protocol ABMediaViewDelegate;

extern const NSNotificationName ABMediaViewWillRotateNotification;
extern const NSNotificationName ABMediaViewDidRotateNotification;

/// Preset sizes for the ABMediaView minimized view
extern const CGFloat ABMediaViewRatioPresetPortrait;
extern const CGFloat ABMediaViewRatioPresetSquare;
extern const CGFloat ABMediaViewRatioPresetLandscape;

/// Preset buffer offsets for easy access
extern const CGFloat ABBufferStatusBar;
extern const CGFloat ABBufferNavigationBar;
extern const CGFloat ABBufferStatusAndNavigationBar;
extern const CGFloat ABBufferTabBar;

@interface ABMediaView : UIImageView <VideoTrackDelegate, UIGestureRecognizerDelegate> {
    /// Position of the swipe vertically
    CGFloat ySwipePosition;
    
    /// Position of the swipe horizontally
    CGFloat xSwipePosition;
    
    /// Variable tracking offset of video
    CGFloat offset;
    
    /// Determines if video is minimized
    BOOL isMinimized;
    
    /// Keeps track of how much the video has been minimized
    CGFloat offsetPercentage;
    
    /// Determines whether the content's original size is full screen. If you are looking to make it so that when a mediaView is selected from another view, that it opens up in full screen, then set the property 'shouldDisplayFullScreen'
    BOOL isFullscreen;
    
    /// Determines if the video is already loading
    BOOL isLoadingVideo;
    
    /// Recognizer to record user swiping
    UIPanGestureRecognizer *swipeRecognizer;
    
    /// Recognizer to record a user swiping right to dismiss a minimize video
    UIPanGestureRecognizer *dismissRecognizer;
}

@property (weak, nonatomic) id<ABMediaViewDelegate> delegate;

- (instancetype) initWithMediaView: (ABMediaView *) mediaView;

/// Shared Manager, which keeps track of mediaViews
+ (id)sharedManager;

/// Queue which holds an array of mediaViews to be displayed
@property (strong, nonatomic) NSMutableArray *mediaViewQueue;

/// Media view that is currently presented by the manager
@property (strong, nonatomic) ABMediaView *currentMediaView;

/// Main window which the mediaView will be added to
@property (strong, nonatomic) UIWindow *mainWindow;

/// Gradient dark overlay on top of the mediaView which UI can be placed on top of
@property (strong, nonatomic) UIImageView *topOverlay;

/// Height constraint of the top overlay
@property (strong, nonatomic) NSLayoutConstraint *topOverlayHeight;

/// Label at the top of the mediaView, displayed within the topOverlay. Designated for a title, but other text can be inserted
@property (strong, nonatomic) UILabel *titleLabel;

/// Space between the titleLabel and the superview
@property (strong, nonatomic) NSLayoutConstraint *titleTopOffset;

/// Label at the top of the mediaView, displayed within the topOverlay. Designated for details
@property (strong, nonatomic) UILabel *detailsLabel;

/// Space between the detailsLabel and the superview
@property (strong, nonatomic) NSLayoutConstraint *detailsTopOffset;

/// Set a title to the mediaView, displayed in the titleLabel of the topOverlay, without a details
- (void) setTitle:(NSString *)title;

/// Set a title and details to the mediaView, displayed in the titleLabel and detailsLabel of the topOverlay
- (void) setTitle:(NSString *)title withDetails:(NSString *)details;

/// Track which shows the progress of the video being played
@property (strong, nonatomic) VideoTrackView *track;

/// URL endpoint for image
@property (strong, nonatomic) NSString *imageURL;

/// Image cached after loading
@property (strong, nonatomic) UIImage *imageCache;

/// URL endpoint for video
@property (strong, nonatomic) NSString *videoURL;

/// Video location on disk that was cached after loading
@property (strong, nonatomic) NSURL *videoCache;

/// URL endpoint for audio
@property (strong, nonatomic) NSString *audioURL;

/// Audio location on disk that was cached after loading
@property (strong, nonatomic) NSURL *audioCache;

/// URL endpoint for gif
@property (strong, nonatomic) NSString *gifURL;

/// Data for gif
@property (strong, nonatomic) NSData *gifData;

/// Gif cached after loading
@property (strong, nonatomic) UIImage *gifCache;

/// Download video and audio before playing
@property (nonatomic) BOOL preloadVideoAndAudio;

/// Automate caching for media
@property (nonatomic) BOOL shouldCacheMedia;

/// Theme color which will show on the play button and progress track for videos
@property (strong, nonatomic) UIColor *themeColor;

/// Determines whether the video playerLayer should be set to aspect fit mode
@property BOOL videoAspectFit;

/// Determines whether the progress track should be shown for video
@property BOOL showTrack;

/// Determines if the video is already loading
@property (readonly) BOOL isLoadingVideo;

/// Determines if the video should be looped when it reaches completion
@property BOOL allowLooping;

/// Determines whether or not the mediaView is being used in a reusable view
@property BOOL imageViewNotReused;

/// Determines whether the mediaView can be minimized into the bottom right corner, and then dismissed by swiping right on the minimized version
@property (nonatomic) BOOL isMinimizable;

/// Determines whether the mediaView can be dismissed by swiping down on the view, this setting would override isMinimizable
@property (nonatomic) BOOL isDismissable;

/// Determines whether the video occupies the full screen when displayed
@property BOOL shouldDisplayFullscreen;

/// Determines whether the content's original size is full screen. If you are looking to make it so that when a mediaView is selected from another view, that it opens up in full screen, then set the property 'shouldDisplayFullScreen'
@property (readonly) BOOL isFullScreen;

/// Toggle functionality for remaining time to show on right track label rather than showing total time
@property BOOL displayRemainingTime;

/// Toggle functionality for hiding the close button from the fullscreen view. If minimizing is disabled, this functionality is not allowed.
@property BOOL hideCloseButton;

/// Toggle functionality to have the mediaView autoplay the video associated with it after presentation
@property BOOL autoPlayAfterPresentation;

/// Change font for track labels
@property (strong, nonatomic) UIFont *trackFont;

/// Recognizer to record user swiping
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *swipeRecognizer;

/// Recognizer which keeps track of whether the user taps the view to play or pause the video
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

/// Indicator which shows that the video is being loaded
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

/// Custom image can be set for the play button (video)
@property (strong, nonatomic) UIImage *customPlayButton;

/// Custom image can be set for the play button (music)
@property (strong, nonatomic) UIImage *customMusicButton;

/// Play button imageView which shows in the center of the video, notifies the user that a video can be played
@property (strong, nonatomic) UIImageView *videoIndicator;

/// Closes the mediaView when in fullscreen mode
@property (strong, nonatomic) UIButton *closeButton;

/// ABPlayer which will handle video playback
@property (strong, nonatomic) ABPlayer *player;

/// AVPlayerLayer which will display video
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

/// Timer for animating the videoIndicator, to show that the video is loading
@property (strong, nonatomic) NSTimer *animateTimer;

/// Setting this value to true will allow you to have the fullscreen popup originate from the frame of the original view, without having to set the originRect yourself
@property BOOL presentFromOriginRect;

/// Rect that specifies where the mediaView's frame will originate from when presenting, and needs to be converted into its position in the mainWindow
@property CGRect originRect;

/// Rect that specifies where the mediaView's frame will originate from when presenting, and is already converted into its position in the mainWindow
@property CGRect originRectConverted;

/// Original superview for presenting mediaview
@property (strong, nonatomic) UIView *originalSuperview;

/// By default, there is a buffer of 12px on the bottom of the view, and more space can be added by adjusting this bottom buffer. This is useful in order to have the mediaView show above UITabBars, UIToolbars, and other views that need reserved space on the bottom of the screen.
@property (nonatomic) CGFloat bottomBuffer;

/// Ratio that the minimized view will be shruken to, can be set to a custom value or one of the available ABMediaViewRatioPresets. (Height/Width)
@property (nonatomic) CGFloat minimizedAspectRatio;

/// Ratio of the screen's width that the mediaView's minimized view will stretch across.
@property (nonatomic) CGFloat minimizedWidthRatio;

/// Variable tracking offset of video
@property (nonatomic, readonly) CGFloat offset;

/// Position of the swipe vertically
@property (nonatomic, readonly) CGFloat ySwipePosition;

/// Position of the swipe horizontally
@property (nonatomic, readonly) CGFloat xSwipePosition;

/// Determines if video is minimized
@property (readonly) BOOL isMinimized;

/// The width of the view when minimized
@property (nonatomic, readonly) CGFloat minViewWidth;

/// The height of the view when minimized
@property (nonatomic, readonly) CGFloat minViewHeight;

/// The maximum amount of y offset for the mediaView
@property (nonatomic, readonly) CGFloat maxViewOffset;

/// Keeps track of how much the video has been minimized
@property (nonatomic, readonly) CGFloat offsetPercentage;

/// Width of the mainWindow
@property (nonatomic, readonly) CGFloat superviewWidth;

/// Height of the mainWindow
@property (nonatomic, readonly) CGFloat superviewHeight;

/// Ability to offset the subviews at the top of the screen to avoid hiding other views (ie. UIStatusBar)
@property (nonatomic) CGFloat topBuffer;

/// Determines whether the view has a video
@property (readonly) BOOL hasVideo;

/// Determines whether the view has media (video or audio)
@property (readonly) BOOL hasMedia;

/// Determines whether the view is already playing video
@property (readonly) BOOL isPlayingVideo;

/// Determines whether the user can press and hold the image thumbnail for GIF
@property (nonatomic) BOOL pressForGIF;

/// Determines whether user is long pressing thumbnail
@property (nonatomic) BOOL isLongPressing;

/// File being played is from directory
@property (nonatomic) BOOL fileFromDirectory;

/// Clears all meda that have been downloaded to the directory
+ (void) clearABMediaDirectory;

/// Allows functionality to change the videoGravity to aspectFit on the fly
- (void) changeVideoToAspectFit: (BOOL) videoAspectFit;

/// Download the image, display the image, and give completion block
- (void) setImageURL:(NSString *)imageURL withCompletion: (ImageCompletionBlock) completion;

/// Set the url where the video can be downloaded from
- (void) setVideoURL:(NSString *)videoURL;

/// Set the url where the video can be downloaded from, as well as the url where the thumbnail image can be found
- (void) setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *) thumbnailURL;

/// Set the url where the video can be downloaded from, as well as the url where the thumbnail gif can be found
- (void) setVideoURL:(NSString *)videoURL withThumbnailGifURL:(NSString *) thumbnailGifURL;

/// Set the url where the video can be downloaded from, as well as the data for the thumbnail gif
- (void) setVideoURL:(NSString *)videoURL withThumbnailGifData:(NSData *) thumbnailGifData;

/// Set the url where the video can be downloaded from, as well as the thumbnail image can be found
- (void) setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *) thumbnail;

/// Set the url where the video can be downloaded from, as well as the image for the thumbnail, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via URL
- (void) setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *) thumbnail andPreviewGifURL:(NSString *) previewGifURL;

/// Set the url where the video can be downloaded from, as well as the image for the thumbnail, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via NSData
- (void) setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *) thumbnail andPreviewGifData:(NSData *) previewGifData;

/// Set the url where the video can be downloaded from, as well as the url where the thumbnail image can be found, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via URL
- (void) setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *) thumbnailURL andPreviewGifURL:(NSString *) previewGifURL;


/// Set the url where the video can be downloaded from, as well as the url where the thumbnail image can be found, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via NSData
- (void) setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *) thumbnailURL andPreviewGifData:(NSData *) previewGifData;


/// Set the url where the audio can be downloaded from, as well as the url where the thumbnail image can be found
- (void) setAudioURL:(NSString *)audioURL withThumbnailURL: (NSString *)thumbnailURL;

/// Set the url where the audio can be downloaded from, as well as the url where the thumbnail gif can be found
- (void) setAudioURL:(NSString *)audioURL withThumbnailGifURL: (NSString *)thumbnailGifURL;

/// Set the url where the audio can be downloaded from, as well as the data for the thumbnail gif
- (void) setAudioURL:(NSString *)audioURL withThumbnailGifData: (NSData *)thumbnailGifData;

/// Set the url where the audio can be downloaded from, as well as the thumbnail image can be found
- (void) setAudioURL:(NSString *)audioURL withThumbnailImage: (UIImage *)thumbnail;

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
- (void) handleTapFromRecognizer;

/// Toggle functionality for remaining time to show on right track label rather than showing total time
- (void) setShowRemainingTime: (BOOL) showRemainingTime;

/// Add a mediaView to the queue of mediaViews that will be displayed. If no mediaView is currently showing, this will display that new mediaView
- (void) queueMediaView: (ABMediaView *) mediaView;

/// Will remove the currently displaying mediaView and then display the next in the queue
- (void) presentNextMediaView;

/// Present a mediaView by adding it to the main window, and removing whatever previous mediaView was being shown.
- (void) presentMediaView:(ABMediaView *) mediaView;

/// Present a mediaView by adding it to the main window, and removing whatever previous mediaView was being shown. Has an option to decide whether or not presentation should be animated.
- (void) presentMediaView:(ABMediaView *) mediaView animated: (BOOL) animated;

/// Remove a mediaView from the queue
- (void) removeFromQueue:(ABMediaView *) mediaView;

/// Dismiss the mediaView by moving it offscreen and removing it from the queue
- (void) dismissMediaViewAnimated:(BOOL) animated withCompletion:(void (^)(BOOL completed))completion;

/// Resets variables from mediaView, removing image, video, audio and GIF data
- (void) resetVariables;

/// Removes image, video, audio and GIF data
- (void) resetMediaInView;

/// Sets the close button to hidden, only allowed if isMinimizable is true
- (void) hideCloseButton: (BOOL) hideButton;

/// Determines how audio will be played when the media is playing and the app has silent mode on
+ (void) setPlaysAudioWhenPlayingMediaOnSilent:(BOOL)playAudioOnSilent;

/// Determines how audio will be played when the media is stopping and the app has silent mode on
+ (void) setPlaysAudioWhenStoppingMediaOnSilent:(BOOL)playAudioOnSilent;

@end

@protocol ABMediaViewDelegate <NSObject>

@optional

/// A listener to know what percentage that the view has minimized, at a value from 0 to 1
- (void) mediaView: (ABMediaView *) mediaView didChangeOffset: (float) offsetPercentage;

/// When the mediaView begins playing a video
- (void) mediaViewDidPlayVideo: (ABMediaView *) mediaView;

/// When the mediaView pauses a video
- (void) mediaViewDidPauseVideo: (ABMediaView *) mediaView;

/// Called when the mediaView has begun the presentation process
- (void) mediaViewWillPresent: (ABMediaView *) mediaView;

/// Called when the mediaView has been presented
- (void) mediaViewDidPresent: (ABMediaView *) mediaView;

/// Called when the mediaView has begun the dismissal process
- (void) mediaViewWillDismiss: (ABMediaView *) mediaView;

/// Called when the mediaView has completed the dismissal process. Useful if not looking to utilize the dismissal completion block
- (void) mediaViewDidDismiss: (ABMediaView *) mediaView;

/// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
- (void) mediaViewWillChangeMinimization:(ABMediaView *)mediaView;

/// Called when the mediaView is in the process of minimizing, and has made a change in frame
- (void) mediaViewDidChangeMinimization:(ABMediaView *)mediaView;

/// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
- (void) mediaViewWillEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized;

/// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
- (void) mediaViewDidEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized;

/// Called when the 'image' value of the UIImageView has been set
- (void) mediaView:(ABMediaView *)mediaView didSetImage:(UIImage *) image;

/// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
- (void) mediaViewWillChangeDismissing:(ABMediaView *)mediaView;

/// Called when the mediaView is in the process of minimizing, and has made a change in frame
- (void) mediaViewDidChangeDismissing:(ABMediaView *)mediaView;

/// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
- (void) mediaViewWillEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss;

/// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
- (void) mediaViewDidEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss;

/// Called when the mediaView has completed downloading the image from the web
- (void) mediaView:(ABMediaView *)mediaView didDownloadImage:(UIImage *) image;

/// Called when the mediaView has completed downloading the video from the web
- (void) mediaView:(ABMediaView *)mediaView didDownloadVideo: (NSURL *)video;

/// Called when the mediaView has completed downloading the audio from the web
- (void) mediaView:(ABMediaView *)mediaView didDownloadAudio:(NSURL *)audio;

/// Called when the mediaView has completed downloading the gif from the web
- (void) mediaView:(ABMediaView *)mediaView didDownloadGif:(UIImage *)gif;

/// Called when the user taps the title label
- (void) handleTitleSelectionInMediaView:(ABMediaView *)mediaView;

/// Called when the user taps the details label
- (void) handleDetailsSelectionInMediaView:(ABMediaView *)mediaView;

@end
