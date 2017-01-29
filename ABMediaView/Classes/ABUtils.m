//
//  ABUtils.m
//  Pods
//
//  Created by Andrew Boryk on 1/4/17.
//
//

#import "ABUtils.h"

@implementation ABUtils

+ (BOOL)notNull:(id)object {
    if ([object isEqual:[NSNull null]] || [object isKindOfClass:[NSNull class]] || object == nil) {
        return false;
    }
    else {
        return true;
    }
}

+ (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [hex uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (float)viewWidth {
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    return screen.size.width;
}
@end
