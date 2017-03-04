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
#import "ABTrackView.h"
#import "UIImage+animatedGIF.h"
@class ABLabel;

/// Different types of directory items
typedef NS_ENUM(NSInteger, DirectoryItemType) {
    VideoDirectoryItems,
    AudioDirectoryItems,
    AllDirectoryItems,
    TempDirectoryItems,
};

/// Image completed loading onto ABMediaView
typedef void (^ImageCompletionBlock)(UIImage *image, NSError *error);

/// Video completed loading onto ABMediaView
typedef void (^VideoDataCompletionBlock)(NSString *video, NSError *error);

/// Delegate for the ABMediaView
@protocol ABMediaViewDelegate;

/// Notification that the device will rotate
extern const NSNotificationName ABMediaViewWillRotateNotification;

/// Notification that the device did rotate
extern const NSNotificationName ABMediaViewDidRotateNotification;

/// Preset size for minimized view to be in portrait ratio (9:16)
extern const CGFloat ABMediaViewRatioPresetPortrait;

/// Preset size for minimized view to be in square ratio (1:1)
extern const CGFloat ABMediaViewRatioPresetSquare;

/// Preset size for minimized view to be in landscape ratio (16:9)
extern const CGFloat ABMediaViewRatioPresetLandscape;

/// Preset buffer offset for 20px
extern const CGFloat ABBufferStatusBar;

/// Preset buffer offset for 44px
extern const CGFloat ABBufferNavigationBar;

/// Preset buffer offset for 64px
extern const CGFloat ABBufferStatusAndNavigationBar;

/// Preset buffer offset for 48px
extern const CGFloat ABBufferTabBar;

//extern NSString *const ABTestString;

@interface ABMediaView : UIImageView <ABTrackViewDelegate, UIGestureRecognizerDelegate> {
    /// Determines if video is minimized
    BOOL isMinimized;
    
    /// Keeps track of how much the video has been minimized
    CGFloat offsetPercentage;
    
    /// Determines whether the content's original size is full screen. If you are looking to make it so that when a mediaView is selected from another view, that it opens up in full screen, then set the property 'shouldDisplayFullScreen'
    BOOL isFullscreen;
    
    /// Determines if the video is already loading
    BOOL isLoadingVideo;
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

#pragma mark - Data Properties
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

#pragma mark - Interface properties
/// Track which shows the progress of the video being played
@property (strong, nonatomic) ABTrackView *track;

/// Gradient dark overlay on top of the mediaView which UI can be placed on top of
@property (strong, nonatomic) UIImageView *topOverlay;

/// Label at the top of the mediaView, displayed within the topOverlay. Designated for a title, but other text can be inserted
@property (strong, nonatomic) ABLabel *titleLabel;

/// Label at the top of the mediaView, displayed within the topOverlay. Designated for details
@property (strong, nonatomic) ABLabel *detailsLabel;

#pragma mark - Customizable Properties
/// If all media is sourced from the same location, then the ABCacheManager will search the Directory for files with the same name when getting cached objects, since they all have the same remote location
@property (nonatomic) BOOL allMediaFromSameLocation;

/// Download video and audio before playing
@property (nonatomic) BOOL shouldPreloadVideoAndAudio;

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
@property (nonatomic) BOOL closeButtonHidden;

/// Toggle functionality to not have a play button visible
@property (nonatomic) BOOL playButtonHidden;

/// Toggle functionality to have the mediaView autoplay the video associated with it after presentation
@property BOOL autoPlayAfterPresentation;

/// Change font for track labels
@property (strong, nonatomic) UIFont *trackFont;

/// Custom image can be set for the play button (video)
@property (strong, nonatomic) UIImage *customPlayButton;

/// Custom image can be set for the play button (music)
@property (strong, nonatomic) UIImage *customMusicButton;

/// Custom image can be set for when media fails to play
@property (strong, nonatomic) UIImage *customFailedButton;

/// Timer for animating the playIndicatorView, to show that the video is loading
@property (strong, nonatomic) NSTimer *animateTimer;

/// Setting this value to true will allow you to have the fullscreen popup originate from the frame of the original view, without having to set the originRect yourself
@property BOOL presentFromOriginRect;

/// Rect that specifies where the mediaView's frame will originate from when presenting, and needs to be converted into its position in the mainWindow
@property CGRect originRect;

/// Rect that specifies where the mediaView's frame will originate from when presenting, and is already converted into its position in the mainWindow
@property CGRect originRectConverted;

/// By default, there is a buffer of 12px on the bottom of the view, and more space can be added by adjusting this bottom buffer. This is useful in order to have the mediaView show above UITabBars, UIToolbars, and other views that need reserved space on the bottom of the screen.
@property (nonatomic) CGFloat bottomBuffer;

/// Ratio that the minimized view will be shruken to, can be set to a custom value or one of the available ABMediaViewRatioPresets. (Height/Width)
@property (nonatomic) CGFloat minimizedAspectRatio;

/// Ratio of the screen's width that the mediaView's minimized view will stretch across.
@property (nonatomic) CGFloat minimizedWidthRatio;

/// Determines if video is minimized
@property (readonly) BOOL isMinimized;

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

#pragma mark - Initialization Methods

/// Download the image, display the image, and give completion block
- (void)setImageURL:(NSString *)imageURL withCompletion:(ImageCompletionBlock)completion;

/// Set the url where the video can be downloaded from
- (void)setVideoURL:(NSString *)videoURL;

/// Set the url where the video can be downloaded from, as well as the url where the thumbnail image can be found
- (void)setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *)thumbnailURL;

/// Set the url where the video can be downloaded from, as well as the url where the thumbnail gif can be found
- (void)setVideoURL:(NSString *)videoURL withThumbnailGifURL:(NSString *)thumbnailGifURL;

/// Set the url where the video can be downloaded from, as well as the data for the thumbnail gif
- (void)setVideoURL:(NSString *)videoURL withThumbnailGifData:(NSData *)thumbnailGifData;

/// Set the url where the video can be downloaded from, as well as the thumbnail image can be found
- (void)setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *)thumbnail;

/// Set the url where the video can be downloaded from, as well as the image for the thumbnail, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via URL
- (void)setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *)thumbnail andPreviewGifURL:(NSString *)previewGifURL;

/// Set the url where the video can be downloaded from, as well as the image for the thumbnail, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via NSData
- (void)setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *)thumbnail andPreviewGifData:(NSData *)previewGifData;

/// Set the url where the video can be downloaded from, as well as the url where the thumbnail image can be found, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via URL
- (void)setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *)thumbnailURL andPreviewGifURL:(NSString *)previewGifURL;

/// Set the url where the video can be downloaded from, as well as the url where the thumbnail image can be found, and added functionality where when the user presses and holds on the thumbnail, it turns into a GIF. GIF is added via NSData
- (void)setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *)thumbnailURL andPreviewGifData:(NSData *)previewGifData;

/// Download the video associated with this ABMediaView
- (void)preloadVideo;

/// Set the url where the audio can be downloaded from, as well as the url where the thumbnail image can be found
- (void)setAudioURL:(NSString *)audioURL withThumbnailURL:(NSString *)thumbnailURL;

/// Set the url where the audio can be downloaded from, as well as the url where the thumbnail gif can be found
- (void)setAudioURL:(NSString *)audioURL withThumbnailGifURL:(NSString *)thumbnailGifURL;

/// Set the url where the audio can be downloaded from, as well as the data for the thumbnail gif
- (void)setAudioURL:(NSString *)audioURL withThumbnailGifData:(NSData *)thumbnailGifData;

/// Set the url where the audio can be downloaded from, as well as the thumbnail image can be found
- (void)setAudioURL:(NSString *)audioURL withThumbnailImage:(UIImage *)thumbnail;

/// Download the audio associated with this ABMediaView
- (void)preloadAudio;

#pragma mark - Shared Manager Methods
/// Add a mediaView to the queue of mediaViews that will be displayed. If no mediaView is currently showing, this will display that new mediaView
- (void)queueMediaView:(ABMediaView *)mediaView;

/// Will remove the currently displaying mediaView and then display the next in the queue
- (void)presentNextMediaView;

/// Present a mediaView by adding it to the main window, and removing whatever previous mediaView was being shown.
- (void)presentMediaView:(ABMediaView *)mediaView;

/// Present a mediaView by adding it to the main window, and removing whatever previous mediaView was being shown. Has an option to decide whether or not presentation should be animated.
- (void)presentMediaView:(ABMediaView *)mediaView animated:(BOOL)animated;

/// Remove a mediaView from the queue
- (void)removeFromQueue:(ABMediaView *)mediaView;

/// Dismiss the mediaView by moving it offscreen and removing it from the queue
- (void)dismissMediaViewAnimated:(BOOL)animated withCompletion:(void (^)(BOOL completed))completion;

#pragma mark - Reset Methods
/// Clears all meda that have been downloaded to the directory
+ (void)clearABMediaDirectory:(DirectoryItemType)directoryType;

/// Resets variables from mediaView, removing image, video, audio and GIF data
- (void)resetVariables;

/// Removes image, video, audio and GIF data
- (void)resetMediaInView;

#pragma mark - Customization Methods

/// Allows functionality to change the videoGravity to aspectFit on the fly
- (void)changeVideoToAspectFit:(BOOL)videoAspectFit;

/// Determines how audio will be played when the media is playing and the app has silent mode on
+ (void)setPlaysAudioWhenPlayingMediaOnSilent:(BOOL)playAudioOnSilent;

/// Determines how audio will be played when the media is stopping and the app has silent mode on
+ (void)setPlaysAudioWhenStoppingMediaOnSilent:(BOOL)playAudioOnSilent;

/// Toggle functionality for remaining time to show on right track label rather than showing total time
- (void)setShowRemainingTime:(BOOL)showRemainingTime;

/// Set a title to the mediaView, displayed in the titleLabel of the topOverlay, without a details
- (void)setTitle:(NSString *)title;

/// Set a title and details to the mediaView, displayed in the titleLabel and detailsLabel of the topOverlay
- (void)setTitle:(NSString *)title withDetails:(NSString *)details;

@end

@protocol ABMediaViewDelegate <NSObject>

@optional

/// A listener to know what percentage that the view has minimized, at a value from 0 to 1
- (void)mediaView:(ABMediaView *)mediaView didChangeOffset:(float)offsetPercentage;

/// When the mediaView begins playing a video
- (void)mediaViewDidPlayVideo:(ABMediaView *)mediaView;

/// When the mediaView fails to play a video
- (void)mediaViewDidFailToPlayVideo:(ABMediaView *)mediaView;

/// When the mediaView pauses a video
- (void)mediaViewDidPauseVideo:(ABMediaView *)mediaView;

/// Called when the mediaView has begun the presentation process
- (void)mediaViewWillPresent:(ABMediaView *)mediaView;

/// Called when the mediaView has been presented
- (void)mediaViewDidPresent:(ABMediaView *)mediaView;

/// Called when the mediaView has begun the dismissal process
- (void)mediaViewWillDismiss:(ABMediaView *)mediaView;

/// Called when the mediaView has completed the dismissal process. Useful if not looking to utilize the dismissal completion block
- (void)mediaViewDidDismiss:(ABMediaView *)mediaView;

/// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
- (void)mediaViewWillChangeMinimization:(ABMediaView *)mediaView;

/// Called when the mediaView is in the process of minimizing, and has made a change in frame
- (void)mediaViewDidChangeMinimization:(ABMediaView *)mediaView;

/// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
- (void)mediaViewWillEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized;

/// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
- (void)mediaViewDidEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized;

/// Called when the 'image' value of the UIImageView has been set
- (void)mediaView:(ABMediaView *)mediaView didSetImage:(UIImage *)image;

/// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
- (void)mediaViewWillChangeDismissing:(ABMediaView *)mediaView;

/// Called when the mediaView is in the process of minimizing, and has made a change in frame
- (void)mediaViewDidChangeDismissing:(ABMediaView *)mediaView;

/// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
- (void)mediaViewWillEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss;

/// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
- (void)mediaViewDidEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss;

/// Called when the mediaView has completed downloading the image from the web
- (void)mediaView:(ABMediaView *)mediaView didDownloadImage:(UIImage *)image;

/// Called when the mediaView has completed downloading the video from the web
- (void)mediaView:(ABMediaView *)mediaView didDownloadVideo:(NSURL *)video;

/// Called when the mediaView has completed downloading the audio from the web
- (void)mediaView:(ABMediaView *)mediaView didDownloadAudio:(NSURL *)audio;

/// Called when the mediaView has completed downloading the gif from the web
- (void)mediaView:(ABMediaView *)mediaView didDownloadGif:(UIImage *)gif;

/// Called when the user taps the title label
- (void)handleTitleSelectionInMediaView:(ABMediaView *)mediaView;

/// Called when the user taps the details label
- (void)handleDetailsSelectionInMediaView:(ABMediaView *)mediaView;

@end
