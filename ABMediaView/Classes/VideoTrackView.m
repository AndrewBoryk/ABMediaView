//
//  VideoTrackView.m
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import "VideoTrackView.h"

@implementation VideoTrackView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = frame;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
        
        self.bufferView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        self.bufferView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25f];
        
        [self addSubview:self.bufferView];
        
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        self.progressView.backgroundColor = [UIColor colorWithRed:48.0f/255.0f green:207.0f/255.0f blue:210.0f/255.0f alpha:1];
        
        [self addSubview:self.progressView];
    }
    
    return self;
}

- (void) setProgress:(NSNumber *)progress withDuration: (CGFloat) duration {
    _progress = progress;
    
    if ([ABUtils notNull:self.progress]) {
        CGFloat prog = self.progress.floatValue;
        
        if (prog == 0) {
            self.progressView.frame = CGRectMake(0, 0, 0, self.frame.size.height);
        }
        else {
            if (isnan(duration)) {
                duration = 15.0f;
            }
            
            CGFloat timeElapsedRatio = prog/ (duration - 0.5f);
            CGFloat width = timeElapsedRatio * self.frame.size.width;
            
            [UIView animateWithDuration:0.01f animations:^{
                self.progressView.frame = CGRectMake(0, 0, width, self.frame.size.height);
            }];
        }
    }
}

- (void) setBuffer:(NSNumber *)buffer withDuration: (CGFloat) duration {
    _buffer = buffer;
    
    if ([ABUtils notNull:self.buffer]) {
        CGFloat buff = self.buffer.floatValue;
        
        if (buff == 0) {
            self.bufferView.frame = CGRectMake(0, 0, 0, self.frame.size.height);
        }
        else {
            if (isnan(duration)) {
                duration = 15.0f;
            }
            
            CGFloat timeElapsedRatio = buff/duration;
            CGFloat width = timeElapsedRatio * self.frame.size.width;
            
            [UIView animateWithDuration:0.1f animations:^{
                self.bufferView.frame = CGRectMake(0, 0, width, self.frame.size.height);
            }];
        }
    }
    else {
        self.bufferView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

@end
