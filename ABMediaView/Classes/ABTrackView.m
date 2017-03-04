//
//  ABTrackView.m
//  Pods
//
//  Created by Andrew Boryk on 2/22/17.
//
//

#import "ABTrackView.h"
#import "ABCommons.h"
#import "ABLabel.h"

@implementation ABTrackView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = frame;
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    _barHeight = 2.0f;
    self.buffer = @0;
    
    self.barBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - _barHeight, self.frame.size.width, _barHeight)];
    self.barBackgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
    self.barBackgroundView.layer.masksToBounds = NO;
    self.barBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.barBackgroundView.layer.shadowOffset = CGSizeMake(0, 2);
    self.barBackgroundView.layer.shadowOpacity = 0.8f;
    self.barBackgroundView.layer.shadowRadius = 4.0f;
    
    [self addSubview:self.barBackgroundView];
    
    self.bufferView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - _barHeight, 0, _barHeight)];
    self.bufferView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25f];
    
    [self addSubview:self.bufferView];
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - _barHeight, 0, _barHeight)];
    self.progressView.backgroundColor = [UIColor cyanColor];
    
    [self addSubview:self.progressView];
    
    self.currentTimeLabel = [[ABLabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height - _barHeight - 14.0f, 120.0f, 14)];
    self.currentTimeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    self.currentTimeLabel.text = @"0:00";
    self.currentTimeLabel.alpha = 0;
    self.currentTimeLabel.userInteractionEnabled = NO;
    [self addShadow:self.currentTimeLabel];
    
    [self addSubview:self.currentTimeLabel];
    
    self.totalTimeLabel = [[ABLabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 128, self.frame.size.height - _barHeight - 14.0f, 120.0f, 14)];
    self.totalTimeLabel.textAlignment = NSTextAlignmentRight;
    self.totalTimeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    self.totalTimeLabel.text = @"0:00";
    self.totalTimeLabel.alpha = 0;
    self.totalTimeLabel.userInteractionEnabled = NO;
    [self addShadow:self.totalTimeLabel];
    
    [self addSubview:self.totalTimeLabel];
    
    self.scrubRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrub:)];
    self.scrubRecognizer.delegate = self;
    self.scrubRecognizer.delaysTouchesBegan = YES;
    self.scrubRecognizer.cancelsTouchesInView = YES;
    self.scrubRecognizer.maximumNumberOfTouches = 1;
    
    [self addGestureRecognizer:self.scrubRecognizer];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trackTap:)];
    self.tapRecognizer.cancelsTouchesInView = YES;
    self.tapRecognizer.delaysTouchesBegan = YES;
    self.tapRecognizer.delegate = self;
    self.tapRecognizer.numberOfTapsRequired = 1;
    self.tapRecognizer.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:self.tapRecognizer];
}

- (void)setProgress:(NSNumber *)progress withDuration:(CGFloat)duration {
    _progress = progress;
    _duration = duration;
    
    [self updateProgress];
    
    int trackInt = 0;
    
    if ([ABCommons notNull:progress]) {
        trackInt = progress.intValue;
    }
    
    int minutes = trackInt/60;
    int seconds = trackInt%60;
    
    int doneMinutes = (int)duration/60;
    int doneSeconds = (int)duration%60;
    
    if (self.showRemainingTime) {
        doneMinutes = (int)(duration - trackInt)/60;
        doneSeconds = (int)(duration - trackInt)%60;
    }
    
    if (seconds < 10) {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%i:0%i", minutes, seconds];
    } else {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
    }
    
    if (doneSeconds < 10) {
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%i:0%i", doneMinutes, doneSeconds];
    } else {
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%i:%i", doneMinutes, doneSeconds];
    }
    
}

- (void)updateProgress {
    
    if ([ABCommons notNull:self.progress]) {
        CGFloat prog = self.progress.floatValue;
        
        if (prog == 0) {
            self.progressView.frame = CGRectMake(0, self.frame.size.height - _barHeight, 0, _barHeight);
        } else {
            
            if (isnan(self.duration)) {
                self.duration = 15.0f;
            }
            
            CGFloat timeElapsedRatio = prog/ (self.duration - 0.5f);
            CGFloat width = timeElapsedRatio * self.frame.size.width;
            
            [UIView animateWithDuration:0.01f animations:^{
                self.progressView.frame = CGRectMake(0, self.frame.size.height - _barHeight, width, _barHeight);
            }];
        }
    }
    
}

- (void)setBuffer:(NSNumber *)buffer withDuration:(CGFloat)duration {
    _buffer = buffer;
    _duration = duration;
    
    [self updateBuffer];
}

- (void) updateBuffer {
    
    if ([ABCommons notNull:self.buffer]) {
        CGFloat buff = self.buffer.floatValue;
        
        if (buff == 0) {
            self.bufferView.frame = CGRectMake(0, self.frame.size.height - _barHeight, 0, _barHeight);
        } else {
            
            if (isnan(self.duration)) {
                self.duration = 15.0f;
            }
            
            CGFloat timeElapsedRatio = buff/self.duration;
            CGFloat width = timeElapsedRatio * self.frame.size.width;
            
            [UIView animateWithDuration:0.1f animations:^{
                self.bufferView.frame = CGRectMake(0, self.frame.size.height - _barHeight, width, _barHeight);
            }];
        }
        
    } else {
        self.bufferView.frame = CGRectMake(0, self.frame.size.height - _barHeight, self.frame.size.width, _barHeight);
    }
    
}

- (void)updateBarBackground {
    [UIView animateWithDuration:0.1f animations:^{
        self.barBackgroundView.frame = CGRectMake(0, self.frame.size.height - _barHeight, self.frame.size.width, _barHeight);
        self.currentTimeLabel.frame = CGRectMake(8, self.frame.size.height - _barHeight - 20.0f, 120.0f, 20.0f);
        self.totalTimeLabel.frame = CGRectMake(self.frame.size.width - 128, self.frame.size.height - _barHeight - 20.0f, 120.0f, 20.0f);
    }];
}

- (void)seekToPoint:(float)point {
    
    if (point <= self.bufferView.frame.size.width && self.canSeek) {
        float ratio = point/self.frame.size.width;
        
        if (!isnan(_duration)) {
            float seekTime = ratio * _duration;
            
            if ([self.delegate respondsToSelector:@selector(trackView:seekToTime:)]) {
                [self.delegate trackView:self seekToTime:seekTime];
            }
            
        }
        
    }
    
}

- (void)turnOnSeek {
    self.canSeek = YES;
}

- (void)addShadow:(UIView *)view {
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowOpacity = 0.8f;
    view.layer.shadowRadius = 1.0f;
}

- (void)handleScrub:(UIGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.barHeight = 6.0f;
        
        if (self.progressView.frame.size.height == 6.0f) {
            [self seekToPoint:[gesture locationInView:self].x];
        } else {
            [UIView animateWithDuration:0.2f animations:^{
                self.currentTimeLabel.alpha = 1;
                self.totalTimeLabel.alpha = 1;
                [self updateProgress];
                [self updateBuffer];
                [self updateBarBackground];
            } completion:^(BOOL finished) {
                [self performSelector:@selector(turnOnSeek) withObject:nil afterDelay:0.3f];
            }];
        }
        
        [self.hideTimer invalidate];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.progressView.frame.size.height == 6.0f) {
            
            [self seekToPoint:[gesture locationInView:self].x];
        }
        
        [self.hideTimer invalidate];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateFailed ||
             gesture.state == UIGestureRecognizerStateCancelled) {
        [self.hideTimer invalidate];
        
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(hideTrack) userInfo:nil repeats:NO];
    }
    
}

- (void)trackTap:(UIGestureRecognizer *)gesture {
    self.barHeight = 6.0f;
    
    if (self.progressView.frame.size.height == 6.0f) {
        [self seekToPoint:[gesture locationInView:self].x];
    } else {
        [UIView animateWithDuration:0.2f animations:^{
            self.currentTimeLabel.alpha = 1;
            self.totalTimeLabel.alpha = 1;
            [self updateProgress];
            [self updateBuffer];
            [self updateBarBackground];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(turnOnSeek) withObject:nil afterDelay:0.3f];
        }];
    }
    
    [self.hideTimer invalidate];
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(hideTrack) userInfo:nil repeats:NO];
}

- (void)setTrackFont:(UIFont *)font {
    
    if ([ABCommons notNull:font]) {
        self.totalTimeLabel.font = font;
        self.currentTimeLabel.font = font;
    }
    
}

- (void)hideTrack {
    self.barHeight = 2.0f;
    self.canSeek = NO;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.currentTimeLabel.alpha = 0;
        self.totalTimeLabel.alpha = 0;
        [self updateProgress];
        [self updateBuffer];
        [self updateBarBackground];
    }];
}
@end
