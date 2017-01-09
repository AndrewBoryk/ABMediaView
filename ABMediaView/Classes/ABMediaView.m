//
//  ABMediaView.m
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import "ABMediaView.h"

const NSNotificationName ABMediaViewWillRotateNotification = @"ABMediaViewWillRotateNotification";
const NSNotificationName ABMediaViewDidRotateNotification = @"ABMediaViewDidRotateNotification";

const CGFloat ABMediaViewRatioPresetPortrait = (16.0f/9.0f);
const CGFloat ABMediaViewRatioPresetSquare = 1.0f;
const CGFloat ABMediaViewRatioPresetLandscape = (9.0f/16.0f);

@implementation ABMediaView {
    float bufferTime;
    
    /// Recognizer to record user swiping
    UIPanGestureRecognizer *swipeRecognizer;
    
    /// Recognizer to record a user swiping right to dismiss a minimize video
    UIPanGestureRecognizer *dismissRecognizer;
    
}

@synthesize isMinimized = isMinimized;
@synthesize offsetPercentage = offsetPercentage;
@synthesize offset = offset;
@synthesize ySwipePosition = ySwipePosition;
@synthesize xSwipePosition = xSwipePosition;
@synthesize isFullScreen = isFullscreen;
@synthesize isLoadingVideo = isLoadingVideo;

+ (id)sharedManager {
    static ABMediaView *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initManager];
    
    });
    return sharedMyManager;
}


- (instancetype) initManager {
    self = [super init];
    
    if (self) {
        self.mediaViewQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self layoutSubviews];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    [self updatePlayerFrame];
    
    [self.track updateBuffer];
    [self.track updateBarBackground];
    [self.track updateProgress];
    
    CGRect playFrame = self.videoIndicator.frame;
    CGRect closeFrame = self.closeButton.frame;
    
    CGFloat playSize = 30.0f + (30.0f * (self.frame.size.height / self.superviewHeight));
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        playSize = 30.0f + (30.0f * (self.frame.size.width / self.superviewHeight));
    }
    
    playFrame.size = CGSizeMake(playSize, playSize);
    closeFrame.size = CGSizeMake(50.0f, 50.0f);
    closeFrame.origin = CGPointMake(0, 0);
    
    self.videoIndicator.frame = playFrame;
    self.videoIndicator.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    
    self.closeButton.frame = closeFrame;
}

- (instancetype) initWithMediaView: (ABMediaView *) mediaView {
    self = [self initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    
    if (self) {
        
        // Transfer over all attributes from the previous mediaView
        self.contentMode = mediaView.contentMode;
        self.backgroundColor = mediaView.backgroundColor;
        
        self.imageViewNotReused = mediaView.imageViewNotReused;
        [self changeVideoToAspectFit:mediaView.videoAspectFit];
        [self setShowRemainingTime:mediaView.displayRemainingTime];
        self.imageCache = mediaView.imageCache;
        [self setImageURL:mediaView.imageURL withCompletion:nil];
        [self setVideoURL:mediaView.videoURL];
        self.videoCache = mediaView.videoCache;
        
        self.themeColor = mediaView.themeColor;
        
        self.showTrack = mediaView.showTrack;
        [self setTrackFont:mediaView.trackFont];
        self.allowLooping = mediaView.allowLooping;
        [self setCanMinimize: mediaView.isMinimizable];
        self.shouldDisplayFullscreen = mediaView.shouldDisplayFullscreen;
        [self setFullscreen:mediaView.isFullScreen];
        [self hideCloseButton: mediaView.hideCloseButton];
        
        self.originRect = mediaView.originRect;
        self.originRectConverted = mediaView.originRectConverted;
        self.bottomBuffer = mediaView.bottomBuffer;
        
        self.minimizedAspectRatio = mediaView.minimizedAspectRatio;
        self.minimizedWidthRatio = mediaView.minimizedWidthRatio;
        
    }
    
    return self;
}


- (void) commonInit {
    self.themeColor = [UIColor cyanColor];
    
    self.minimizedWidthRatio = 0.5f;
    self.minimizedAspectRatio = ABMediaViewRatioPresetLandscape;
    
    [self setBorderAlpha:0.0f];
    self.layer.borderWidth = 1.0f;
    
    [self registerForRotation];
    
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.0f;
    self.layer.shadowRadius = 1.0f;
    
    if (![ABUtils notNull:self.loadingIndicator]) {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.loadingIndicator.hidesWhenStopped = YES;
        [self.loadingIndicator stopAnimating];
        
    }
    
    if (![ABUtils notNull:self.videoIndicator]) {
        
        self.videoIndicator = [[UIImageView alloc] initWithImage: [self imageForPlayButton]];
        self.videoIndicator.contentMode = UIViewContentModeScaleAspectFit;
        self.videoIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.videoIndicator.center = self.center;
        [self.videoIndicator sizeToFit];
        
    }
    
    if (![ABUtils notNull:self.closeButton]) {
        
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 50.0f)];
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.closeButton setImage:[self imageForCloseButton] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    self.closeButton.alpha = 0;
    
    if (![self.subviews containsObject:self.closeButton]) {
        [self addSubview:self.closeButton];
        
        [self bringSubviewToFront:self.closeButton];
    }
    
    if (![ABUtils notNull:swipeRecognizer]) {
        swipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRecognizer.delegate = self;
        swipeRecognizer.delaysTouchesBegan = YES;
        swipeRecognizer.cancelsTouchesInView = YES;
        swipeRecognizer.maximumNumberOfTouches = 1;
        swipeRecognizer.enabled = NO;
    }
    
    [self addGestureRecognizer:swipeRecognizer];
    
    if (![ABUtils notNull:self.track]) {
        self.track = [[VideoTrackView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60.0f)];
        self.track.translatesAutoresizingMaskIntoConstraints = NO;
        [self.track.progressView setBackgroundColor: self.themeColor];
        self.track.delegate = self;
        
        [swipeRecognizer requireGestureRecognizerToFail:self.track.scrubRecognizer];
        [swipeRecognizer requireGestureRecognizerToFail:self.track.tapRecognizer];
    }
    
    self.track.hidden = YES;
    
    if (![self.subviews containsObject:self.videoIndicator]) {
        self.videoIndicator.alpha = 0;
        
        [self addSubview:self.videoIndicator];
        
        [self bringSubviewToFront:self.videoIndicator];
        
//        [self addConstraint:
//         [NSLayoutConstraint constraintWithItem:self
//                                      attribute:NSLayoutAttributeCenterX
//                                      relatedBy:0
//                                         toItem:self.videoIndicator
//                                      attribute:NSLayoutAttributeCenterX
//                                     multiplier:1
//                                       constant:0]];
//        
//        [self addConstraint:
//         [NSLayoutConstraint constraintWithItem:self
//                                      attribute:NSLayoutAttributeCenterY
//                                      relatedBy:0
//                                         toItem:self.videoIndicator
//                                      attribute:NSLayoutAttributeCenterY
//                                     multiplier:1
//                                       constant:0]];
        
    }
    
    
    
    if (![self.subviews containsObject:self.track] && [ABUtils notNull:self.track]) {
        
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
                                                               attribute: NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:60.0f]];
        
        [self.track layoutIfNeeded];
    }
    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self selector:@selector(orientationChanged:)
//     name:UIDeviceOrientationDidChangeNotification
//     object:[UIDevice currentDevice]];

    
    
    //    if (![self.subviews containsObject:self.loadingIndicator]) {
    //
    //
    //        [self addSubview:self.loadingIndicator];
    //
    //        [self addConstraint:
    //         [NSLayoutConstraint constraintWithItem:self
    //                                      attribute:NSLayoutAttributeCenterX
    //                                      relatedBy:0
    //                                         toItem:self.loadingIndicator
    //                                      attribute:NSLayoutAttributeCenterX
    //                                     multiplier:1
    //                                       constant:0]];
    //
    //        [self addConstraint:
    //         [NSLayoutConstraint constraintWithItem:self
    //                                      attribute:NSLayoutAttributeCenterY
    //                                      relatedBy:0
    //                                         toItem:self.loadingIndicator
    //                                      attribute:NSLayoutAttributeCenterY
    //                                     multiplier:1
    //                                       constant:0]];
    //
    //    }
    
    self.backgroundColor = [ABUtils colorWithHexString:@"EFEFF4"];
//    self.clipsToBounds = YES;
    
}
- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (void) removeObservers {
    @try{
        [self.player removeObserver:self forKeyPath:@"currentItem.loadedTimeRanges"];
    }@catch(id anException){
        //do nothing, not an observer
    }
    
    @try{
        [self.player removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    }@catch(id anException){
        //do nothing, not an observer
    }
    
    @try{
        [self.player removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }@catch(id anException){
        //do nothing, not an observer
    }
    
    @try{
        [self.player removeObserver:self forKeyPath:@"playbackBufferFull"];
    }@catch(id anException){
        //do nothing, not an observer
    }
}

- (void) resetVariables {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self registerForRotation];
    
    _imageURL = nil;
    _imageCache = nil;
    _videoCache = nil;
    _videoURL = nil;
    
    self.track.hidden = YES;
    
    [self removeObservers];
    
    if ([ABUtils notNull:self.player]) {
        [self.player pause];
    }
    
    self.player = nil;
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    isLoadingVideo = false;
    
    if (!self.imageViewNotReused) {
        self.image = nil;
    }
    
    bufferTime = 0;
    
    self.videoIndicator.alpha = 0;
    self.closeButton.alpha = 0;
    
    [self stopVideoAnimate];
}

- (void) setImageURL:(NSString *)imageURL withCompletion: (ImageCompletionBlock) completion {
    _imageURL = imageURL;
    
    if (!self.imageViewNotReused) {
        self.image = nil;
    }
    
    if ([ABUtils notNull:imageURL]) {
        NSURL *notificationURL = [NSURL URLWithString:imageURL];
        //        if ([ABUtils notNull:notificationURL]) {
        //            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage) name:notificationURL.relativeString object:nil];
        //
        //            NSString *progressString = [NSString stringWithFormat:@"Progress:%@", notificationURL.relativeString];
        //            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:progressString object:nil];
        //        }
        
        if ([ABUtils notNull:self.imageCache]) {
            self.image = self.imageCache;
            
            if ([ABUtils notNull:completion]) {
                completion(self.imageCache, nil);
            }
        }
        else {
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:notificationURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.image = image;
                            self.imageCache = image;
                            
                            //                        [self.loadingIndicator stopLoading];
                            
                            if ([ABUtils notNull:completion]) {
                                completion(image, error);
                            }
                        });
                    }
                }
            }];
            
            [task resume];
        }
        
        
    }
    else {
        //        [self.loadingIndicator stopAnimating];
        
        if ([ABUtils notNull:completion]) {
            completion(nil, nil);
        }
    }
}

- (void) setImage:(UIImage *)image {
    super.image = image;
    
    if ([ABUtils notNull:image]) {
        
        [self registerForRotation];
        
        _imageCache = image;
    }
    
}

- (void) setVideoURL:(NSString *)videoURL {
    _videoURL = videoURL;
    
    self.track.hidden = YES;
    [self.track setProgress: @0 withDuration: 0];
    [self.track setBuffer: @0 withDuration: 0];
    
    self.videoIndicator.alpha = 1;
    
    //initializes gestures
    [self addPlayGesture];
    
    if ([ABUtils notNull:self.track]) {
        if ([ABUtils notNull:self.track.scrubRecognizer]) {
            [self.playRecognizer requireGestureRecognizerToFail:self.track.scrubRecognizer];
        }
        
        if ([ABUtils notNull:self.track.tapRecognizer]) {
            [self.playRecognizer requireGestureRecognizerToFail:self.track.tapRecognizer];
        }
    }
    
    //    if ([self stableWiFiConnection]) {
    //        [self loadVideoWithPlay:NO withCompletion:nil];
    //    }
}

- (void) loadVideoWithPlay: (BOOL)play withCompletion: (VideoDataCompletionBlock) completion {
    
    if ([ABUtils notNull:_videoURL]) {
        
        if (play) {
            [self loadVideoAnimate];
            isLoadingVideo = true;
            
        }
        
        if ([ABUtils notNull:self.videoURL]) {
            [self removeObservers];
            
            AVURLAsset *vidAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.videoURL] options:nil];
            
            if ([ABUtils notNull:self.videoCache]) {
                AVURLAsset *cachedVideo = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.videoCache] options:nil];
                if ([ABUtils notNull:cachedVideo]) {
                    vidAsset = cachedVideo;
                }
            }
            
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:vidAsset];
            
            self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            
            
            if ([ABUtils notNull:self.player]) {
                
                self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(playerItemDidReachEnd:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:[self.player currentItem]];
                
                self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                self.playerLayer.videoGravity = [self getVideoGravity];
                
                self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                
                [(AVPlayerLayer *)self.layer setPlayer:self.player];
                
//                [self.layer insertSublayer:self.playerLayer below:self.videoIndicator.layer];
                
                if (play) {
                    [self.player play];
                    
                    if ([self.delegate respondsToSelector:@selector(mediaViewDidPlayVideo:)]) {
                        [self.delegate mediaViewDidPlayVideo:self];
                    }
                }
                
                
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
                    //                        float pTime = CMTimeGetSeconds(time);
                    
                    if ([ABUtils notNull: weakSelf.player.currentItem]) {
                        if (weakSelf.showTrack) {
                            weakSelf.track.hidden = NO;
                        }
                        else {
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
            
            
            
        }
        
        
    }
    else {
        
        if ([ABUtils notNull:completion]) {
            completion(nil, nil);
        }
    }
}

- (void) playVideoFromRecognizer {
    ////if the cell that is selected already has a video playing then its paused and if not then play that video
    
    if (isMinimized) {
        self.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.25f animations:^{
            self.frame = self.superview.frame;
            
            if (!self.isPlayingVideo || self.isLoadingVideo) {
                self.videoIndicator.alpha = 1.0f;
            }
            
            [self handleCloseButtonDisplay:self];
            
            [self layoutSubviews];
            
            [self updatePlayerFrame];
            [self.track updateBuffer];
            [self.track updateProgress];
            [self.track updateBarBackground];
            
            self.layer.cornerRadius = 0.0f;
            [self setBorderAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            isMinimized = NO;
            self.track.userInteractionEnabled = !isMinimized;
            offset = self.frame.origin.y;
            
            self.userInteractionEnabled = YES;
            
        }];
    }
    else {
        if (self.shouldDisplayFullscreen && !self.isFullScreen) {
            
            
            if ([[[ABMediaView sharedManager] mediaViewQueue] count]) {
                [[ABMediaView sharedManager] queueMediaView:[[ABMediaView alloc] initWithMediaView:self]];
                
                [[ABMediaView sharedManager] showNextMediaView];
            }
            else {
                [[ABMediaView sharedManager] queueMediaView:[[ABMediaView alloc] initWithMediaView:self]];
            }
        }
        else {
            if ([ABUtils notNull:self.player]) {
                if ((self.player.rate != 0) && (self.player.error == nil)) {
                    [self stopVideoAnimate];
                    isLoadingVideo = false;
                    [UIView animateWithDuration:0.15f animations:^{
                        self.videoIndicator.alpha = 1.0f;
                    }];
                    
                    
                    [self.player pause];
                    
                    if ([self.delegate respondsToSelector:@selector(mediaViewDidPauseVideo:)]) {
                        [self.delegate mediaViewDidPauseVideo:self];
                    }
                    
                }
                else if (!self.isLoadingVideo) {
                    [self stopVideoAnimate];
                    [self hideVideoAnimated:NO];
                    
                    [self.player play];
                    
                    if ([self.delegate respondsToSelector:@selector(mediaViewDidPlayVideo:)]) {
                        [self.delegate mediaViewDidPlayVideo:self];
                    }
                    
                }
                else {
                    [self loadVideoAnimate];
                    
                    [self.player play];
                    
                    if ([self.delegate respondsToSelector:@selector(mediaViewDidPlayVideo:)]) {
                        [self.delegate mediaViewDidPlayVideo: self];
                    }
                }
            }
            //if the video hasn't been loaded to disk then load it from backend and save it and then play it
            else if (!self.isLoadingVideo){
                [self loadVideoWithPlay:YES withCompletion:nil];
            }
            else if (self.isLoadingVideo) {
                [self stopVideoAnimate];
            }
        }
        
    }
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    // Loop video when end is reached
    
    if (self.allowLooping) {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
    }
}

- (void)loadVideoAnimate {
    // Set video loader animation timer
    
    [self stopVideoAnimate];
    
    [self animateVideo];
    
    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.751f target:self selector:@selector(animateVideo) userInfo:nil repeats:YES];
}

- (void)stopVideoAnimate {
    // Stop animating video loader
    [self.animateTimer invalidate];
}

- (void) hideVideoAnimated:(BOOL) animated {
    if (animated) {
        [UIView animateWithDuration:0.15f animations:^{
            self.videoIndicator.alpha = 0.0f;
        }];
    }
    else {
        self.videoIndicator.alpha = 0.0f;
    }
    
}

- (void)animateVideo {
    // Animate video loader fade in and out
    BOOL showAnimation = true;
    if ([ABUtils notNull:self.videoURL]) {
        if ([ABUtils notNull:self.videoURL] && !self.isLoadingVideo) {
            showAnimation = false;
            
        }
    }
    
    if (showAnimation) {
        if (self.videoIndicator.alpha == 1.0f) {
            [UIView animateWithDuration:0.75f animations:^{
                self.videoIndicator.alpha = 0.4f;
            }];
        }
        else {
            [UIView animateWithDuration:0.75f animations:^{
                self.videoIndicator.alpha = 1.0f;
            }];
        }
    }
    else {
        self.videoIndicator.alpha = 0.0f;
    }
    
}

- (void) updatePlayerFrame {
    if ([ABUtils notNull:self.playerLayer]) {
        self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

//- (void) updateImage {
//    if ([ABUtils notNull:self.imageURL]) {
//        self.imageView.image = [Defaults cache:self.cache objectForKey:self.imageURL];
//
//        //        [self.loadingIndicator stopAnimating];
//        [self.loader stopLoading];
//
//        if (![ABUtils notNull: self.imageView.image] && self.showProgress) {
//            //            [self.loadingIndicator startAnimating];
//            [self.loader startLoading];
//        }
//
//    }
//}

//- (void) updateProgress: (NSNotification *) notification {
//    if ([ABUtils notNull:notification.object] && [notification.object isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *progressDictionary = notification.object;
//
//        if ([ABUtils notNull:[progressDictionary objectForKey:@"image"]] && [ABUtils notNull:self.imageURL] && [ABUtils notNull:[progressDictionary objectForKey:@"progress"]] && [[progressDictionary objectForKey:@"progress"]isKindOfClass: [NSNumber class]]) {
//            if ([self.imageURL isEqualToString:[progressDictionary objectForKey:@"image"]]) {
//                NSNumber *progress = [progressDictionary objectForKey:@"progress"];
//
//                [self showProgress:progress.floatValue];
//
//            }
//        }
//    }
//}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([ABUtils notNull:keyPath]) {
        //        [self print:object tag:@"Object"];
        //        [self print:change tag:@"Change"];
        //        [self print:keyPath tag:@"Key"];
        if ([keyPath isEqualToString:@"currentItem.loadedTimeRanges"]) {
            
            if ([ABUtils notNull:self.player]) {
                if ([ABUtils notNull:self.player.currentItem]) {
                    //                    NSArray *loadedTimeRanges = self.player.currentItem.loadedTimeRanges;
                    
                    if (isnan(bufferTime)) {
                        bufferTime = 0;
                    }
                    
                    for (NSValue *time in self.player.currentItem.loadedTimeRanges) {
                        CMTimeRange range;
                        [time getValue:&range];
                        
                        if (CMTimeGetSeconds(range.duration) > bufferTime) {
                            bufferTime = CMTimeGetSeconds(range.duration);
                        }
                    }
                    float duration = CMTimeGetSeconds(self.player.currentItem.duration);
                    
                    [self.track setBuffer:[NSNumber numberWithFloat:bufferTime] withDuration:duration];
                    
                    //
                    //                    [self.track setProgress: @0 withDuration: position];
                    if (self.showTrack) {
                        self.track.hidden = NO;
                    }
                    else {
                        self.track.hidden = YES;
                    }
                    
                }
            }
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            if ([ABUtils notNull:self.player]) {
                if ((self.player.rate != 0) && (self.player.error == nil)) {
                    isLoadingVideo = true;
                }
                else {
                    isLoadingVideo = false;
                }
            }
            else {
                isLoadingVideo = false;
            }
        }
        else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            isLoadingVideo = false;
        }
        else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
            isLoadingVideo = false;
        }
    }
}


//- (void) showProgress: (float) progress {
//    if ([ABUtils notNull:self.imageView.image]) {
//        [self.loader stopLoading];
//    }
//    else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            [self.loader setLoaderProgress:progress animate:YES];
//        });
//    }
//
//}

- (void) addPlayGesture {
    //initializes gestures
    if (![ABUtils notNull:self.playRecognizer]) {
        self.playRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideoFromRecognizer)];
        self.playRecognizer.numberOfTapsRequired = 1;
        self.playRecognizer.delegate = self;
    }
    
    self.userInteractionEnabled = YES;
    
    [self removeGestureRecognizer:self.playRecognizer];
    
    if (![self.gestureRecognizers containsObject:self.playRecognizer]) {
        [self addGestureRecognizer:self.playRecognizer];
    }
}

- (BOOL) hasVideo {
    
    if ([ABUtils notNull:self.videoURL]) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isPlayingVideo {
    
    if ([ABUtils notNull:self.player]) {
        if (((self.player.rate != 0) && (self.player.error == nil)) || self.isLoadingVideo) {
            return YES;
        }
    }
    
    return NO;
}

- (UIImage *) imageForPlayButton {
    static UIImage *playCircle = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(60.f, 60.0f), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, 60.0f, 60.0f);
    UIColor *color = self.themeColor;
    
    CGContextSetFillColorWithColor(ctx, [color colorWithAlphaComponent:0.8f].CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
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

- (void) setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    
    self.videoIndicator.image = [self imageForPlayButton];
    [self.track.progressView setBackgroundColor: self.themeColor];
}

- (void) changeVideoToAspectFit:(BOOL)videoAspectFit {
    if (self.videoAspectFit != videoAspectFit) {
        self.videoAspectFit = videoAspectFit;
        
        if ([ABUtils notNull:self.playerLayer]) {
            self.playerLayer.videoGravity = [self getVideoGravity];
        }
    }
    
  
    
}

- (NSString *) getVideoGravity {
    if (self.videoAspectFit) {
        return AVLayerVideoGravityResizeAspect;
    }
    else {
        if (self.contentMode == UIViewContentModeScaleAspectFit) {
            return AVLayerVideoGravityResizeAspect;
        }
        else {
            return AVLayerVideoGravityResizeAspectFill;
        }
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    
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
            
            swipeRecognizer.enabled = self.isMinimizable;
        }
        else {
            
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
        
        if (!self.isPlayingVideo || self.isLoadingVideo) {
            self.videoIndicator.alpha = 1.0f;
        }
        
        [self handleCloseButtonDisplay:self];
        
        if (self.isLoadingVideo) {
            [self stopVideoAnimate];
            [self loadVideoAnimate];
        }
        

    }
    
    [self updatePlayerFrame];
    
    if ([ABUtils notNull:self.videoURL]) {
        [self.track updateBuffer];
        [self.track updateProgress];
        [self.track updateBarBackground];
    }
    
    [self layoutIfNeeded];
    
    
}

- (void) seekToTime:(float)time {
    if ([ABUtils notNull:self.player]) {
        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        CMTime timeCM = CMTimeMakeWithSeconds(time, timeScale);
        [self.player seekToTime:timeCM toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) handleSwipe: (UIPanGestureRecognizer *) gesture {
    if (self.isFullScreen) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self stopVideoAnimate];
            
            self.track.userInteractionEnabled = NO;
            self.playRecognizer.enabled = NO;
            self.closeButton.userInteractionEnabled = NO;
            
            if ([ABUtils notNull:self.track]) {
                if ([ABUtils notNull:self.track.hideTimer]) {
                    [self.track.hideTimer invalidate];
                    [self.track hideTrack];
                }
            }
            
            ySwipePosition = [gesture locationInView:self].y;
            xSwipePosition = [gesture locationInView:self].x;
            offset = self.frame.origin.y;
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            
            if (isMinimized && offset == self.maxViewOffset) {
                CGPoint vel = [gesture velocityInView:self];
                if (self.frame.origin.x > (self.superviewWidth - (self.minViewWidth + 12.0f))) {
                    [self handleDismissingForRecognizer: gesture];
                }
                else {
                    // User dragged towards the right
                    if (vel.x > 0)
                    {
                        float velocityY = vel.y;
                        if (vel.y < 0 && fabsf(velocityY) > vel.x) {
                            // User dragged towards the right, however, he draged upwards more than he dragged right
                            [self handleMinimizingForRecognizer:gesture];
                        }
                        else {
                            [self handleDismissingForRecognizer: gesture];
                        }
                    }
                    else {
                        [self handleMinimizingForRecognizer:gesture];
                    }
                }
                
                
            }
            else {
                // The view is not in fully minimized form, and thus can't be dismissed
                [self handleMinimizingForRecognizer:gesture];
            }
        }
        else if (gesture.state == UIGestureRecognizerStateEnded ||
                 gesture.state == UIGestureRecognizerStateFailed ||
                 gesture.state == UIGestureRecognizerStateCancelled) {
            
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
                [self dismissMediaView];
            }
            else {
                [UIView animateWithDuration:0.25f animations:^{
                    if (minimize) {
                        self.frame = CGRectMake(self.superviewWidth - self.minViewWidth - 12.0f, self.maxViewOffset, self.minViewWidth, self.minViewHeight);
                        self.videoIndicator.alpha = 0;
                        self.closeButton.alpha = 0;
//                        self.layer.cornerRadius = 1.5f;
                        [self setBorderAlpha:1.0f];
                    }
                    else {
                        self.frame = self.superview.frame;
                        
                        if (!self.isPlayingVideo || self.isLoadingVideo) {
                            self.videoIndicator.alpha = 1.0f;
                        }
                        
                        [self handleCloseButtonDisplay:self];
                        
                        self.layer.cornerRadius = 0.0f;
                        [self setBorderAlpha:0.0f];
                    }
                    
                    self.alpha = 1;
                    
                    [self layoutSubviews];
                    
                    [self updatePlayerFrame];
                    [self.track updateBuffer];
                    [self.track updateProgress];
                    [self.track updateBarBackground];
                    
                    
                } completion:^(BOOL finished) {
                    
                    isMinimized = minimize;
                    
                    self.playRecognizer.enabled = YES;
                    self.closeButton.userInteractionEnabled = YES;
                    
                    self.track.userInteractionEnabled = !isMinimized;
                    offset = self.frame.origin.y;
                    
                    self.userInteractionEnabled = YES;
                    
                    if (self.isLoadingVideo) {
                        [self loadVideoAnimate];
                    }
                }];
            }
            
            
        }
    }
    
    
    
    
}

- (void) handleDismissingForRecognizer: (UIPanGestureRecognizer *) gesture {
    if (self.isFullScreen) {
        CGRect frame = self.frame;
        CGPoint origin = self.frame.origin;
        
        //        [self logFrame:self.superview.frame withTag:@"Superview"];
        //        [self logFrame:frame withTag:@"Subview"];
        
        CGFloat difference = [gesture locationInView:self].x - xSwipePosition;
        
        CGFloat tempOffset = self.frame.origin.x + difference;
        
        CGFloat offsetRatio = (tempOffset - (self.superviewWidth - self.minViewWidth - 12.0f)) / (self.minViewWidth - 12.0f);
        
        if (offsetRatio >= 1) {
            origin.y = self.maxViewOffset;
            origin.x = self.superviewWidth;
            offset = self.maxViewOffset;
            self.alpha = 0;
        }
        else if (offsetRatio < 0) {
            origin.y = self.maxViewOffset;
            origin.x = self.superviewWidth - (self.minViewWidth + 12.0f);
            offset = self.maxViewOffset;
            self.alpha = 1;
        }
        else {
            origin.y = self.maxViewOffset;
            origin.x += difference;
            offset = self.maxViewOffset;
            self.alpha = (1 - offsetRatio);
        }
        
        frame.origin = origin;
        
        [UIView animateWithDuration:0.0f animations:^{
            self.frame = frame;
            [self layoutSubviews];
        }];
        
        
        ySwipePosition = [gesture locationInView:self].y;
        xSwipePosition = [gesture locationInView:self].x;
    }
    
}

- (void) handleMinimizingForRecognizer: (UIPanGestureRecognizer *) gesture {
    
    if (self.isFullScreen) {
        CGRect frame = self.frame;
        CGPoint origin = self.frame.origin;
        CGSize size = self.frame.size;
        
//        [self logFrame:self.superview.frame withTag:@"Superview"];
//        [self logFrame:frame withTag:@"Subview"];
        
        CGFloat difference = [gesture locationInView:self].y - ySwipePosition;
        CGFloat tempOffset = offset + difference;
        offsetPercentage = tempOffset / self.maxViewOffset;
        
        if (offsetPercentage > 1) {
            offsetPercentage = 1;
        }
        else if (offsetPercentage < 0) {
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
            offset = self.maxViewOffset;
//            self.layer.cornerRadius = 1.5f;
            [self setBorderAlpha:1.0f];
            
            if (!self.isPlayingVideo || self.isLoadingVideo)  {
                self.videoIndicator.alpha = 0;
            }
            
            self.closeButton.alpha = 0;
        }
        else if (testOrigin <= 0) {
            origin.y = 0;
            size.width = self.superviewWidth;
            size.height = self.superviewHeight;
            origin.x = 0;
            offset = 0.0f;
            self.layer.cornerRadius = 0;
            [self setBorderAlpha:0.0f];
            
            if (!self.isPlayingVideo || self.isLoadingVideo)  {
                self.videoIndicator.alpha = 1;
            }
            
            [self handleCloseButtonDisplay:self];
        }
        else {
            origin.y = testOrigin;
            size.width = self.superviewWidth - (offsetPercentage * (self.superviewWidth - self.minViewWidth));
            size.height = self.superviewHeight - (offsetPercentage * (self.superviewHeight - self.minViewHeight));
            origin.x = self.superviewWidth - size.width - (offsetPercentage * 12.0f);
            offset+= difference;
//            self.layer.cornerRadius = 1.5f * offsetPercentage;
            [self setBorderAlpha:offsetPercentage];
            
            if (!self.isPlayingVideo || self.isLoadingVideo)  {
                self.videoIndicator.alpha = (1-offsetPercentage);
            }
            
            if (self.isFullScreen) {
                
                UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
                
                if (self.hideCloseButton && self.isMinimizable && UIDeviceOrientationIsPortrait(orientation)) {
                    self.closeButton.alpha = 0;
                }
                else {
                    self.closeButton.alpha = (1-offsetPercentage);
                }
            }
            else {
                self.closeButton.alpha = 0;
            }
        }
        
        frame.origin = origin;
        frame.size = size;
        
        [UIView animateWithDuration:0.0f animations:^{
            self.frame = frame;
            [self layoutSubviews];
            
            [self updatePlayerFrame];
            [self.track updateBuffer];
            [self.track updateProgress];
            [self.track updateBarBackground];
        }];
        
        
        ySwipePosition = [gesture locationInView:self].y;
        xSwipePosition = [gesture locationInView:self].x;
    }
    
    
}
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void) willRotate: (NSNotification *) notification {
//    NSLog(@"Rotation began");
    [self orientationChanged:nil];
    
}

- (void) didRotate: (NSNotification *) notification {
//    NSLog(@"Rotation complete");
    [self orientationChanged:nil];
    
}

- (void) registerForRotation {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ABMediaViewWillRotateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ABMediaViewDidRotateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:ABMediaViewWillRotateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:ABMediaViewDidRotateNotification object:nil];
}

- (void) setShowRemainingTime: (BOOL) showRemainingTime {
    _displayRemainingTime = showRemainingTime;
    
    if ([ABUtils notNull:self.track]) {
        self.track.showRemainingTime = showRemainingTime;
    }
}

- (void) setCanMinimize:(BOOL)canMinimize {
    self.isMinimizable = canMinimize;
    
    if ([ABUtils notNull:swipeRecognizer]) {
        swipeRecognizer.enabled = self.isMinimizable;
    }
}

- (void) queueMediaView: (ABMediaView *) mediaView {
    if ([ABUtils notNull:mediaView]) {
        [self.mediaViewQueue addObject:mediaView];
        
        if (self.mediaViewQueue.count == 1) {
            [[ABMediaView sharedManager] presentMediaView:mediaView];
        }
    }
}

- (void) showNextMediaView {
    if (self.mediaViewQueue.count) {
        self.userInteractionEnabled = NO;
        
        ABMediaView *mediaView = self.mediaViewQueue.firstObject;
        
        [mediaView dismissMediaView];
        
        self.userInteractionEnabled = YES;
        if (self.mediaViewQueue.count) {
            [[ABMediaView sharedManager] presentMediaView:[self.mediaViewQueue firstObject]];
        }
        else {
            NSLog(@"No mediaView in queue");
        }
        
        
        
    }
    else {
        NSLog(@"No mediaView in queue");
    }
}

- (void) presentMediaView:(ABMediaView *) mediaView {
    self.mainWindow = [[UIApplication sharedApplication] keyWindow];
    [self.mainWindow makeKeyAndVisible];
    
    [mediaView setFullscreen:YES];
    [mediaView handleCloseButtonDisplay:mediaView];
    
    mediaView.backgroundColor = [UIColor blackColor];
    
    if (!CGRectIsEmpty(mediaView.originRect)) {
        if (CGRectIsEmpty(mediaView.originRectConverted)) {
            mediaView.originRectConverted = [self convertRect:mediaView.originRect toView:self.mainWindow];
        }
    }
    
    if (!CGRectIsEmpty(mediaView.originRectConverted)) {
        mediaView.alpha = 1;
        mediaView.frame = mediaView.originRectConverted;
        mediaView.closeButton.alpha = 0;
        [mediaView layoutSubviews];
        [self.mainWindow addSubview:mediaView];
        [self.mainWindow bringSubviewToFront:mediaView];
        
        [UIView animateWithDuration:0.5f animations:^{
//            mediaView.videoIndicator.center = mediaView.center;
            mediaView.frame = mediaView.superview.frame;
            [mediaView handleCloseButtonDisplay:mediaView];
            [mediaView layoutSubviews];
        } completion:^(BOOL finished) {
            
            if ([ABUtils notNull:mediaView.videoURL]) {
                [mediaView playVideoFromRecognizer];
            }
            //        if ([mediaView.delegate respondsToSelector:@selector(mediaViewDidShow:)]) {
            //            [mediaView.delegate mediaViewDidShow:self];
            //        }
        }];
    }
    else {
        mediaView.alpha = 0;
        mediaView.closeButton.alpha = 0;
        mediaView.frame = self.mainWindow.frame;
        [self.mainWindow addSubview:mediaView];
        [self.mainWindow bringSubviewToFront:mediaView];
        
        [UIView animateWithDuration:0.25f animations:^{
            mediaView.alpha = 1;
            [mediaView handleCloseButtonDisplay:mediaView];
        } completion:^(BOOL finished) {
            if ([ABUtils notNull:mediaView.videoURL]) {
                [mediaView playVideoFromRecognizer];
            }
            //        if ([mediaView.delegate respondsToSelector:@selector(mediaViewDidShow:)]) {
            //            [mediaView.delegate mediaViewDidShow:self];
            //        }
        }];
    }
    
    
}

- (void) removeFromQueue:(ABMediaView *) mediaView {
    if ([ABUtils notNull:mediaView] && self.mediaViewQueue.count) {
        [self.mediaViewQueue removeObject:mediaView];
    }
}

- (void) dismissMediaView {
    if (self.isFullScreen) {
        self.userInteractionEnabled = NO;

        
        [UIView animateWithDuration:0.25f animations:^{
            self.frame = CGRectMake(self.superviewWidth, self.maxViewOffset, self.minViewWidth, self.minViewHeight);
            self.alpha = 0;
//            self.layer.cornerRadius = 1.5f;
            [self setBorderAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            [[ABMediaView sharedManager] removeFromQueue:self];
            [self.player pause];
            [self.playerLayer removeFromSuperlayer];
            self.playerLayer = nil;
            self.player = nil;
            [self removeFromSuperview];
            
            self.userInteractionEnabled = YES;
        }];
    }
    
    
}

- (void) setBorderAlpha: (CGFloat) alpha {
    self.layer.borderColor = [[ABUtils colorWithHexString:@"95a5a6"] colorWithAlphaComponent:alpha].CGColor;
    self.layer.shadowOpacity = alpha;
}

- (void) setTrackFont:(UIFont *)font {
    _trackFont = font;
    
    if ([ABUtils notNull:font]) {
        [self.track setTrackFont:font];
    }
}

- (void) setBottomBuffer:(CGFloat)bottomBuffer {
    _bottomBuffer = bottomBuffer;
    
    if (_bottomBuffer < 0) {
        self.bottomBuffer = 0;
    }
    else if (_bottomBuffer > 120) {
        self.bottomBuffer = 120;
    }
    
}
- (void) logFrame: (CGRect) frame withTag: (NSString *) tag {
    NSLog(@"%@ - x: %f  y: %f  width: %f  height: %f", tag, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (void) setMinimizedAspectRatio:(CGFloat)minimizedAspectRatio {
    if (minimizedAspectRatio <= 0) {
        _minimizedAspectRatio = ABMediaViewRatioPresetLandscape;
    }
    else {
        _minimizedAspectRatio = minimizedAspectRatio;
    }
}

- (void) setMinimizedWidthRatio:(CGFloat)minimizedWidthRatio {
    _minimizedWidthRatio = minimizedWidthRatio;
    
    CGFloat maxWidthRatio = (self.superviewWidth - 24.0f) / self.superviewWidth;
    
    if (_minimizedWidthRatio < 0.25f) {
        _minimizedWidthRatio = 0.25f;
    }
    else if (_minimizedWidthRatio > maxWidthRatio) {
        _minimizedWidthRatio = maxWidthRatio;
    }
}

- (UIImage *) imageForCloseButton {
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

- (void) closeAction {
    if (self.isFullScreen) {
        [UIView animateWithDuration:0.20f animations:^{
            self.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [[ABMediaView sharedManager] removeFromQueue:self];
            [self.player pause];
            [self.playerLayer removeFromSuperlayer];
            self.playerLayer = nil;
            self.player = nil;
            [self removeFromSuperview];
            
            self.userInteractionEnabled = YES;
            if (self.mediaViewQueue.count) {
                [[ABMediaView sharedManager] presentMediaView:[self.mediaViewQueue firstObject]];
            }
            else {
                NSLog(@"No mediaView in queue");
            }
        }];
    }
    else {
        self.closeButton.alpha = 0;
    }
}

- (void) hideCloseButton:(BOOL)hideButton {
    _hideCloseButton = hideButton;
    
    [self handleCloseButtonDisplay:self];
}

- (void) handleCloseButtonDisplay: (ABMediaView *) mediaView {
    if (mediaView.isFullScreen) {
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        
        if (mediaView.hideCloseButton && mediaView.isMinimizable && UIDeviceOrientationIsPortrait(orientation)) {
            mediaView.closeButton.alpha = 0;
        }
        else {
            mediaView.closeButton.alpha = 1;
        }
    }
    else {
        mediaView.closeButton.alpha = 0;
    }
}

- (void) setFullscreen: (BOOL) fullscreen {
    isFullscreen = fullscreen;
}

- (CGFloat) superviewWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    CGFloat height = screenRect.size.height;
    
    if (width > height) {
        return height;
    }
    
    return width;
}

- (CGFloat) superviewHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    CGFloat height = screenRect.size.height;
    
    if (width > height) {
        return width;
    }
    
    return height;
}

- (CGFloat) minViewWidth {
    return self.superviewWidth * self.minimizedWidthRatio;
}

- (CGFloat) minViewHeight {
    return self.minViewWidth * self.minimizedAspectRatio;
}

- (CGFloat) maxViewOffset {
    return (self.superviewHeight - (self.minViewHeight + 12.0f + self.bottomBuffer));
}

@end
