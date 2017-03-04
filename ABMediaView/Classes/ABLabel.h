//
//  ABLabel.h
//  Pods
//
//  Created by Andrew Boryk on 3/4/17.
//
//

#import <UIKit/UIKit.h>

@protocol ABLabelDelegate;

@interface ABLabel : UILabel

/// Delegate for the ABLabel
@property (weak, nonatomic) id<ABLabelDelegate> delegate;

/// Determines if the label's delegate responds to touchUpInside events
@property (nonatomic) BOOL touchUpInside;

/// Adds a shadow to the given label
+ (void)addShadow:(UILabel *)label;

@end

@protocol ABLabelDelegate <NSObject>

@optional

/// UILabel did receive a touch up inside tap event
- (void)labelDidTouchUpInside:(ABLabel *)label;

@end

