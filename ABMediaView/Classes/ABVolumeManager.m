//
//  ABVolumeManager.m
//  Pods
//
//  Created by Andrew Boryk on 1/29/17.
//
//

#import "ABVolumeManager.h"
#import "ABCommons.h"
#import <AVFoundation/AVFoundation.h>

@implementation ABVolumeManager

@synthesize volumeBar;
@synthesize mpVolumeView;
@synthesize volumeSlider;
@synthesize volumeTimer;
@synthesize dontShowVolumeBar;
@synthesize volumeBackground;

+ (id)sharedManager {
    static ABVolumeManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        // Initialize caches
        
        self.defaultAudioPlayingType = DefaultAudio;
        self.defaultAudioStoppingType = DefaultAudio;
        
        volumeBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [ABCommons viewWidth], 2)];
        
        volumeBackground.backgroundColor = [UIColor darkGrayColor];
        volumeBackground.alpha = 0;
        
        volumeBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        
        [self updateVolumeBarColor: [ABVolumeManager darkVolumeBar]];
        
        volumeBar.clipsToBounds = NO;
        volumeBar.layer.masksToBounds = NO;
        
        volumeBar.layer.shadowColor = [UIColor blackColor].CGColor;
        volumeBar.layer.shadowOffset = CGSizeMake(0, 0);
        volumeBar.layer.shadowOpacity = 0.5f;
        volumeBar.layer.shadowRadius = 1.0f;
        volumeBar.alpha = 0;
        
        mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-50, -50, 0, 0)];
        
        [[mpVolumeView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UISlider class]]) {
                volumeSlider = obj;
                *stop = YES;
            }
        }];
        
        // Notification when volume is changed
        [volumeSlider addTarget:self action:@selector(handleVolumeChanged:) forControlEvents:UIControlEventValueChanged];
        
        UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
        
        [currentWindow addSubview:volumeBackground];
        [currentWindow addSubview:volumeBar];
        
        if (mpVolumeView) [currentWindow addSubview:mpVolumeView];
        
        
        
    }
    return self;
}

- (void)handleVolumeChanged:(id)sender
{
    
    // Handles a change in volume, and adjusts the width of the volumeBar accordingly
    
    //    [Utils printString:[NSString stringWithFormat:@"%s - %f", __PRETTY_FUNCTION__, volumeSlider.value]];
    
    // Volume changed, show volumeBar
    
    volumeBackground.frame = CGRectMake(0, 0, [ABCommons viewWidth], 2);
    
    CGRect volumeBarFrame = volumeBar.frame;
    
    CGFloat previousWidth = volumeBarFrame.size.width;
    
    CGFloat viewWidth = [ABCommons viewWidth];
    
    CGFloat newWidth = (volumeSlider.value/1.0f) * viewWidth;
    
    newWidth = (volumeSlider.value/1.0f) * viewWidth;
    volumeBarFrame.size = CGSizeMake(newWidth, 2);
    
    [self updateVolumeBarColor:[ABVolumeManager darkVolumeBar]];
    
    volumeBackground.backgroundColor = [UIColor darkGrayColor];
    //
    //    if ([[Defaults viewVisible] isEqualToString:@"Create"])
    //        volumeBar.backgroundColor = [UIColor whiteColor];
    //        volumeBarFrame.size = CGSizeMake(newWidth, 6);
    //        volumeBackground.backgroundColor = [UIColor clearColor];
    //    }
    //
    
    
    if ((newWidth != previousWidth || newWidth >= viewWidth || newWidth <= 0) && !self.dontShowVolumeBar) {
        
        [UIView animateWithDuration:0.35f animations:^{
            volumeBar.frame = volumeBarFrame;
            volumeBar.alpha = 0.75f;
            volumeBackground.alpha = 1.0f;
            
        }];
        
        [volumeTimer invalidate];
        volumeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(volumeDone) userInfo:nil repeats:NO];
    }
    else {
        
        volumeBar.alpha = 0;
        volumeBackground.alpha = 0;
        volumeBar.frame = volumeBarFrame;
    }
    
}

- (void) dontShowVolumebar {
    self.volumeBar.alpha = 0;
    volumeBackground.alpha = 0;
    self.dontShowVolumeBar = true;
    
    [self performSelector:@selector(showVolumeBar) withObject:nil afterDelay:1.0f];
}

- (void) showVolumeBar {
    self.dontShowVolumeBar = false;
}

- (void) volumeDone {
    // Hide volumeBar after animation
    [UIView animateWithDuration:0.35f animations:^{
        volumeBar.alpha = 0;
        volumeBackground.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void) updateVolumeBarColor:(UIColor *)color {
    volumeBar.backgroundColor = color;
}

- (void) setAudioWhenPlaying {
    [[ABVolumeManager sharedManager] setAudioSession:self.defaultAudioPlayingType];
}

- (void) setAudioWhenStopping {
    [[ABVolumeManager sharedManager] setAudioSession:self.defaultAudioStoppingType];
}

- (void) setAudioSession: (AudioType) type {
    
    if (type == PlayAudioWhenSilent) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    }
    else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient
                                         withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                               error:nil];
    }
    
}

+ (UIColor *) lightVolumeBar {
    return [ABCommons colorWithHexString:@"FFFFFF"];
}

+ (UIColor *) darkVolumeBar {
    return [ABCommons colorWithHexString:@"1DCBD0"];
}
@end

