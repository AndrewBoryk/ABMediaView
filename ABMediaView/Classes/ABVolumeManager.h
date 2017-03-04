//
//  ABVolumeManager.h
//  Pods
//
//  Created by Andrew Boryk on 1/29/17.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, AudioType) {
    PlayAudioWhenSilent,
    DefaultAudio,
};

@interface ABVolumeManager : NSObject

/// View which handles volume change
@property (strong, nonatomic) MPVolumeView *mpVolumeView;

/// Slider which records the user's volume level
@property (strong, nonatomic) UISlider *volumeSlider;

/// Default value for how audio should be handled when playing media
@property (nonatomic) AudioType defaultAudioPlayingType;

/// Default value for how audio should be handled when pausing media
@property (nonatomic) AudioType defaultAudioStoppingType;

/// Shared Manager for Volume Manager
+ (id)sharedManager;

/// Sets the audio when the ABPlayer is supposed to play
- (void)setAudioWhenPlaying;

/// Sets the audio when the ABPlayer is supposed to pause
- (void)setAudioWhenStopping;

/// Set the audio session type to play audio when video is playing, and mute it when not
- (void)setAudioSession:(AudioType)type;

@end
