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

#define ABVolumeBarColorLight [ABUtils colorWithHexString:@"FFFFFF"];
#define ABVolumeBarColorDark = 

@interface ABVolumeManager : NSObject {
    
    /// Bar which shows volume level
    UIView *volumeBar;
    
    /// View which handles volume change
    MPVolumeView *mpVolumeView;
    
    /// Slider which records the user's volume level
    UISlider *volumeSlider;
    
    // Timer that when selector is performed, hides volumeBar
    NSTimer *volumeTimer;
    
    /// Determines whether volume bar should be shown
    BOOL dontShowVolumeBar;
    
    /// Background for volume bar
    UIView *volumeBackground;
}

extern UIColor *  const COLOR_LIGHT_BLUE;

/// Determines whether volume bar should be shown
@property BOOL dontShowVolumeBar;

/// Background for volume bar
@property (retain, nonatomic) UIView *volumeBackground;

/// Bar which shows volume level
@property (retain, nonatomic) UIView *volumeBar;

/// View which handles volume change
@property (retain, nonatomic) MPVolumeView *mpVolumeView;

/// Slider which records the user's volume level
@property (retain, nonatomic) UISlider *volumeSlider;

// Timer that when selector is performed, hides volumeBar
@property (retain, nonatomic) NSTimer *volumeTimer;

/// Shared Manager for Volume Manager
+ (id)sharedManager;

/// Hides volume bar for 2.5 seconds
- (void) dontShowVolumebar;

/// Shows volume bar
- (void) showVolumeBar;

/// Updates color for volumebar
- (void) updateVolumeBarColor:(UIColor *)color;

/// Light color for the bar
+ (UIColor *) lightVolumeBar;

/// Dark color for the bar
+ (UIColor *) darkVolumeBar;

/// Set the audio session type to play audio when video is playing, and mute it when not
- (void) setAudioSession: (AudioType) type;
@end
