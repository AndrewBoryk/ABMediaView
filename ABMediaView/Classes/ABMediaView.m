//
//  ABMediaView.m
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import "ABMediaView.h"

@implementation ABMediaView {
    float bufferTime;
    
    /// Recognizer to record user swiping
    UIPanGestureRecognizer *swipeRecognizer;
    
    /// Position of the swipe
    CGFloat ySwipePosition;
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
}

- (void) commonInit {
    self.themeColor = [UIColor cyanColor];
    
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
        [self.videoIndicator sizeToFit];
        
    }
    
    if (![ABUtils notNull:self.track]) {
        self.track = [[VideoTrackView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60.0f)];
        self.track.translatesAutoresizingMaskIntoConstraints = NO;
        [self.track.progressView setBackgroundColor: self.themeColor];
        self.track.delegate = self;
    }
    
    if (![ABUtils notNull:swipeRecognizer]) {
        swipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRecognizer.delegate = self;
        swipeRecognizer.delaysTouchesBegan = YES;
        swipeRecognizer.cancelsTouchesInView = YES;
    }
    
    [self addGestureRecognizer:swipeRecognizer];
    
    self.track.hidden = YES;
    
    if (![self.subviews containsObject:self.videoIndicator]) {
        self.videoIndicator.alpha = 0;
        
        [self addSubview:self.videoIndicator];
        
        [self bringSubviewToFront:self.videoIndicator];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:0
                                         toItem:self.videoIndicator
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1
                                       constant:0]];
        
        [self addConstraint:
         [NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:0
                                         toItem:self.videoIndicator
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1
                                       constant:0]];
        
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
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

    
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
    self.clipsToBounds = YES;
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

- (void) setImageURL:(NSString *)imageURL withCompletion: (ImageCompletionBlock) completion {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _videoURL = nil;
    _imageURL = imageURL;
    
    self.track.hidden = YES;
    
    [self removeObservers];
    
    self.player = nil;
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.isLoadingVideo = false;
    
    if (!self.imageViewNotReused) {
        self.image = nil;
    }
    
    
    bufferTime = 0;
    
    self.videoIndicator.alpha = 0;
    
    [self stopVideoAnimate];
    
    if ([ABUtils notNull:imageURL]) {
        NSURL *notificationURL = [NSURL URLWithString:imageURL];
        //        if ([ABUtils notNull:notificationURL]) {
        //            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage) name:notificationURL.relativeString object:nil];
        //
        //            NSString *progressString = [NSString stringWithFormat:@"Progress:%@", notificationURL.relativeString];
        //            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:progressString object:nil];
        //        }
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:notificationURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = image;
                        
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
    else {
        //        [self.loadingIndicator stopAnimating];
        
        if ([ABUtils notNull:completion]) {
            completion(nil, nil);
        }
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
    
    //    if ([self stableWiFiConnection]) {
    //        [self loadVideoWithPlay:NO andScroll:NO withCompletion:nil];
    //    }
}

- (void) loadVideoWithPlay: (BOOL)play andScroll: (BOOL) scroll withCompletion: (VideoDataCompletionBlock) completion {
    
    if ([ABUtils notNull:_videoURL]) {
        
        if (play) {
            [self loadVideoAnimate];
            self.isLoadingVideo = true;
            
            if (scroll) {
                if ([self.delegate respondsToSelector:@selector(playVideo)]) {
                    [self.delegate playVideo];
                }
            }
            
        }
        
        if ([ABUtils notNull:self.videoURL]) {
            [self removeObservers];
            
            AVURLAsset *vidAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.videoURL] options:nil];
            
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
                
                [self.layer insertSublayer:self.playerLayer below:self.videoIndicator.layer];
                
                if (play) {
                    [self.player play];
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
                            weakSelf.isLoadingVideo = false;
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

- (void) playVideoWithoutScroll:(BOOL)scroll {
    ////if the cell that is selected already has a video playing then its paused and if not then play that video
    
    if ([ABUtils notNull:self.player]) {
        if ((self.player.rate != 0) && (self.player.error == nil)) {
            [self stopVideoAnimate];
            self.isLoadingVideo = false;
            [UIView animateWithDuration:0.15f animations:^{
                self.videoIndicator.alpha = 1.0f;
            }];
            
            
            [self.player pause];
            
            if ([self.delegate respondsToSelector:@selector(pauseVideo)]) {
                [self.delegate pauseVideo];
            }
            
        }
        else if (!self.isLoadingVideo) {
            [self stopVideoAnimate];
            [self hideVideoAnimated:NO];
            
            [self.player play];
            
            if (!scroll) {
                if ([self.delegate respondsToSelector:@selector(playVideo)]) {
                    [self.delegate playVideo];
                }
            }
            
        }
        else {
            [self loadVideoAnimate];
            
            [self.player play];
            
            if (!scroll) {
                if ([self.delegate respondsToSelector:@selector(playVideo)]) {
                    [self.delegate playVideo];
                }
            }
        }
    }
    //if the video hasn't been loaded to disk then load it from backend and save it and then play it
    else if (!self.isLoadingVideo){
        [self loadVideoWithPlay:YES andScroll:!scroll withCompletion:nil];
        
    }
    else if (self.isLoadingVideo) {
        [self stopVideoAnimate];
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
                    self.isLoadingVideo = true;
                }
                else {
                    self.isLoadingVideo = false;
                }
            }
            else {
                self.isLoadingVideo = false;
            }
        }
        else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            self.isLoadingVideo = false;
        }
        else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
            self.isLoadingVideo = false;
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
        self.playRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideoWithoutScroll:)];
        self.playRecognizer.numberOfTapsRequired = 1;
        
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
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(80.f, 80.0f), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, 80.0f, 80.0f);
    UIColor *color = self.themeColor;
    
    CGContextSetFillColorWithColor(ctx, [color colorWithAlphaComponent:0.8f].CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    CGFloat inset = 20.0f;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:(CGPoint){27.5f, inset}];
    [bezierPath addLineToPoint:(CGPoint){ 80.0f - inset, 80.0f/2.f}];
    [bezierPath addLineToPoint:(CGPoint){27.5f, 80.0f - inset}];
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

- (void) handleSwipe: (UIGestureRecognizer *) gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Touches Began");
        ySwipePosition = [gesture locationInView:self].y;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"Touches Moved");
        
        CGRect frame = [self convertRect:self.frame toView:self.superview];
        
        NSLog(@"x: %f  y: %f  width: %f  height: %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        
        CGFloat difference = [gesture locationInView:self].y - ySwipePosition;
        
        frame.origin = CGPointMake(frame.origin.x, frame.origin.y + difference);
        
        if ([gesture locationInView:self].y > ySwipePosition) {
            if (frame.origin.y > self.superview.frame.size.height - 100) {
                frame.origin = CGPointMake(frame.origin.x, self.superview.frame.size.height - 100);
            }
        }
        else if ([gesture locationInView:self].y < ySwipePosition) {
            if (frame.origin.y < 0) {
                frame.origin = CGPointMake(frame.origin.x, 0);
            }
        }
        
        self.frame = frame;
        
        ySwipePosition = [gesture locationInView:self].y;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateFailed ||
             gesture.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"Touches Ended");
        
        ySwipePosition = 0.0f;
    }
}



@end
