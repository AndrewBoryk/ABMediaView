//
//  ABLabel.m
//  Pods
//
//  Created by Andrew Boryk on 3/4/17.
//
//

#import "ABLabel.h"
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ABCommons.h"

@interface ABLabel ()

/// Recognizer that recognizes tap events on the label
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation ABLabel

#pragma mark - Initialization Methods

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [ABLabel addShadow:self];
        self.userInteractionEnabled = YES;
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentLeft;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.touchUpInside = NO;
        
        if (![ABCommons notNull:self.tapRecognizer]) {
            self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchUpInside:)];
            self.tapRecognizer.numberOfTapsRequired = 1;
        }
        
        self.tapRecognizer.enabled = self.touchUpInside;
        
        if (![self.gestureRecognizers containsObject:self.tapRecognizer]) {
            [self addGestureRecognizer:self.tapRecognizer];
        }
    }
    
    return self;
    
}

#pragma mark - Class Methods

+ (void)addShadow:(UILabel *)label {
    label.layer.masksToBounds = NO;
    label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.32f];
    label.shadowOffset = CGSizeMake(0, 1);
}

#pragma mark - Custom Accessor Methods

- (void)setTouchUpInside:(BOOL)touchUpInside {
    _touchUpInside = touchUpInside;
    
    if ([ABCommons notNull:self.tapRecognizer]) {
        self.tapRecognizer.enabled = self.touchUpInside;
    }
    
}

#pragma mark - Gesture Methods

- (void)handleTouchUpInside:(UITapGestureRecognizer *)gesture {
    
    if ([self.delegate respondsToSelector:@selector(labelDidTouchUpInside:)]) {
        [self.delegate labelDidTouchUpInside:self];
    }
    
}

@end
