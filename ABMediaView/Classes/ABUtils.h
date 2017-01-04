//
//  ABUtils.h
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import <Foundation/Foundation.h>

@interface ABUtils : NSObject

/// Returns a color for a hex string
+ (UIColor*)colorWithHexString:(NSString*)hex;

/// Determines whether value is null or nil
+ (BOOL)notNull:(id)object;
@end
