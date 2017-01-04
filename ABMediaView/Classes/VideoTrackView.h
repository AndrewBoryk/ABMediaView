//
//  VideoTrackView.h
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ABUtils.h"

@interface VideoTrackView : UIView

/// View which shows how much of the video has loaded
@property (strong, nonatomic) UIView *bufferView;

/// View which shows progress of watching the video
@property (strong, nonatomic) UIView *progressView;

/// Current progress for streaming video
@property (strong, nonatomic) NSNumber *progress;

/// Current buffer for streaming video
@property (strong, nonatomic) NSNumber *buffer;

/// Update progress for the streaming video
- (void) setProgress:(NSNumber *)progress withDuration: (CGFloat) duration;

/// Update buffer for the streaming video
- (void) setBuffer:(NSNumber *)buffer withDuration: (CGFloat) duration;

@end
