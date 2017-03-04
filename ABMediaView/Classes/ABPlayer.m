//
//  ABPlayer.m
//  Pods
//
//  Created by Andrew Boryk on 1/29/17.
//
//

#import "ABPlayer.h"
#import "ABVolumeManager.h"

@implementation ABPlayer

- (void)play {
    [[ABVolumeManager sharedManager] setAudioWhenPlaying];
    
    [super play];
}

- (void)pause {
    [[ABVolumeManager sharedManager] setAudioWhenStopping];
    
    [super pause];
}

@end
