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

@synthesize mpVolumeView;
@synthesize volumeSlider;

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
        
        mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-50, -50, 0, 0)];
        
        [[mpVolumeView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UISlider class]]) {
                volumeSlider = obj;
                *stop = YES;
            }
        }];
        
        UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
        
        if (mpVolumeView) [currentWindow addSubview:mpVolumeView];
        
        
        
    }
    return self;
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
@end

