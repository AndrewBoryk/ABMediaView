//
//  ABMediaView.m
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import "ABMediaView.h"
#import "ABPlayer.h"
#import "ABCommons.h"
#import "ABVolumeManager.h"
#import "ABCacheManager.h"
#import "ABLabel.h"

const NSNotificationName ABMediaViewWillRotateNotification = @"ABMediaViewWillRotateNotification";
const NSNotificationName ABMediaViewDidRotateNotification = @"ABMediaViewDidRotateNotification";

const CGFloat ABMediaViewRatioPresetPortrait = (16.0f/9.0f);
const CGFloat ABMediaViewRatioPresetSquare = 1.0f;
const CGFloat ABMediaViewRatioPresetLandscape = (9.0f/16.0f);

const CGFloat ABBufferStatusBar = 20.0f;
const CGFloat ABBufferNavigationBar = 44.0f;
const CGFloat ABBufferStatusAndNavigationBar = 64.0f;
const CGFloat ABBufferTabBar = 49.0f;

//NSString *const ABTestString = @"Hello World";

#pragma mark - Private Interface

@interface ABMediaView () <ABLabelDelegate>

#pragma mark - UI Properties

/// Height constraint of the top overlay
@property (strong, nonatomic) NSLayoutConstraint *topOverlayHeight;

/// Space between the titleLabel and the superview
@property (strong, nonatomic) NSLayoutConstraint *titleTopOffset;

/// Space between the detailsLabel and the superview
@property (strong, nonatomic) NSLayoutConstraint *detailsTopOffset;

/// Play button imageView which shows in the center of the video or audio, notifies the user that a video or audio can be played
@property (strong, nonatomic) UIImageView *playIndicatorView;

/// Closes the mediaView when in fullscreen mode
@property (strong, nonatomic) UIButton *closeButton;

/// ABPlayer which will handle video playback
@property (strong, nonatomic) ABPlayer *player;

/// AVPlayerLayer which will display video
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

/// Original superview for presenting mediaview
@property (strong, nonatomic) UIView *originalSuperview;

#pragma mark - Gesture Properties

/// Recognizer to record user swiping
@property (strong, nonatomic) UIPanGestureRecognizer *swipeRecognizer;

/// Recognizer to record a user swiping right to dismiss a minimize video
@property (strong, nonatomic) UIPanGestureRecognizer *dismissRecognizer;

/// Recognizer which keeps track of whether the user taps the view to play or pause the video
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

/// Recognizer for when the thumbnail experiences a long press
@property (strong, nonatomic) UILongPressGestureRecognizer *gifLongPressRecognizer;

#pragma mark - Variable Properties

/// Position of the swipe vertically
@property (nonatomic) CGFloat ySwipePosition;

/// Position of the swipe horizontally
@property (nonatomic) CGFloat xSwipePosition;

/// Variable tracking offset of video
@property (nonatomic) CGFloat offset;

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

/// Number of seconds in the buffer
@property (nonatomic) CGFloat bufferTime;

/// Determines if the play has failed to play media
@property (nonatomic) BOOL failedToPlayMedia;

#pragma mark - Private Methods

/// Remove observers for player
- (void)removeObservers;

/// Selector to play the video from the playRecognizer
- (void)handleTapFromRecognizer;

/// Loads the video, saves to disk, and decides whether to play the video
- (void)loadVideoWithPlay:(BOOL)play withCompletion:(VideoDataCompletionBlock)completion;

/// Show that the video is loading with animation
- (void)loadVideoAnimate;

/// Stop video loading animation
- (void)stopVideoAnimate;

/// Update the frame of the playerLayer
- (void)updatePlayerFrame;

@end

#pragma mark - Implementation

@implementation ABMediaView

@synthesize isMinimized = isMinimized;
@synthesize offsetPercentage = offsetPercentage;
@synthesize isFullScreen = isFullscreen;
@synthesize isLoadingVideo = isLoadingVideo;
@synthesize swipeRecognizer = swipeRecognizer;

+ (id)sharedManager {
    static ABMediaView *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initManager];
    
    });
    return sharedMyManager;
}

#pragma mark - Lifecycle Methods

- (instancetype)initManager {
    self = [super init];
    
    if (self) {
        self.mediaViewQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self layoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updatePlayerFrame];
    
    if ([self hasMedia]) {
        [self.track updateBuffer];
        [self.track updateProgress];
        [self.track updateBarBackground];
    }
    
    CGRect playFrame = self.playIndicatorView.frame;
    CGRect closeFrame = self.closeButton.frame;
    
    CGFloat playSize = 30.0f + (30.0f * (self.frame.size.width / self.superviewWidth));
    
    if ([ABCommons isLandscape]) {
        playSize = 30.0f + (30.0f * (self.frame.size.height / self.superviewWidth));
        closeFrame.origin = CGPointMake(0, 0);
    }
    else {
        closeFrame.origin = CGPointMake(0, 0 + self.topBuffer);
    }
    
    playFrame.size = CGSizeMake(playSize, playSize);
    closeFrame.size = CGSizeMake(50.0f, 50.0f);
    
    
    self.playIndicatorView.frame = playFrame;
    self.playIndicatorView.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    
    self.closeButton.frame = closeFrame;
}

- (instancetype)initWithMediaView:(ABMediaView *)mediaView {
    self = [self initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    
    if (self) {
        
        self.image = mediaView.image;
        
        // Transfer over all attributes from the previous mediaView
        self.contentMode = mediaView.contentMode;
        self.backgroundColor = mediaView.backgroundColor;
        
        self.imageViewNotReused = mediaView.imageViewNotReused;
        [self changeVideoToAspectFit:mediaView.videoAspectFit];
        [self setShowRemainingTime:mediaView.displayRemainingTime];
        [self setFullscreen:YES];
        self.imageCache = mediaView.imageCache;
        [self setImageURL:mediaView.imageURL];
        [self setVideoURL:mediaView.videoURL];
        [self setAudioURL:mediaView.audioURL];
        [self setCustomPlayButton:mediaView.customPlayButton];
        [self setCustomMusicButton:mediaView.customMusicButton];
        
        self.originalSuperview = mediaView.superview;
        
        self.pressForGIF = NO;
        
        self.gifCache = mediaView.gifCache;
        if ([ABCommons notNull:mediaView.gifURL]) {
            if (mediaView.pressForGIF) {
                [self setGifURLPress:mediaView.gifURL];
            }
            else {
                [self setGifURL:mediaView.gifURL];
            }
            
        }
        else if ([ABCommons notNull:mediaView.gifData]) {
            if (mediaView.pressForGIF) {
                [self setGifDataPress:mediaView.gifData];
            }
            else {
                [self setGifData:mediaView.gifData];
            }
        }
        
        
        self.themeColor = mediaView.themeColor;
        
        self.showTrack = mediaView.showTrack;
        [self setTrackFont:mediaView.trackFont];
        self.allowLooping = mediaView.allowLooping;
        self.isMinimizable = mediaView.isMinimizable;
        self.isDismissable = mediaView.isDismissable;
        
        self.shouldDisplayFullscreen = mediaView.shouldDisplayFullscreen;
        [self setCloseButtonHidden: mediaView.closeButtonHidden];
        [self setPlayButtonHidden: mediaView.playButtonHidden];
        self.autoPlayAfterPresentation = mediaView.autoPlayAfterPresentation;
        self.delegate = mediaView.delegate;
        
        NSString *title = nil;
        NSString *details = nil;
        
        if ([ABCommons notNull:mediaView.titleLabel]) {
            if ([ABCommons isValidEntry:mediaView.titleLabel.text]) {
                title = mediaView.titleLabel.text;
            }
            
        }
        
        if ([ABCommons notNull:mediaView.detailsLabel]) {
            if ([ABCommons isValidEntry:mediaView.detailsLabel.text]) {
                details = mediaView.detailsLabel.text;
            }
        }
        
        [self setTitle:title withDetails:details];
        
        if (mediaView.presentFromOriginRect) {
            self.originRect = mediaView.frame;
        }
        else {
            self.originRect = mediaView.originRect;
            self.originRectConverted = mediaView.originRectConverted;
        }
        
        self.topBuffer = mediaView.topBuffer;
        self.bottomBuffer = mediaView.bottomBuffer;
        
        self.minimizedAspectRatio = mediaView.minimizedAspectRatio;
        self.minimizedWidthRatio = mediaView.minimizedWidthRatio;
        
        
        if ([ABCommons isLandscape]) {
            self.swipeRecognizer.enabled = NO;
        }
        
    }
    
    return self;
}

- (void)commonInit {
    self.themeColor = [UIColor cyanColor];
    
    self.minimizedWidthRatio = 0.5f;
    self.minimizedAspectRatio = ABMediaViewRatioPresetLandscape;
    
    [self setBorderAlpha:0.0f];
    self.layer.borderWidth = 1.0f;
    self.autoPlayAfterPresentation = YES;
    
    [self registerForRotation];
    
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.0f;
    self.layer.shadowRadius = 1.0f;
    
    [self addTapGesture];
    
    if (![ABCommons notNull:self.topOverlay]) {
        self.topOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.superviewHeight, 80)];
        self.topOverlay.translatesAutoresizingMaskIntoConstraints = NO;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        
        gradient.frame = self.topOverlay.bounds;
        gradient.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.5f].CGColor, (id)[UIColor clearColor].CGColor];
        
        UIGraphicsBeginImageContextWithOptions(gradient.frame.size, NO, 0);
        
        [gradient renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        [self.topOverlay setImage:outputImage];
    }
    
    if (![ABCommons notNull:self.playIndicatorView]) {
        
        self.playIndicatorView = [[UIImageView alloc] initWithImage: [self imageForPlayButton]];
        self.playIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
        self.playIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        self.playIndicatorView.center = self.center;
        [self.playIndicatorView sizeToFit];
        
    }
    
    if (![ABCommons notNull:self.closeButton]) {
        
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 50.0f)];
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.closeButton setImage:[self imageForCloseButton] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    self.closeButton.alpha = 0;
    
    
    if (![ABCommons notNull:swipeRecognizer]) {
        swipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRecognizer.delegate = self;
        swipeRecognizer.delaysTouchesBegan = YES;
        swipeRecognizer.cancelsTouchesInView = YES;
        swipeRecognizer.maximumNumberOfTouches = 1;
        swipeRecognizer.enabled = NO;
    }
    
    [self addGestureRecognizer:swipeRecognizer];

    swipeRecognizer.enabled = isFullscreen;
    
    if (![ABCommons notNull:self.track]) {
        self.track = [[ABTrackView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60.0f)];
        self.track.translatesAutoresizingMaskIntoConstraints = NO;
        [self.track.progressView setBackgroundColor: self.themeColor];
        self.track.delegate = self;
        
        [swipeRecognizer requireGestureRecognizerToFail:self.track.scrubRecognizer];
        [swipeRecognizer requireGestureRecognizerToFail:self.track.tapRecognizer];
    }
    
    self.track.hidden = YES;
    
    if (![self.subviews containsObject:self.topOverlay]) {
        self.topOverlay.alpha = 0;
        
        [self addSubview:self.topOverlay];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeTrailing
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topOverlay
                                      attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                       constant:0]];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeLeading
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topOverlay
                                      attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                       constant:0]];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topOverlay
                                      attribute:NSLayoutAttributeTop
                                     multiplier:1
                                       constant:0]];
        
        [self updateTopOverlayHeight];
        [self.topOverlay addConstraint:self.topOverlayHeight];
        
        [self.topOverlay layoutIfNeeded];
        
    }
    
    if (![self.subviews containsObject:self.closeButton]) {
        [self addSubview:self.closeButton];
        
        [self bringSubviewToFront:self.closeButton];
    }
    
    if (![self.subviews containsObject:self.playIndicatorView]) {
        self.playIndicatorView.alpha = 0;
        
        [self addSubview:self.playIndicatorView];
        
        [self bringSubviewToFront:self.playIndicatorView];
    }
    
    
    
    if (![self.subviews containsObject:self.track] && [ABCommons notNull:self.track]) {
        
        [self addSubview:self.track];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeTrailing
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.track
                                      attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                       constant:0]];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeLeading
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.track
                                      attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                       constant:0]];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.track
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                       constant:0]];
        
        [self.track addConstraint:[NSLayoutConstraint constraintWithItem:self.track
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:60.0f]];
        
        [self.track layoutIfNeeded];
    }
    
    self.backgroundColor = [ABCommons colorWithHexString:@"EFEFF4"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubviews)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubviews)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVideoEnteringBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Initialization Methods
- (void)setImage:(UIImage *)image {
    [super setImage:image];
    
    if ([self.delegate respondsToSelector:@selector(mediaView:didSetImage:)]) {
        [self.delegate mediaView:self didSetImage:self.image];
    }
}

- (void)setImageURL:(NSString *)imageURL {
    [self setImageURL:imageURL withCompletion:nil];
}

- (void)setImageURL:(NSString *)imageURL withCompletion:(ImageCompletionBlock)completion {
    _imageURL = imageURL;
    
    if (!self.imageViewNotReused) {
        self.image = nil;
    }
    
    if ([ABCommons notNull:imageURL]) {
        UIImage *fileImage = [ABCacheManager getCache:ImageCache objectForKey:imageURL];
        if ([ABCommons notNull: fileImage]) {
            self.imageCache = fileImage;
            
            if (!self.isLongPressing || self.isFullScreen) {
                self.image = self.imageCache;
            }
            
            if ([ABCommons notNull:completion]) {
                completion(self.imageCache, nil);
            }
        }
        else {
            if ([ABCommons notNull:self.imageCache]) {
                if (!self.isLongPressing || self.isFullScreen) {
                    self.image = self.imageCache;
                }
                
                
                if ([ABCommons notNull:completion]) {
                    completion(self.imageCache, nil);
                }
            }
            else {
                [ABCacheManager loadImage:imageURL completion:^(UIImage *image, NSString *key, NSError *error) {
                    if (!self.isLongPressing || self.isFullScreen) {
                        self.image = image;
                    }
                    
                    self.imageCache = image;
                    
                    if ([ABCommons notNull:completion]) {
                        completion(image, error);
                    }
                }];
                
            }

        }
        
        
    }
    else {
        
        if ([ABCommons notNull:completion]) {
            completion(nil, nil);
        }
    }
}

- (void)setVideoURL:(NSString *)videoURL {
    _videoURL = videoURL;
    self.failedToPlayMedia = NO;
    
    self.track.hidden = YES;
    [self.track setProgress: @0 withDuration: 0];
    [self.track setBuffer: @0 withDuration: 0];
    
    if ([self hasMedia]) {
        self.playIndicatorView.image = [self imageForPlayButton];
        
        self.playIndicatorView.alpha = 1;
    }
    
    if ([ABCommons notNull:self.track]) {
        if ([ABCommons notNull:self.track.scrubRecognizer]) {
            [self.tapRecognizer requireGestureRecognizerToFail:self.track.scrubRecognizer];
        }
        
        if ([ABCommons notNull:self.track.tapRecognizer]) {
            [self.tapRecognizer requireGestureRecognizerToFail:self.track.tapRecognizer];
        }
    }
    
    if ([[ABMediaView sharedManager] shouldPreloadVideoAndAudio]) {
        [self preloadVideo];
    }
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *)thumbnailURL {
    [self setImageURL:thumbnailURL];
    [self setVideoURL:videoURL];
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailGifURL:(NSString *)thumbnailGifURL {
    [self setGifURL:thumbnailGifURL];
    [self setVideoURL:videoURL];
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailGifData:(NSData *)thumbnailGifData {
    [self setGifData:thumbnailGifData];
    [self setVideoURL:videoURL];
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *)thumbnail {
    self.image = thumbnail;
    [self setVideoURL:videoURL];
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *)thumbnail andPreviewGifURL:(NSString *)previewGifURL {
    self.image = thumbnail;
    self.pressForGIF = YES;
    [self setVideoURL:videoURL];
    [self setGifURLPress:previewGifURL];
    
    if (!self.isFullScreen) {
        [self setupGifLongPress];
        
        self.playIndicatorView.image = [self imageForPlayButton];
    }
    
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailImage:(UIImage *)thumbnail andPreviewGifData:(NSData *)previewGifData {
    self.image = thumbnail;
    self.pressForGIF = YES;
    [self setVideoURL:videoURL];
    [self setGifDataPress:previewGifData];
    
    if (!self.isFullScreen) {
        [self setupGifLongPress];
        
        self.playIndicatorView.image = [self imageForPlayButton];
    }
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *)thumbnailURL andPreviewGifURL:(NSString *)previewGifURL {
    [self setImageURL:thumbnailURL];
    self.pressForGIF = YES;
    [self setVideoURL:videoURL];
    [self setGifURLPress:previewGifURL];
    
    if (!self.isFullScreen) {
        [self setupGifLongPress];
        
        self.playIndicatorView.image = [self imageForPlayButton];
    }
}

- (void)setVideoURL:(NSString *)videoURL withThumbnailURL:(NSString *)thumbnailURL andPreviewGifData:(NSData *)previewGifData {
    [self setImageURL:thumbnailURL];
    self.pressForGIF = YES;
    [self setVideoURL:videoURL];
    [self setGifDataPress:previewGifData];
    
    if (!self.isFullScreen) {
        [self setupGifLongPress];
        
        self.playIndicatorView.image = [self imageForPlayButton];
    }
}

- (void)setAudioURL:(NSString *)audioURL {
    _audioURL = audioURL;
    
    self.track.hidden = YES;
    [self.track setProgress: @0 withDuration: 0];
    [self.track setBuffer: @0 withDuration: 0];
    
    if ([self hasMedia]) {
        self.playIndicatorView.image = [self imageForPlayButton];
        
        self.playIndicatorView.alpha = 1;
    }
    
    if ([ABCommons notNull:self.track]) {
        
        if ([ABCommons notNull:self.track.scrubRecognizer]) {
            [self.tapRecognizer requireGestureRecognizerToFail:self.track.scrubRecognizer];
        }
        
        if ([ABCommons notNull:self.track.tapRecognizer]) {
            [self.tapRecognizer requireGestureRecognizerToFail:self.track.tapRecognizer];
        }
        
    }
    
    if ([[ABMediaView sharedManager] shouldPreloadVideoAndAudio]) {
        [self preloadAudio];
    }
}

- (void)setAudioURL:(NSString *)audioURL withThumbnailURL:(NSString *)thumbnailURL {
    [self setImageURL:thumbnailURL];
    [self setAudioURL:audioURL];
}

- (void)setAudioURL:(NSString *)audioURL withThumbnailGifURL:(NSString *)thumbnailGifURL {
    [self setGifURL:thumbnailGifURL];
    [self setAudioURL:audioURL];
}

- (void)setAudioURL:(NSString *)audioURL withThumbnailGifData:(NSData *)thumbnailGifData {
    [self setGifData:thumbnailGifData];
    [self setAudioURL:audioURL];
}

- (void)setAudioURL:(NSString *)audioURL withThumbnailImage:(UIImage *)thumbnail {
    self.image = thumbnail;
    [self setAudioURL:audioURL];
}

- (void)setGifURLPress:(NSString *)gifURL {
    _gifURL = gifURL;
    
    if ([ABCommons notNull:self.gifURL]) {
        
        if ([ABCommons notNull:self.gifCache]) {
            
            if (self.isLongPressing && !self.isFullScreen) {
                self.image = self.gifCache;
            }
            
        } else {
            [ABCacheManager loadGIF:self.gifURL completion:^(UIImage *gif, NSString *key, NSError *error) {
                
                if (self.isLongPressing && !self.isFullScreen) {
                    self.image = gif;
                }
                
                self.gifCache = gif;
            }];
        }
        
    }
    
}

- (void)setGifURL:(NSString *)gifURL {
    _gifURL = gifURL;
    
    if ([ABCommons notNull:self.gifURL]) {
        
        if ([ABCommons notNull:self.gifCache]) {
            self.image = self.gifCache;
        } else {
            [ABCacheManager loadGIF:self.gifURL completion:^(UIImage *gif, NSString *key, NSError *error) {
                self.image = gif;
                self.gifCache = gif;
            }];
        }
    }
    
}

- (void)setGifData:(NSData *)gifData {
    _gifData = gifData;
    
    if ([ABCommons notNull:self.gifData]) {
        
        if ([ABCommons notNull:self.gifCache]) {
            self.image = self.gifCache;
        } else {
            [ABCacheManager loadGIFData:self.gifData completion:^(UIImage *gif, NSString *key, NSError *error) {
                self.image = gif;
                self.gifCache = gif;
            }];
        }
        
    }
    
}

- (void)setGifDataPress:(NSData *)gifData {
    _gifData = gifData;
    
    if ([ABCommons notNull:self.gifData]) {
        
        if ([ABCommons notNull:self.gifCache]) {
            
            if (self.isLongPressing && !self.isFullScreen) {
                self.image = self.gifCache;
            }
            
        } else {
            [ABCacheManager loadGIFData:gifData completion:^(UIImage *gif, NSString *key, NSError *error) {
                
                if (self.isLongPressing && !self.isFullScreen) {
                    self.image = gif;
                }
                
                self.gifCache = gif;
            }];
        }
        
    }
    
}

#pragma mark - Shared Manager Methods

- (void)queueMediaView: (ABMediaView *) mediaView {
    
    if ([ABCommons notNull:mediaView]) {
        [self.mediaViewQueue addObject:mediaView];
    }
    
}

- (void)presentNextMediaView {
    
    if (self.mediaViewQueue.count) {
        [[ABMediaView sharedManager] presentMediaView:[self.mediaViewQueue firstObject]];
    } else {
        
        if ([ABCommons notNull: [[ABMediaView sharedManager] currentMediaView]]) {
            [[[ABMediaView sharedManager] currentMediaView] dismissMediaViewAnimated:YES withCompletion:^(BOOL completed) {
                NSLog(@"No mediaView in queue");
            }];
        } else {
            NSLog(@"No mediaView in queue");
        }
        
    }
    
}

- (void)presentMediaView:(ABMediaView *)mediaView {
    [[ABMediaView sharedManager] presentMediaView:mediaView animated:YES];
}

- (void)presentMediaView:(ABMediaView *) mediaView animated:(BOOL)animated {
    
    if ([ABCommons notNull: [[ABMediaView sharedManager] currentMediaView]]) {
        [[[ABMediaView sharedManager] currentMediaView] dismissMediaViewAnimated:YES withCompletion:^(BOOL completed) {
            [[ABMediaView sharedManager] removeFromQueue:mediaView];
            [[ABMediaView sharedManager] handleMediaViewPresentation:mediaView animated:animated];
        }];
    } else {
        [[ABMediaView sharedManager] removeFromQueue:mediaView];
        [[ABMediaView sharedManager] handleMediaViewPresentation:mediaView animated:animated];
    }
    
}

- (void)handleMediaViewPresentation:(ABMediaView *)mediaView animated:(BOOL)animated {
    
    if ([mediaView.delegate respondsToSelector:@selector(mediaViewWillPresent:)]) {
        [mediaView.delegate mediaViewWillPresent:mediaView];
    }
    
    self.mainWindow = [[UIApplication sharedApplication] keyWindow];
    [self.mainWindow makeKeyAndVisible];
    
    [mediaView setFullscreen:YES];
    [mediaView handleCloseButtonDisplay:mediaView];
    
    if (!mediaView.autoPlayAfterPresentation) {
        [mediaView handleTopOverlayDisplay:mediaView];
    }
    
    mediaView.backgroundColor = [UIColor blackColor];
    
    if (!CGRectIsEmpty(mediaView.originRect)) {
        
        if (CGRectIsEmpty(mediaView.originRectConverted)) {
            
            if ([ABCommons notNull:mediaView.originalSuperview]) {
                mediaView.originRectConverted = [mediaView.originalSuperview convertRect:mediaView.originRect toView:self.mainWindow];
            } else {
                mediaView.originRectConverted = [self convertRect:mediaView.originRect toView:self.mainWindow];
            }
            
        }
        
    }
    
    if (!CGRectIsEmpty(mediaView.originRectConverted)) {
        mediaView.alpha = 1;
        mediaView.frame = mediaView.originRectConverted;
        mediaView.closeButton.alpha = 0;
        mediaView.topOverlay.alpha = 0;
        mediaView.titleLabel.alpha = 0;
        mediaView.detailsLabel.alpha = 0;
        [mediaView layoutSubviews];
        [self.mainWindow addSubview:mediaView];
        [self.mainWindow bringSubviewToFront:mediaView];
        
        [[ABMediaView sharedManager] setCurrentMediaView:mediaView];
        
        float animationTime = 0.0f;
        
        if (animated) {
            animationTime = 0.5f;
        }
        
        [UIView animateWithDuration:animationTime delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            //            mediaView.playIndicatorView.center = mediaView.center;
            mediaView.frame = mediaView.superview.frame;
            [mediaView handleCloseButtonDisplay:mediaView];
            
            if (!mediaView.autoPlayAfterPresentation) {
                [mediaView handleTopOverlayDisplay:mediaView];
            }
            
            [mediaView layoutSubviews];
        } completion:^(BOOL finished) {
            
            if ([mediaView.delegate respondsToSelector:@selector(mediaViewDidPresent:)]) {
                [mediaView.delegate mediaViewDidPresent:mediaView];
            }
            
            if ([mediaView hasMedia] && mediaView.autoPlayAfterPresentation) {
                [mediaView handleTapFromRecognizer];
            }
            
        }];
    } else {
        mediaView.alpha = 0;
        mediaView.closeButton.alpha = 0;
        mediaView.topOverlay.alpha = 0;
        mediaView.titleLabel.alpha = 0;
        mediaView.detailsLabel.alpha = 0;
        mediaView.frame = self.mainWindow.frame;
        [self.mainWindow addSubview:mediaView];
        [self.mainWindow bringSubviewToFront:mediaView];
        
        [[ABMediaView sharedManager] setCurrentMediaView:mediaView];
        
        float animationTime = 0.0f;
        
        if (animated) {
            animationTime = 0.25f;
        }
        
        [UIView animateWithDuration:animationTime delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            mediaView.alpha = 1;
            [mediaView handleCloseButtonDisplay:mediaView];
            
            if (!mediaView.autoPlayAfterPresentation) {
                [mediaView handleTopOverlayDisplay:mediaView];
            }
            
        } completion:^(BOOL finished) {
            
            if ([mediaView.delegate respondsToSelector:@selector(mediaViewDidPresent:)]) {
                [mediaView.delegate mediaViewDidPresent:mediaView];
            }
            
            if ([mediaView hasMedia] && mediaView.autoPlayAfterPresentation) {
                [mediaView handleTapFromRecognizer];
            }
            
        }];
    }
    
}

- (void)removeFromQueue:(ABMediaView *)mediaView {
    if ([ABCommons notNull:mediaView] && self.mediaViewQueue.count) {
        [self.mediaViewQueue removeObject:mediaView];
    }
}

- (void)dismissMediaViewAnimated:(BOOL)animated withCompletion:(void (^)(BOOL completed))completion {
    
    if (self.isFullScreen) {
        
        if ([self.delegate respondsToSelector:@selector(mediaViewWillDismiss:)]) {
            [self.delegate mediaViewWillDismiss:self];
        }
        
        self.userInteractionEnabled = NO;

        float animationTime = 0.0f;
        
        if (animated) {
            animationTime = 0.25f;
        }
        
        [UIView animateWithDuration:animationTime delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            
            if (self.isDismissable) {
                self.frame = CGRectMake(0, self.superviewHeight, self.superviewWidth, self.superviewHeight);
            }
            else if (self.isMinimizable && self.isMinimized) {
                self.frame = CGRectMake(self.superviewWidth, self.maxViewOffset, self.minViewWidth, self.minViewHeight);
                [self setBorderAlpha:0.0f];
            }
            
            self.alpha = 0;
            
        } completion:^(BOOL finished) {
            [self.player pause];
            
            [self.playerLayer removeFromSuperlayer];
            self.playerLayer = nil;
            self.player = nil;
            self.image = nil;
            [self removeFromSuperview];
            
            self.userInteractionEnabled = YES;
            
            if ([self.delegate respondsToSelector:@selector(mediaViewDidDismiss:)]) {
                [self.delegate mediaViewDidDismiss:self];
            }
            
            [[ABMediaView sharedManager] setCurrentMediaView:nil];
            
            if ([ABCommons notNull:completion]) {
                completion(YES);
            }
            
        }];
    }
    
}

#pragma mark - Reset Methods

- (void)resetMediaInView {
    self.failedToPlayMedia = NO;
    
    _imageURL = nil;
    _imageCache = nil;
    _videoCache = nil;
    _videoURL = nil;
    _gifURL = nil;
    _gifData = nil;
    _gifCache = nil;
    _audioURL = nil;
    _audioCache = nil;
    
    if ([ABCommons notNull:self.gifLongPressRecognizer]) {
        
        if ([self.gestureRecognizers containsObject:self.gifLongPressRecognizer]) {
            [self removeGestureRecognizer:self.gifLongPressRecognizer];
        }
        
    }
    
    self.track.hidden = YES;
    
    [self removeObservers];
    
    if ([ABCommons notNull:self.player]) {
        [self.player pause];
    }
    
    self.player = nil;
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    isLoadingVideo = false;
    
    self.image = nil;
    
    self.bufferTime = 0;
    
    self.playIndicatorView.alpha = 0;
    self.closeButton.alpha = 0;
    self.topOverlay.alpha = 0;
    self.titleLabel.alpha = 0;
    self.detailsLabel.alpha = 0;
    
    [self stopVideoAnimate];
    
    self.pressForGIF = NO;
    self.fileFromDirectory = NO;
}

- (void)resetVariables {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self registerForRotation];
    
    self.delegate = nil;
    self.autoPlayAfterPresentation = NO;
    self.closeButtonHidden = NO;
    self.playButtonHidden = NO;
    self.shouldDisplayFullscreen = NO;
    self.allowLooping = NO;
    self.showTrack = NO;
    [self setShowRemainingTime:NO];
    
    [self resetMediaInView];
}

#pragma mark - Notification Methods

- (void)willRotate:(NSNotification *)notification {
    //    Rotation began
    [self orientationChanged:nil];
    
}

- (void)didRotate:(NSNotification *)notification {
    //    Rotation ended
    [self orientationChanged:nil];
}

- (void)registerForRotation {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ABMediaViewWillRotateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ABMediaViewDidRotateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:ABMediaViewWillRotateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:ABMediaViewDidRotateNotification object:nil];
}

- (void)removeObservers {
    @try {
        [self.player removeObserver:self forKeyPath:@"currentItem.status"];
    } @catch(id anException){
        //do nothing, not an observer
    }
    
    @try {
        [self.player removeObserver:self forKeyPath:@"currentItem.loadedTimeRanges"];
    } @catch(id anException){
        //do nothing, not an observer
    }
    
    @try {
        [self.player removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    } @catch(id anException){
        //do nothing, not an observer
    }
    
    @try {
        [self.player removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    } @catch(id anException){
        //do nothing, not an observer
    }
    
    @try {
        [self.player removeObserver:self forKeyPath:@"playbackBufferFull"];
    } @catch(id anException){
        //do nothing, not an observer
    }
}

- (void)orientationChanged:(NSNotification *)notification{
    
    // When rotation is enabled, then the positioning of the imageview which holds the AVPlayerLayer must be adjusted to accomodate this change.
    
    if (self.isFullScreen) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        CGFloat width = screenRect.size.width;
        CGFloat height = screenRect.size.height;
        
        if (UIDeviceOrientationIsPortrait(orientation)) {
            
            if (height < width) {
                CGFloat tempFloat = width;
                width = height;
                height = tempFloat;
            }
            
            swipeRecognizer.enabled = (self.isMinimizable || self.isDismissable);
        } else {
            
            if (height > width) {
                CGFloat tempFloat = width;
                width = height;
                height = tempFloat;
            }
            
            swipeRecognizer.enabled = NO;
        }
        
        isMinimized = NO;
        
        self.frame = CGRectMake(0, 0, width, height);
        self.layer.cornerRadius = 0.0f;
        [self setBorderAlpha:0.0f];
        self.userInteractionEnabled = YES;
        self.track.userInteractionEnabled = YES;
        
        if ((!self.isPlayingVideo || self.isLoadingVideo) && [self hasMedia]) {
            self.playIndicatorView.alpha = 1.0f;
        }
        
        [self handleCloseButtonDisplay:self];
        [self handleTopOverlayDisplay:self];
        
        if (self.isLoadingVideo) {
            [self stopVideoAnimate];
            [self loadVideoAnimate];
        }
        
    }
    
    [self updatePlayerFrame];
    
    if ([self hasMedia]) {
        [self.track updateBuffer];
        [self.track updateProgress];
        [self.track updateBarBackground];
    }
    
    BOOL hasDetails = NO;
    
    if ([ABCommons notNull:self.detailsLabel]) {
        
        if ([ABCommons isValidEntry:self.detailsLabel.text]) {
            hasDetails = YES;
        }
        
    }
    
    [self updateTitleLabelOffsets:hasDetails];
    
    if (hasDetails) {
        [self updateDetailsLabelOffsets];
    }
    
    [self updateTopOverlayHeight];
    [self layoutIfNeeded];
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    // Loop video when end is reached
    
    if (self.allowLooping) {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
    } else {
        [self.player pause];
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
    }
    
    [self cacheStreamedVideo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([ABCommons notNull:keyPath]) {
        
        if ([keyPath isEqualToString:@"currentItem.loadedTimeRanges"]) {
            
            if ([ABCommons notNull:self.player]) {
                
                if ([ABCommons notNull:self.player.currentItem]) {
                    
                    if ([self hasVideo]) {
                        self.image = nil;
                    }
                    
                    if (isnan(self.bufferTime)) {
                        self.bufferTime = 0;
                    }
                    
                    for (NSValue *time in self.player.currentItem.loadedTimeRanges) {
                        CMTimeRange range;
                        [time getValue:&range];
                        
                        if (CMTimeGetSeconds(range.duration) > self.bufferTime) {
                            self.bufferTime = CMTimeGetSeconds(range.duration);
                        }
                        
                    }
                    
                    float duration = CMTimeGetSeconds(self.player.currentItem.duration);
                    
                    [self.track setBuffer:[NSNumber numberWithFloat:self.bufferTime] withDuration:duration];
                    
                    if (self.bufferTime == duration) {
                        [self cacheStreamedVideo];
                    }
                    
                    if (self.showTrack) {
                        self.track.hidden = NO;
                    } else {
                        self.track.hidden = YES;
                    }
                    
                }
                
            }
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            if ([ABCommons notNull:self.player]) {
                
                if ((self.player.rate != 0) && (self.player.error == nil)) {
                    isLoadingVideo = true;
                } else {
                    isLoadingVideo = false;
                }
                
            } else {
                isLoadingVideo = false;
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            if ([self hasVideo]) {
                self.image = nil;
            }
            
            isLoadingVideo = false;
        } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
            
            if ([self hasVideo]) {
                self.image = nil;
            }
            
            isLoadingVideo = false;
        } else if (object == self.player.currentItem && [keyPath isEqualToString:@"status"]) {
            
            if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
                self.failedToPlayMedia = NO;
                self.playIndicatorView.image = [self imageForPlayButton];
                self.playIndicatorView.alpha = 0;
                
            } else if (self.player.currentItem.status == AVPlayerStatusFailed) {
                NSLog(@"AVPlayer Error %@", self.player.currentItem.error);
                self.failedToPlayMedia = YES;
                
                isLoadingVideo = false;
                
                [self stopVideoAnimate];
                self.playIndicatorView.image = [self imageForPlayButton];
                self.playIndicatorView.alpha = 1;
                
                [self.player pause];
                
                if (self.isFullScreen) {
                    
                    if ([self hasTitle:self]) {
                        self.topOverlay.alpha = 1;
                        self.titleLabel.alpha = 1;
                        self.detailsLabel.alpha = 1;
                    }
                    
                }
                
                if ([self.delegate respondsToSelector:@selector(mediaViewDidFailToPlayVideo:)]) {
                    [self.delegate mediaViewDidFailToPlayVideo:self];
                }
                
                [self removeObservers];
                self.player = nil;
                
            } else if (self.player.currentItem.status == AVPlayerItemStatusUnknown) {
                NSLog(@"AVPlayer Unknown");
                self.failedToPlayMedia = YES;
                
                isLoadingVideo = false;
                
                [self stopVideoAnimate];
                self.playIndicatorView.image = [self imageForPlayButton];
                self.playIndicatorView.alpha = 1;
                
                [self.player pause];
                
                if ([self.delegate respondsToSelector:@selector(mediaViewDidFailToPlayVideo:)]) {
                    [self.delegate mediaViewDidFailToPlayVideo:self];
                }
                
                [self removeObservers];
                self.player = nil;
            }
            
        }
        
    }
    
}

#pragma mark - Gesture Methods

- (void)handleSwipe: (UIPanGestureRecognizer *) gesture {
    if (self.isFullScreen) {
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self stopVideoAnimate];
            
            self.track.userInteractionEnabled = NO;
            self.tapRecognizer.enabled = NO;
            self.closeButton.userInteractionEnabled = NO;
            
            if ([ABCommons notNull:self.track]) {
                
                if ([ABCommons notNull:self.track.hideTimer]) {
                    [self.track.hideTimer invalidate];
                    [self.track hideTrack];
                }
                
            }
            
            self.ySwipePosition = [gesture locationInView:self].y;
            self.xSwipePosition = [gesture locationInView:self].x;
            self.offset = self.frame.origin.y;
        } else if (gesture.state == UIGestureRecognizerStateChanged) {
            
            if (self.isDismissable) {
                [self handleSwipeDismissingForRecognizer:gesture];
            } else if (self.isMinimizable) {
                
                if (isMinimized && self.offset == self.maxViewOffset) {
                    CGPoint vel = [gesture velocityInView:self];
                    
                    if (self.frame.origin.x > (self.superviewWidth - (self.minViewWidth + 12.0f))) {
                        [self handleDismissingForRecognizer: gesture];
                    } else {
                        
                        // User dragged towards the right
                        if (vel.x > 0)
                        {
                            float velocityY = vel.y;
                            
                            if (vel.y < 0 && fabsf(velocityY) > vel.x) {
                                // User dragged towards the right, however, he draged upwards more than he dragged right
                                [self handleMinimizingForRecognizer:gesture];
                            } else {
                                [self handleDismissingForRecognizer: gesture];
                            }
                            
                        } else {
                            [self handleMinimizingForRecognizer:gesture];
                        }
                        
                    }
                    
                } else {
                    // The view is not in fully minimized form, and thus can't be dismissed
                    [self handleMinimizingForRecognizer:gesture];
                }
                
            }
            
        } else if (gesture.state == UIGestureRecognizerStateEnded ||
                   gesture.state == UIGestureRecognizerStateFailed ||
                   gesture.state == UIGestureRecognizerStateCancelled) {
            
            if (self.isDismissable) {
                self.userInteractionEnabled = NO;
                
                CGPoint gestureVelocity = [gesture velocityInView:self];
                
                BOOL shouldDismiss = false;
                
                if ((offsetPercentage > 0.25f && offsetPercentage < 0.35f && gestureVelocity.y > 300.0f) || offsetPercentage >= 0.35f) {
                    shouldDismiss = true;
                }
                
                if (shouldDismiss) {
                    
                    if ([self.delegate respondsToSelector:@selector(mediaViewWillEndDismissing:withDismissal:)]) {
                        [self.delegate mediaViewWillEndDismissing:self withDismissal:YES];
                    }
                    
                    [self dismissMediaViewAnimated:YES withCompletion:^(BOOL completed) {
                        
                        if ([self.delegate respondsToSelector:@selector(mediaViewDidEndDismissing:withDismissal:)]) {
                            [self.delegate mediaViewDidEndDismissing:self withDismissal:YES];
                        }
                        
                    }];
                } else {
                    
                    if ([self.delegate respondsToSelector:@selector(mediaViewWillEndDismissing:withDismissal:)]) {
                        [self.delegate mediaViewWillEndDismissing:self withDismissal:NO];
                    }
                    
                    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                        self.frame = self.superview.frame;
                        
                        [self layoutSubviews];
                        
                    } completion:^(BOOL finished) {
                        
                        self.tapRecognizer.enabled = YES;
                        self.closeButton.userInteractionEnabled = YES;
                        
                        self.track.userInteractionEnabled = YES;
                        self.offset = self.frame.origin.y;
                        
                        self.userInteractionEnabled = YES;
                        
                        if ([self.delegate respondsToSelector:@selector(mediaViewDidEndDismissing:withDismissal:)]) {
                            [self.delegate mediaViewDidEndDismissing:self withDismissal:NO];
                        }
                        
                    }];
                }
            } else if (self.isMinimizable) {
                self.userInteractionEnabled = NO;
                
                
                BOOL minimize = false;
                
                if (offsetPercentage >= 0.40f) {
                    minimize = true;
                }
                
                BOOL shouldDismiss = false;
                
                if (self.alpha < 0.6f) {
                    shouldDismiss = true;
                }
                
                if (shouldDismiss) {
                    [self dismissMediaViewAnimated:YES withCompletion:^(BOOL completed) {
                        
                    }];
                }
                else {
                    if ([self.delegate respondsToSelector:@selector(mediaViewWillEndMinimizing:atMinimizedState:)]) {
                        [self.delegate mediaViewWillEndMinimizing:self atMinimizedState:minimize];
                    }
                    
                    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                        
                        if (minimize) {
                            self.frame = CGRectMake(self.superviewWidth - self.minViewWidth - 12.0f, self.maxViewOffset, self.minViewWidth, self.minViewHeight);
                            self.playIndicatorView.alpha = 0;
                            self.closeButton.alpha = 0;
                            self.topOverlay.alpha = 0;
                            self.titleLabel.alpha = 0;
                            self.detailsLabel.alpha = 0;
                            [self setBorderAlpha:1.0f];
                        } else {
                            self.frame = self.superview.frame;
                            
                            if ((!self.isPlayingVideo || self.isLoadingVideo) && [self hasMedia]) {
                                self.playIndicatorView.alpha = 1.0f;
                            }
                            
                            [self handleCloseButtonDisplay:self];
                            [self handleTopOverlayDisplay:self];
                            
                            self.layer.cornerRadius = 0.0f;
                            [self setBorderAlpha:0.0f];
                        }
                        
                        self.alpha = 1;
                        
                        [self layoutSubviews];
                        
                        
                    } completion:^(BOOL finished) {
                        
                        isMinimized = minimize;
                        
                        self.tapRecognizer.enabled = YES;
                        self.closeButton.userInteractionEnabled = YES;
                        
                        self.track.userInteractionEnabled = !isMinimized;
                        self.offset = self.frame.origin.y;
                        
                        self.userInteractionEnabled = YES;
                        
                        if ([self.delegate respondsToSelector:@selector(mediaViewDidEndMinimizing:atMinimizedState:)]) {
                            [self.delegate mediaViewDidEndMinimizing:self atMinimizedState:minimize];
                        }
                        
                        if (self.isLoadingVideo) {
                            [self loadVideoAnimate];
                        }
                        
                    }];
                }
            }
        }
    }
}

- (void)handleDismissingForRecognizer: (UIPanGestureRecognizer *) gesture {
    
    if (self.isFullScreen) {
        CGRect frame = self.frame;
        CGPoint origin = self.frame.origin;
        CGFloat difference = [gesture locationInView:self].x - self.xSwipePosition;
        CGFloat tempOffset = self.frame.origin.x + difference;
        CGFloat offsetRatio = (tempOffset - (self.superviewWidth - self.minViewWidth - 12.0f)) / (self.minViewWidth - 12.0f);
        
        if (offsetRatio >= 1) {
            origin.y = self.maxViewOffset;
            origin.x = self.superviewWidth;
            self.offset = self.maxViewOffset;
            self.alpha = 0;
        } else if (offsetRatio < 0) {
            origin.y = self.maxViewOffset;
            origin.x = self.superviewWidth - (self.minViewWidth + 12.0f);
            self.offset = self.maxViewOffset;
            self.alpha = 1;
        } else {
            origin.y = self.maxViewOffset;
            origin.x += difference;
            self.offset = self.maxViewOffset;
            self.alpha = (1 - offsetRatio);
        }
        
        frame.origin = origin;
        
        [UIView animateWithDuration:0.0f animations:^{
            self.frame = frame;
            [self layoutSubviews];
        }];
        
        
        self.ySwipePosition = [gesture locationInView:self].y;
        self.xSwipePosition = [gesture locationInView:self].x;
    }
    
}

- (void)handleSwipeDismissingForRecognizer: (UIPanGestureRecognizer *) gesture {
    
    if (self.isFullScreen) {
        
        if ([self.delegate respondsToSelector:@selector(mediaViewWillChangeDismissing:)]) {
            [self.delegate mediaViewWillChangeDismissing:self];
        }
        
        CGRect frame = self.frame;
        CGPoint origin = self.frame.origin;
        CGSize size = self.frame.size;
        
        //        [self logFrame:self.superview.frame withTag:@"Superview"];
        //        [self logFrame:frame withTag:@"Subview"];
        
        CGFloat difference = [gesture locationInView:self].y - self.ySwipePosition;
        CGFloat tempOffset = self.offset + difference;
        offsetPercentage = tempOffset / self.superviewHeight;
        
        if (offsetPercentage > 1) {
            offsetPercentage = 1;
        } else if (offsetPercentage < 0) {
            offsetPercentage = 0;
        }
        
        if ([self.delegate respondsToSelector:@selector(mediaView:didChangeOffset:)]) {
            [self.delegate mediaView:self didChangeOffset:offsetPercentage];
        }
        
        CGFloat testOrigin = offsetPercentage * self.superviewHeight;
        
        
        size.width = self.superviewWidth;
        size.height = self.superviewHeight;
        origin.x = 0;
        
        [self setBorderAlpha:0.0f];
        
        if (testOrigin >= self.superviewHeight) {
            origin.y = self.superviewHeight;
            self.offset = self.superviewHeight;
        } else if (testOrigin <= 0) {
            origin.y = 0;
            self.offset = 0.0f;
        } else {
            origin.y = testOrigin;
            self.offset+= difference;
        }
        
        frame.origin = origin;
        frame.size = size;
        
        [UIView animateWithDuration:0.0f animations:^{
            self.frame = frame;
            [self layoutSubviews];
            
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(mediaViewDidChangeDismissing:)]) {
                [self.delegate mediaViewDidChangeDismissing:self];
            }
        }];
        
        self.ySwipePosition = [gesture locationInView:self].y;
        self.xSwipePosition = [gesture locationInView:self].x;
    }
    
}

- (void)handleMinimizingForRecognizer: (UIPanGestureRecognizer *) gesture {
    
    if (self.isFullScreen) {
        
        if ([self.delegate respondsToSelector:@selector(mediaViewWillChangeMinimization:)]) {
            [self.delegate mediaViewWillChangeMinimization:self];
        }
        
        CGRect frame = self.frame;
        CGPoint origin = self.frame.origin;
        CGSize size = self.frame.size;
        
        //        [self logFrame:self.superview.frame withTag:@"Superview"];
        //        [self logFrame:frame withTag:@"Subview"];
        
        CGFloat difference = [gesture locationInView:self].y - self.ySwipePosition;
        CGFloat tempOffset = self.offset + difference;
        offsetPercentage = tempOffset / self.maxViewOffset;
        
        if (offsetPercentage > 1) {
            offsetPercentage = 1;
        } else if (offsetPercentage < 0) {
            offsetPercentage = 0;
        }
        
        if ([self.delegate respondsToSelector:@selector(mediaView:didChangeOffset:)]) {
            [self.delegate mediaView:self didChangeOffset:offsetPercentage];
        }
        
        CGFloat testOrigin = offsetPercentage * self.maxViewOffset;
        
        if (testOrigin >= self.maxViewOffset) {
            origin.y = self.maxViewOffset;
            size.width = self.minViewWidth;
            size.height = self.minViewHeight;
            origin.x = self.superviewWidth - size.width - 12.0f;
            self.offset = self.maxViewOffset;
            //            self.layer.cornerRadius = 1.5f;
            [self setBorderAlpha:1.0f];
            
            if ((!self.isPlayingVideo || self.isLoadingVideo) && [self hasMedia])  {
                self.playIndicatorView.alpha = 0;
            }
            
            self.closeButton.alpha = 0;
            self.topOverlay.alpha = 0;
            self.titleLabel.alpha = 0;
            self.detailsLabel.alpha = 0;
        } else if (testOrigin <= 0) {
            origin.y = 0;
            size.width = self.superviewWidth;
            size.height = self.superviewHeight;
            origin.x = 0;
            self.offset = 0.0f;
            self.layer.cornerRadius = 0;
            [self setBorderAlpha:0.0f];
            
            if ((!self.isPlayingVideo || self.isLoadingVideo) && [self hasMedia])  {
                self.playIndicatorView.alpha = 1.0f;
            }
            
            [self handleCloseButtonDisplay:self];
            [self handleTopOverlayDisplay:self];
        } else {
            origin.y = testOrigin;
            size.width = self.superviewWidth - (offsetPercentage * (self.superviewWidth - self.minViewWidth));
            size.height = self.superviewHeight - (offsetPercentage * (self.superviewHeight - self.minViewHeight));
            origin.x = self.superviewWidth - size.width - (offsetPercentage * 12.0f);
            self.offset+= difference;
            //            self.layer.cornerRadius = 1.5f * offsetPercentage;
            [self setBorderAlpha:offsetPercentage];
            
            if ((!self.isPlayingVideo || self.isLoadingVideo) && [self hasMedia])  {
                self.playIndicatorView.alpha = (1-offsetPercentage);
            }
            
            if (self.isFullScreen) {
                UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
                
                if (self.closeButtonHidden && self.isMinimizable && UIDeviceOrientationIsPortrait(orientation)) {
                    self.closeButton.alpha = 0;
                } else {
                    self.closeButton.alpha = (1-offsetPercentage);
                }
                
                if ([self isPlayingVideo] || ![self hasTitle:self]) {
                    self.topOverlay.alpha = 0;
                    self.titleLabel.alpha = 0;
                    self.detailsLabel.alpha = 0;
                } else {
                    self.topOverlay.alpha = (1-offsetPercentage);
                    self.titleLabel.alpha = (1-offsetPercentage);
                    self.detailsLabel.alpha = (1-offsetPercentage);
                }
                
            } else {
                self.closeButton.alpha = 0;
                self.topOverlay.alpha = 0;
                self.titleLabel.alpha = 0;
                self.detailsLabel.alpha = 0;
            }
            
        }
        
        frame.origin = origin;
        frame.size = size;
        
        [UIView animateWithDuration:0.0f animations:^{
            self.frame = frame;
            [self layoutSubviews];
            
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(mediaViewDidChangeMinimization:)]) {
                [self.delegate mediaViewDidChangeMinimization:self];
            }
        }];
        
        
        self.ySwipePosition = [gesture locationInView:self].y;
        self.xSwipePosition = [gesture locationInView:self].x;
    }
    
}

- (void)handleGifLongPress:(UILongPressGestureRecognizer *)gesture {
    
    if (self.pressForGIF && !self.isFullScreen) {
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            self.isLongPressing = YES;
            
            if ([ABCommons notNull:self.gifCache] && !self.isFullScreen) {
                self.image = self.gifCache;
            } else if ([ABCommons notNull:self.gifURL]) {
                [ABCacheManager loadGIF:self.gifURL completion:^(UIImage *gif, NSString *key, NSError *error) {
                    if (self.isLongPressing && !self.isFullScreen) {
                        self.image = gif;
                    }
                    self.gifCache = gif;
                }];
            } else if ([ABCommons notNull:self.gifData]) {
                [ABCacheManager loadGIFData:self.gifData completion:^(UIImage *gif, NSString *key, NSError *error) {
                    if (self.isLongPressing && !self.isFullScreen) {
                        self.image = gif;
                    }
                    self.gifCache = gif;
                }];
            }
            
            [UIView animateWithDuration:0.25f animations:^{
                self.playIndicatorView.alpha = 0.0f;
            }];
        } else if (gesture.state == UIGestureRecognizerStateEnded ||
                   gesture.state == UIGestureRecognizerStateFailed ||
                   gesture.state == UIGestureRecognizerStateCancelled) {
            self.isLongPressing = NO;
            
            if ([ABCommons notNull:self.imageCache]) {
                
                if (!self.isLongPressing || self.isFullScreen) {
                    self.image = self.imageCache;
                }
                
            } else if ([ABCommons notNull:self.imageURL]) {
                [ABCacheManager loadImage:self.imageURL completion:^(UIImage *image, NSString *key, NSError *error) {
                    
                    if (!self.isLongPressing || self.isFullScreen) {
                        self.image = image;
                    }
                    
                    self.imageCache = image;
                }];
            }
            
            [UIView animateWithDuration:0.25f animations:^{
                self.playIndicatorView.alpha = 1.0f;
            }];
        }
        
    }
    
}

- (void)handleTapFromRecognizer {
    
    ////if the cell that is selected already has a video playing then its paused and if not then play that video
    if (isMinimized) {
        self.userInteractionEnabled = NO;
        
        if ([self.delegate respondsToSelector:@selector(mediaViewWillEndMinimizing:atMinimizedState:)]) {
            [self.delegate mediaViewWillEndMinimizing:self atMinimizedState:NO];
        }
        
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.frame = self.superview.frame;
            
            if ((!self.isPlayingVideo || self.isLoadingVideo) && [self hasMedia]) {
                self.playIndicatorView.alpha = 1.0f;
            }
            
            [self handleCloseButtonDisplay:self];
            [self handleTopOverlayDisplay:self];
            
            [self layoutSubviews];
            
            self.layer.cornerRadius = 0.0f;
            [self setBorderAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            isMinimized = NO;
            self.track.userInteractionEnabled = !isMinimized;
            self.offset = self.frame.origin.y;
            
            self.userInteractionEnabled = YES;
            
            if ([self.delegate respondsToSelector:@selector(mediaViewDidEndMinimizing:atMinimizedState:)]) {
                [self.delegate mediaViewDidEndMinimizing:self atMinimizedState:NO];
            }
            
        }];
    }
    else {
        
        if (self.shouldDisplayFullscreen && !self.isFullScreen) {
            [[ABMediaView sharedManager] presentMediaView:[[ABMediaView alloc] initWithMediaView:self]];
        } else {
            
            if ([ABCommons notNull:self.player]) {
                
                if ((self.player.rate != 0) && (self.player.currentItem.error == nil)) {
                    [self stopVideoAnimate];
                    isLoadingVideo = false;
                    [UIView animateWithDuration:0.15f animations:^{
                        self.playIndicatorView.alpha = 1.0f;
                    }];
                    
                    
                    [self.player pause];
                    
                    [self handleTopOverlayDisplay:self];
                    
                    if ([self.delegate respondsToSelector:@selector(mediaViewDidPauseVideo:)]) {
                        [self.delegate mediaViewDidPauseVideo:self];
                    }
                    
                } else if (!self.isLoadingVideo) {
                    [self stopVideoAnimate];
                    [self hideVideoAnimated:NO];
                    
                    [self.player play];
                    
                    [self handleTopOverlayDisplay:self];
                    
                    if (!self.failedToPlayMedia) {
                        
                        if ([self.delegate respondsToSelector:@selector(mediaViewDidPlayVideo:)]) {
                            [self.delegate mediaViewDidPlayVideo:self];
                        }
                        
                    }
                    
                } else {
                    [self loadVideoAnimate];
                    
                    [self.player play];
                    
                    [self handleTopOverlayDisplay:self];
                    
                    if (!self.failedToPlayMedia) {
                        
                        if ([self.delegate respondsToSelector:@selector(mediaViewDidPlayVideo:)]) {
                            [self.delegate mediaViewDidPlayVideo:self];
                        }
                        
                    }
                    
                }
                
            } else if (!self.isLoadingVideo){
                // If the video hasn't been loaded then load it from backend and save it and then play it
                [self loadVideoWithPlay:YES withCompletion:nil];
            } else if (self.isLoadingVideo) {
                [self stopVideoAnimate];
            }
            
        }
        
    }
    
}

#pragma mark - ABLabel Delegate Methods

- (void)labelDidTouchUpInside:(ABLabel *)label {
    
    if (label.tag == 1000) {
        
        if ([self.delegate respondsToSelector:@selector(handleTitleSelectionInMediaView:)]) {
            [self.delegate handleTitleSelectionInMediaView:self];
        }
        
    }
    else if (label.tag == 2000) {
        
        if ([self.delegate respondsToSelector:@selector(handleDetailsSelectionInMediaView:)]) {
            [self.delegate handleDetailsSelectionInMediaView:self];
        }
        
    }
    
}

#pragma mark - ABTrackView Delegate Methods

- (void)trackView:(ABTrackView *)trackView seekToTime:(float)time {
    
    if ([ABCommons notNull:self.player]) {
        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        CMTime timeCM = CMTimeMakeWithSeconds(time, timeScale);
        [self.player seekToTime:timeCM toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    
}

#pragma mark - Custom Accessor Methods

- (void)setGifCache:(UIImage *)gifCache {
    _gifCache = gifCache;
    
    if ([ABCommons notNull:self.gifCache]) {
        
        if ([self.delegate respondsToSelector:@selector(mediaView:didDownloadGif:)]) {
            [self.delegate mediaView:self didDownloadGif:self.gifCache];
        }
        
    }
}

- (void)setImageCache:(UIImage *)imageCache {
    _imageCache = imageCache;
    
    if ([ABCommons notNull:self.imageCache]) {
        
        if ([self.delegate respondsToSelector:@selector(mediaView:didDownloadImage:)]) {
            [self.delegate mediaView:self didDownloadImage:self.imageCache];
        }
        
    }
}

- (void)setVideoCache:(NSURL *)videoCache {
    _videoCache = videoCache;
    
    if ([ABCommons notNull:self.videoCache]) {
        
        if ([self.delegate respondsToSelector:@selector(mediaView:didDownloadVideo:)]) {
            [self.delegate mediaView:self didDownloadVideo:self.videoCache];
        }
        
    }
}

- (void)setAudioCache:(NSURL *)audioCache {
    _audioCache = audioCache;
    
    if ([ABCommons notNull:self.audioCache]) {
        
        if ([self.delegate respondsToSelector:@selector(mediaView:didDownloadAudio:)]) {
            [self.delegate mediaView:self didDownloadAudio:self.audioCache];
        }
        
    }
}

- (void)setShowRemainingTime:(BOOL)showRemainingTime {
    _displayRemainingTime = showRemainingTime;
    
    if ([ABCommons notNull:self.track]) {
        self.track.showRemainingTime = showRemainingTime;
    }
    
}

- (void)setIsMinimizable:(BOOL)isMinimizable {
    _isMinimizable = isMinimizable;
    
    if ([ABCommons notNull:swipeRecognizer]) {
        
        if (self.isMinimizable || self.isDismissable) {
            swipeRecognizer.enabled = isFullscreen;
        }
        else {
            swipeRecognizer.enabled = NO;
        }
        
    }
    
}

- (void)setIsDismissable:(BOOL)isDismissable {
    _isDismissable = isDismissable;
    
    if ([ABCommons notNull:swipeRecognizer]) {
        swipeRecognizer.enabled = (self.isMinimizable || self.isDismissable);
    }
    
}

- (void)setAllMediaFromSameLocation:(BOOL)allMediaFromSameLocation {
    _allMediaFromSameLocation = allMediaFromSameLocation;
    
    [[ABCacheManager sharedManager] setIsAllMediaFromSameLocation:YES];
}

- (void)setShouldCacheMedia:(BOOL)shouldCacheMedia {
    _shouldCacheMedia = shouldCacheMedia;
    
    [[ABCacheManager sharedManager] setCacheMediaWhenDownloaded:self.shouldCacheMedia];
}

- (void)setCustomPlayButton:(UIImage *)customPlayButton {
    _customPlayButton = customPlayButton;
    
    self.playIndicatorView.image = [self imageForPlayButton];
}

- (void)setCustomMusicButton:(UIImage *)customMusicButton {
    _customMusicButton = customMusicButton;
    
    self.playIndicatorView.image = [self imageForPlayButton];
}

- (void)setTitle:(NSString *)title {
    [self setTitle:title withDetails:nil];
}

- (void)setTitle:(NSString *)title withDetails:(NSString *)details {
    
    [self.titleLabel removeFromSuperview];
    [self.detailsLabel removeFromSuperview];
    self.titleTopOffset = nil;
    self.detailsTopOffset = nil;
    self.titleLabel = nil;
    self.detailsLabel = nil;
    
    BOOL hasTitle = [ABCommons isValidEntry:title];
    BOOL hasDetails = [ABCommons isValidEntry:details];
    
    if (hasTitle) {
        title = [ABCommons trimWhiteAndMultiSpace:title];
        
        self.titleLabel = [[ABLabel alloc] initWithFrame:CGRectMake(0, 0, self.topOverlay.frame.size.width, 16.0f)];
        self.titleLabel.text = title;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
        self.titleLabel.alpha = 0.0f;
        self.titleLabel.touchUpInside = YES;
        self.titleLabel.delegate = self;
        self.titleLabel.tag = 1000;
        
        if (![self.subviews containsObject:self.titleLabel]) {
            [self addSubview:self.titleLabel];
            
            [self addConstraint:
             [NSLayoutConstraint constraintWithItem:self
                                          attribute:NSLayoutAttributeTrailing
                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                             toItem:self.titleLabel
                                          attribute:NSLayoutAttributeTrailing
                                         multiplier:1
                                           constant:50]];
            
            [self addConstraint:
             [NSLayoutConstraint constraintWithItem:self.titleLabel
                                          attribute:NSLayoutAttributeLeading
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                          attribute:NSLayoutAttributeLeading
                                         multiplier:1
                                           constant:50]];
            
            [self updateTitleLabelOffsets:hasDetails];
            [self addConstraint: self.titleTopOffset];
            
            [self.titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:18.0f]];
        }
        
        if (hasDetails) {
            details = [ABCommons trimWhiteAndMultiSpace:details];
            self.detailsLabel = [[ABLabel alloc] initWithFrame:CGRectMake(0, 0, self.topOverlay.frame.size.width, 16.0f)];
            self.detailsLabel.text = details;
            self.detailsLabel.font = [UIFont systemFontOfSize:12.0f];
            self.detailsLabel.alpha = 0.0f;
            self.detailsLabel.touchUpInside = YES;
            self.detailsLabel.delegate = self;
            self.detailsLabel.tag = 2000;
            
            if (![self.subviews containsObject:self.detailsLabel]) {
                [self addSubview:self.detailsLabel];
                
                [self addConstraint:
                 [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                 toItem:self.detailsLabel
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1
                                               constant:50]];
                
                [self addConstraint:
                 [NSLayoutConstraint constraintWithItem:self.detailsLabel
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1
                                               constant:50]];
                
                [self updateDetailsLabelOffsets];
                
                [self addConstraint: self.detailsTopOffset];
                
                [self.detailsLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.detailsLabel
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1
                                                                               constant:18.0f]];
            }
            
        }
        
    }
    
}

- (void)setTopBuffer:(CGFloat)topBuffer {
    
    if (topBuffer < 0) {
        topBuffer = 0;
    }
    else if (topBuffer > 64) {
        topBuffer = 64;
    }
    
    _topBuffer = topBuffer;
    
    [self updateTopOverlayHeight];
    
    BOOL hasDetails = NO;
    
    if ([ABCommons notNull:self.detailsLabel]) {
        if ([ABCommons isValidEntry:self.detailsLabel.text]) {
            hasDetails = YES;
        }
    }
    
    [self updateTitleLabelOffsets:hasDetails];
    
    if (hasDetails) {
        [self updateDetailsLabelOffsets];
    }
    
    [self layoutSubviews];
}

- (void)setFullscreen:(BOOL)fullscreen {
    isFullscreen = fullscreen;
    
    if ([ABCommons notNull:swipeRecognizer]) {
        
        if (self.isMinimizable) {
            swipeRecognizer.enabled = isFullscreen;
        } else {
            swipeRecognizer.enabled = NO;
        }
        
    }
    
}

- (void)setCloseButtonHidden:(BOOL)closeButtonHidden {
    _closeButtonHidden = closeButtonHidden;
    
    [self handleCloseButtonDisplay:self];
}

- (void)setPlayButtonHidden:(BOOL)playButtonHidden {
    _playButtonHidden = playButtonHidden;
    
    self.playIndicatorView.image = [self imageForPlayButton];
}

- (void)setTrackFont:(UIFont *)font {
    _trackFont = font;
    
    if ([ABCommons notNull:font]) {
        [self.track setTrackFont:font];
    }
    
}

- (void)setBottomBuffer:(CGFloat)bottomBuffer {
    _bottomBuffer = bottomBuffer;
    
    if (_bottomBuffer < 0) {
        self.bottomBuffer = 0;
    }
    else if (_bottomBuffer > 120) {
        self.bottomBuffer = 120;
    }
    
}

- (void)setMinimizedAspectRatio:(CGFloat)minimizedAspectRatio {
    
    if (minimizedAspectRatio <= 0) {
        _minimizedAspectRatio = ABMediaViewRatioPresetLandscape;
    }
    else {
        _minimizedAspectRatio = minimizedAspectRatio;
    }
    
}

- (void)setMinimizedWidthRatio:(CGFloat)minimizedWidthRatio {
    _minimizedWidthRatio = minimizedWidthRatio;
    
    CGFloat maxWidthRatio = (self.superviewWidth - 24.0f) / self.superviewWidth;
    
    if (_minimizedWidthRatio < 0.25f) {
        _minimizedWidthRatio = 0.25f;
    }
    else if (_minimizedWidthRatio > maxWidthRatio) {
        _minimizedWidthRatio = maxWidthRatio;
    }
    
}

- (CGFloat)superviewWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    CGFloat height = screenRect.size.height;
    
    if (width > height) {
        return height;
    }
    
    return width;
}

- (CGFloat)superviewHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    CGFloat height = screenRect.size.height;
    
    if (width > height) {
        return width;
    }
    
    return height;
}

- (CGFloat)minViewWidth {
    return self.superviewWidth * self.minimizedWidthRatio;
}

- (CGFloat)minViewHeight {
    return self.minViewWidth * self.minimizedAspectRatio;
}

- (CGFloat)maxViewOffset {
    return (self.superviewHeight - (self.minViewHeight + 12.0f + self.bottomBuffer));
}

- (BOOL)hasMedia {
    return ([self hasVideo] || [ABCommons notNull:self.audioURL]);
}

- (BOOL)hasVideo {
    return [ABCommons notNull:self.videoURL];
}

- (BOOL)isPlayingVideo {
    
    if (self.failedToPlayMedia) {
        return NO;
    }
    
    if ([ABCommons notNull:self.player]) {
        
        if (((self.player.rate != 0) && (self.player.error == nil)) || self.isLoadingVideo) {
            return YES;
        }
        
    }
    
    return NO;
}

- (void)setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    
    self.playIndicatorView.image = [self imageForPlayButton];
    [self.track.progressView setBackgroundColor: self.themeColor];
}

- (void)changeVideoToAspectFit:(BOOL)videoAspectFit {
    
    if (self.videoAspectFit != videoAspectFit) {
        self.videoAspectFit = videoAspectFit;
        
        if ([ABCommons notNull:self.playerLayer]) {
            self.playerLayer.videoGravity = [self videoGravity];
        }
        
    }
    
}

- (NSString *)videoGravity {
    
    if (self.videoAspectFit) {
        return AVLayerVideoGravityResizeAspect;
    } else {
        
        if (self.contentMode == UIViewContentModeScaleAspectFit) {
            return AVLayerVideoGravityResizeAspect;
        } else {
            return AVLayerVideoGravityResizeAspectFill;
        }
        
    }
    
}

#pragma mark - Class Methods
+ (void)clearABMediaDirectory:(DirectoryItemType)directoryType {
    [ABCacheManager clearDirectory:directoryType];
}

+ (void)setPlaysAudioWhenPlayingMediaOnSilent:(BOOL)playAudioOnSilent {
    
    if (playAudioOnSilent)
        [[ABVolumeManager sharedManager] setDefaultAudioPlayingType:PlayAudioWhenSilent];
    else
        [[ABVolumeManager sharedManager] setDefaultAudioPlayingType:DefaultAudio];
    
}

+ (void)setPlaysAudioWhenStoppingMediaOnSilent:(BOOL)playAudioOnSilent {
    
    if (playAudioOnSilent)
        [[ABVolumeManager sharedManager] setDefaultAudioStoppingType:PlayAudioWhenSilent];
    else
        [[ABVolumeManager sharedManager] setDefaultAudioStoppingType:DefaultAudio];
    
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma mark - Public Methods

- (void)preloadVideo {
    
    if ([ABCommons notNull:self.videoURL]) {
        
        if (self.fileFromDirectory) {
            [ABCacheManager loadVideoURL:[NSURL fileURLWithPath:self.videoURL] completion:nil];
        }else {
            [ABCacheManager loadVideo:self.videoURL completion:nil];
        }
        
    }
    
}

- (void)preloadAudio {
    
    if ([ABCommons notNull:self.audioURL]) {
        
        if ([self.audioURL containsString:@"ipod-library://"]) {
            [ABCacheManager loadMusicLibrary:self.audioURL completion:nil];
        } else if (self.fileFromDirectory) {
            [ABCacheManager loadAudioURL:[NSURL fileURLWithPath:self.audioURL] completion:nil];
        } else {
            [ABCacheManager loadAudio:self.audioURL completion:nil];
        }
        
    }
    
}

#pragma mark - Private Methods

- (void)loadVideoWithPlay:(BOOL)play withCompletion:(VideoDataCompletionBlock)completion {
    
    if ([ABCommons notNull:self.videoURL] || [ABCommons notNull:self.audioURL]) {
        
        if (play) {
            [self loadVideoAnimate];
            isLoadingVideo = true;
        }
        
        [self removeObservers];
        
        AVURLAsset *asset;
        
        if ([ABCommons notNull:self.videoURL]) {
            
            if (self.fileFromDirectory) {
                asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoURL] options:nil];
            } else {
                asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.videoURL] options:nil];
            }
            
            NSURL *filePath = [ABCacheManager getCache:VideoCache objectForKey:self.videoURL];
            
            if ([ABCommons notNull:filePath]) {
                self.videoCache = filePath;
                AVURLAsset *cachedVideo = [AVURLAsset assetWithURL:self.videoCache];
                
                if ([ABCommons notNull:cachedVideo]) {
                    asset = cachedVideo;
                }
                
            }
        } else if ([ABCommons notNull:self.audioURL]) {
            asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.audioURL] options:nil];
            
            NSURL *filePath = [ABCacheManager getCache:AudioCache objectForKey:self.audioURL];
            
            if ([ABCommons notNull:filePath]) {
                self.audioCache = filePath;
                AVURLAsset *cachedAudio = [AVURLAsset URLAssetWithURL:self.audioCache options:nil];
                
                if ([ABCommons notNull:cachedAudio]) {
                    asset = cachedAudio;
                }
                
            }
        }
        
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        self.player = [[ABPlayer alloc] initWithPlayerItem:playerItem];
        
        if ([ABCommons notNull:self.player]) {
            
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.player currentItem]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(loadVideoAnimate)
                                                         name:AVPlayerItemPlaybackStalledNotification
                                                       object:[self.player currentItem]];
            
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            self.playerLayer.videoGravity = [self videoGravity];
            
            self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            
            [(AVPlayerLayer *)self.layer setPlayer:self.player];
            
            if (play) {
                [self.player play];
                
                [self handleTopOverlayDisplay:self];
                
                if (!self.failedToPlayMedia) {
                    if ([self.delegate respondsToSelector:@selector(mediaViewDidPlayVideo:)]) {
                        [self.delegate mediaViewDidPlayVideo:self];
                    }
                }
            }
            
            [self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
            
            [self.player addObserver:self
                          forKeyPath:@"currentItem.loadedTimeRanges"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
            
            [self.player addObserver:self
                          forKeyPath:@"playbackBufferEmpty"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
            
            [self.player addObserver:self
                          forKeyPath:@"playbackLikelyToKeepUp"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
            
            [self.player addObserver:self
                          forKeyPath:@"playbackBufferFull"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
            
            CMTime interval = CMTimeMake(10.0, NSEC_PER_SEC);
            
            __weak __typeof(self)weakSelf = self;
            [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                
                if ([ABCommons notNull: weakSelf.player.currentItem]) {
                    
                    if (weakSelf.showTrack) {
                        weakSelf.track.hidden = NO;
                    } else {
                        weakSelf.track.hidden = YES;
                    }
                    
                    CGFloat progress = CMTimeGetSeconds(time);
                    
                    if (progress != 0 && [self.animateTimer isValid]) {
                        isLoadingVideo = false;
                        [weakSelf stopVideoAnimate];
                        [weakSelf hideVideoAnimated: NO];
                    }
                    
                    [weakSelf.track setProgress: [NSNumber numberWithFloat:CMTimeGetSeconds(time)] withDuration: CMTimeGetSeconds(weakSelf.player.currentItem.duration)];
                }
                
            }];
        }
        
    } else {
        
        if ([ABCommons notNull:completion]) {
            completion(nil, nil);
        }
        
    }
}

- (void)adjustSubviews {
    if (self.isFullScreen) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        CGFloat width = screenRect.size.width;
        CGFloat height = screenRect.size.height;
        
        if (![ABCommons isLandscape]) {
            
            if (height < width) {
                CGFloat tempFloat = width;
                width = height;
                height = tempFloat;
            }
            
            swipeRecognizer.enabled = (self.isMinimizable || self.isDismissable);
        } else {
            
            if (height > width) {
                CGFloat tempFloat = width;
                width = height;
                height = tempFloat;
            }
            
            swipeRecognizer.enabled = NO;
            
        }
        
        isMinimized = NO;
        
        self.frame = CGRectMake(0, 0, width, height);
    }
    
    [self layoutSubviews];
}

- (void)pauseVideoEnteringBackground {
    
    if ([self hasMedia]) {
        
        if ([ABCommons notNull:self.player]) {
            
            if ((self.player.rate != 0) && (self.player.error == nil)) {
                [self stopVideoAnimate];
                isLoadingVideo = false;
                [UIView animateWithDuration:0.15f animations:^{
                    self.playIndicatorView.alpha = 1.0f;
                }];
                
                
                [self.player pause];
                
                [self handleTopOverlayDisplay:self];
                
                if ([self.delegate respondsToSelector:@selector(mediaViewDidPauseVideo:)]) {
                    [self.delegate mediaViewDidPauseVideo:self];
                }
                
            }
            
        }
        
    }
    
}

- (BOOL)hasTitle:(ABMediaView *)mediaView {
    
    if ([ABCommons notNull:mediaView]) {
        
        if ([ABCommons notNull:mediaView.titleLabel]) {
            
            if ([ABCommons isValidEntry:mediaView.titleLabel.text]) {
                return YES;
            }
            
        }
        
    }
    
    return NO;
}

- (BOOL)hasDetails:(ABMediaView *)mediaView {
    
    if ([ABCommons notNull:mediaView]) {
        
        if ([ABCommons notNull:mediaView.detailsLabel]) {
            
            if ([ABCommons isValidEntry:mediaView.detailsLabel.text]) {
                return YES;
            }
            
        }
        
    }
    
    return NO;
}

- (void)updateTitleLabelOffsets:(BOOL)hasDetails {
    
    if ([ABCommons notNull:self.titleLabel]) {
        CGFloat constant = 8.0f+self.topBuffer;
        
        if (!hasDetails) {
            constant += 8.0f;
        }
        
        if ([ABCommons isLandscape]) {
            constant -= self.topBuffer;
        }
        
        if ([ABCommons notNull:self.titleTopOffset]) {
            [self layoutIfNeeded];
            self.titleTopOffset.constant = constant;
            [self layoutIfNeeded];
        } else {
            self.titleTopOffset = [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:constant];
        }
        
    }
    
}

- (void)updateDetailsLabelOffsets {
    
    if ([ABCommons notNull:self.titleLabel]) {
        CGFloat constant = 8.0f+self.topBuffer;
        
        if ([ABCommons isLandscape]) {
            constant -= self.topBuffer;
        }
        
        if ([ABCommons notNull:self.detailsTopOffset]) {
            [self layoutIfNeeded];
            self.detailsTopOffset.constant = constant+18.0f;
            [self layoutIfNeeded];
        } else {
            self.detailsTopOffset = [NSLayoutConstraint constraintWithItem:self.detailsLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:constant+18.0f];
        }
    }
}

- (void)updateTopOverlayHeight {
    
    if ([ABCommons notNull:self.topOverlay]) {
        
        CGFloat height = 50.0f+self.topBuffer;
        
        if ([ABCommons isLandscape]) {
            height -= self.topBuffer;
        }
        
        if ([ABCommons notNull:self.topOverlayHeight]) {
            [self layoutIfNeeded];
            self.topOverlayHeight.constant = height;
            [self layoutIfNeeded];
        } else {
            self.topOverlayHeight = [NSLayoutConstraint constraintWithItem:self.topOverlay
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:height];
        }
        
    }
    
}

- (void)setBorderAlpha:(CGFloat)alpha {
    self.layer.borderColor = [[ABCommons colorWithHexString:@"95a5a6"] colorWithAlphaComponent:alpha].CGColor;
    self.layer.shadowOpacity = alpha;
}

- (void)logFrame:(CGRect)frame withTag:(NSString *)tag {
    NSLog(@"%@ - x: %f  y: %f  width: %f  height: %f", tag, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (UIImage *)imageForCloseButton {
    static UIImage *closeX = nil;
    
    CGFloat size = 18.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint:(CGPoint){0, 0}];
    [leftPath addLineToPoint:(CGPoint){size, size}];
    [leftPath closePath];
    
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    [rightPath moveToPoint:(CGPoint){0, size}];
    [rightPath addLineToPoint:(CGPoint){size, 0}];
    [rightPath closePath];
    
    CGColorRef col = [[UIColor whiteColor] colorWithAlphaComponent:1.0f].CGColor;
    CGContextSetFillColorWithColor(ctx, col);
    CGContextSetStrokeColorWithColor(ctx, col);
    CGContextSetLineWidth(ctx, 1.5f);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 1.0f, [UIColor blackColor].CGColor);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextAddPath(ctx, rightPath.CGPath);
    CGContextStrokePath(ctx);
    CGContextAddPath(ctx, rightPath.CGPath);
    CGContextFillPath(ctx);
    CGContextAddPath(ctx, leftPath.CGPath);
    CGContextStrokePath(ctx);
    CGContextAddPath(ctx, leftPath.CGPath);
    CGContextFillPath(ctx);
    
    CGContextRestoreGState(ctx);
    closeX = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return closeX;
}

- (void)closeAction {
    
    if (self.isFullScreen) {
        [self dismissMediaViewAnimated:YES withCompletion:^(BOOL completed) {
            
        }];
    } else {
        self.closeButton.alpha = 0;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)handleCloseButtonDisplay:(ABMediaView *)mediaView {
    
    if (mediaView.isFullScreen) {
        
        if (mediaView.closeButtonHidden && mediaView.isMinimizable && ![ABCommons isLandscape]) {
            mediaView.closeButton.alpha = 0;
        } else {
            mediaView.closeButton.alpha = 1;
        }
        
    } else {
        mediaView.closeButton.alpha = 0;
    }
    
}

- (void)handleTopOverlayDisplay:(ABMediaView *)mediaView {
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (mediaView.isFullScreen) {
            
            if ([self isPlayingVideo] || ![self hasTitle:self]) {
                mediaView.topOverlay.alpha = 0;
                mediaView.titleLabel.alpha = 0;
                mediaView.detailsLabel.alpha = 0;
            } else {
                mediaView.topOverlay.alpha = 1;
                mediaView.titleLabel.alpha = 1;
                mediaView.detailsLabel.alpha = 1;
            }
            
        } else {
            mediaView.topOverlay.alpha = 0;
            mediaView.titleLabel.alpha = 0;
            mediaView.detailsLabel.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setupGifLongPress {
    
    if (![ABCommons notNull:self.gifLongPressRecognizer]) {
        self.gifLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGifLongPress:)];
        self.gifLongPressRecognizer.minimumPressDuration = 0.25f;
        self.gifLongPressRecognizer.delegate = self;
        self.gifLongPressRecognizer.delaysTouchesBegan = NO;
        
    }
    
    if (![self.gestureRecognizers containsObject:self.gifLongPressRecognizer]) {
        [self addGestureRecognizer:self.gifLongPressRecognizer];
    }
    
    if ([ABCommons notNull:self.tapRecognizer]) {
        [self.tapRecognizer requireGestureRecognizerToFail:self.gifLongPressRecognizer];
    }
    
}

- (void)cacheStreamedVideo {
    
    if ([[ABMediaView sharedManager] shouldCacheMedia]) {
        
        if ([ABCommons notNull:self.player.currentItem]) {
            
            if ([ABCommons notNull:self.videoURL]) {
                [ABCacheManager exportAssetURL:self.videoURL type:VideoCache asset:self.player.currentItem.asset];
            } else if ([ABCommons notNull:self.audioURL]) {
                [ABCacheManager exportAssetURL:self.audioURL type:AudioCache asset:self.player.currentItem.asset];
            }
            
        }
        
    }
    
}

- (void)loadVideoAnimate {
    // Set video loader animation timer
    
    [self stopVideoAnimate];
    
    if (self.failedToPlayMedia) {
        self.playIndicatorView.alpha = 1.0f;
        self.playIndicatorView.image = [self imageForPlayButton];
    } else {
        [self animateVideo];
        
        self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.751f target:self selector:@selector(animateVideo) userInfo:nil repeats:YES];
    }
    
}

- (void)stopVideoAnimate {
    // Stop animating video loader
    [self.animateTimer invalidate];
}

- (void)hideVideoAnimated:(BOOL)animated {
    
    if (self.failedToPlayMedia) {
        self.playIndicatorView.alpha = 1.0f;
    } else {
        
        if (animated) {
            [UIView animateWithDuration:0.15f animations:^{
                self.playIndicatorView.alpha = 0.0f;
            }];
        } else {
            self.playIndicatorView.alpha = 0.0f;
        }
        
    }
    
}

- (void)animateVideo {
    // Animate video loader fade in and out
    BOOL showAnimation = true;
    
    if ([self hasMedia]) {
        
        if (!self.isLoadingVideo) {
            showAnimation = false;
        }
        
    }
    
    if (self.failedToPlayMedia) {
        self.playIndicatorView.alpha = 1.0f;
    } else {
        
        if (showAnimation) {
            
            if (self.playIndicatorView.alpha == 1.0f) {
                [UIView animateWithDuration:0.75f animations:^{
                    self.playIndicatorView.alpha = 0.4f;
                }];
            } else {
                [UIView animateWithDuration:0.75f animations:^{
                    self.playIndicatorView.alpha = 1.0f;
                }];
            }
            
        } else {
            self.playIndicatorView.alpha = 0.0f;
        }
        
    }
    
}

- (void)updatePlayerFrame {
    
    if ([ABCommons notNull:self.playerLayer]) {
        self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

- (void)addTapGesture {
    
    //initializes gestures
    if (![ABCommons notNull:self.tapRecognizer]) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromRecognizer)];
        self.tapRecognizer.numberOfTapsRequired = 1;
        self.tapRecognizer.delegate = self;
    }
    
    self.userInteractionEnabled = YES;
    
    [self removeGestureRecognizer:self.tapRecognizer];
    
    if (![self.gestureRecognizers containsObject:self.tapRecognizer]) {
        [self addGestureRecognizer:self.tapRecognizer];
    }
    
    if ([ABCommons notNull:self.gifLongPressRecognizer]) {
        [self.tapRecognizer requireGestureRecognizerToFail:self.gifLongPressRecognizer];
    }
    
}

- (UIImage *)imageForPlayButton {
    
    if (self.failedToPlayMedia) {
        
        if ([ABCommons notNull:self.customFailedButton]) {
            return self.customFailedButton;
        } else {
            
            if (self.playButtonHidden) {
                return nil;
            } else {
                static UIImage *playCircle = nil;
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(60.f, 60.0f), NO, 0.0f);
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextSaveGState(ctx);
                
                CGRect rect = CGRectMake(0, 0, 60.0f, 60.0f);
                UIColor *color = self.themeColor;
                
                CGContextSetFillColorWithColor(ctx, [color colorWithAlphaComponent:0.8f].CGColor);
                CGContextFillEllipseInRect(ctx, rect);
                
                UIBezierPath *leftPath = [UIBezierPath bezierPath];
                [leftPath moveToPoint:(CGPoint){18, 18}];
                [leftPath addLineToPoint:(CGPoint){42, 42}];
                [leftPath closePath];
                
                UIBezierPath *rightPath = [UIBezierPath bezierPath];
                [rightPath moveToPoint:(CGPoint){18, 42}];
                [rightPath addLineToPoint:(CGPoint){42, 18}];
                [rightPath closePath];
                
                CGColorRef col = [[UIColor whiteColor] colorWithAlphaComponent:1.0f].CGColor;
                CGContextSetFillColorWithColor(ctx, col);
                CGContextSetStrokeColorWithColor(ctx, col);
                CGContextSetLineWidth(ctx, 1.5f);
                CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 1.0f, [UIColor blackColor].CGColor);
                CGContextSetLineJoin(ctx, kCGLineJoinRound);
                CGContextSetLineCap(ctx, kCGLineCapRound);
                CGContextAddPath(ctx, rightPath.CGPath);
                CGContextStrokePath(ctx);
                CGContextAddPath(ctx, rightPath.CGPath);
                CGContextFillPath(ctx);
                CGContextAddPath(ctx, leftPath.CGPath);
                CGContextStrokePath(ctx);
                CGContextAddPath(ctx, leftPath.CGPath);
                CGContextFillPath(ctx);
                
                CGContextRestoreGState(ctx);
                playCircle = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                return playCircle;
            }
            
        }
        
    } else if (self.playButtonHidden) {
        return nil;
    } else if ([ABCommons notNull:self.customPlayButton] && [ABCommons notNull:self.videoURL]) {
        return self.customPlayButton;
    } else if ([ABCommons notNull:self.customMusicButton] && [ABCommons notNull:self.audioURL]) {
        return self.customMusicButton;
    } else {
        static UIImage *playCircle = nil;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(60.f, 60.0f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGRect rect = CGRectMake(0, 0, 60.0f, 60.0f);
        CGRect rectGIF = CGRectMake(1, 1, 58.0f, 58.0f);
        UIColor *color = self.themeColor;
        
        CGContextSetFillColorWithColor(ctx, [color colorWithAlphaComponent:0.8f].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        if (!self.isFullScreen && self.pressForGIF) {
            CGFloat thickness = 2.0;
            
            CGContextSetLineWidth(ctx, thickness);
            CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            
            CGFloat ra[] = {4,2};
            CGContextSetLineDash(ctx, 0.0, ra, 2); // nb "2" == ra count
            
            CGContextStrokeEllipseInRect(ctx, rectGIF);
        }
        
        CGFloat inset = 15.0f;
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:(CGPoint){20.625f, inset}];
        [bezierPath addLineToPoint:(CGPoint){60.0f - inset, 60.0f/2.0f}];
        [bezierPath addLineToPoint:(CGPoint){20.625f, 60.0f - inset}];
        [bezierPath closePath];
        
        CGColorRef col = [[UIColor whiteColor] colorWithAlphaComponent:0.8f].CGColor;
        CGContextSetFillColorWithColor(ctx, col);
        CGContextSetStrokeColorWithColor(ctx, col);
        CGContextSetLineWidth(ctx, 0);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextStrokePath(ctx);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextFillPath(ctx);
        
        CGContextRestoreGState(ctx);
        playCircle = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return playCircle;
    }
    
}


@end


















