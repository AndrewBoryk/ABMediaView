//
//  ABCommons.m
//  Pods
//
//  Created by Andrew Boryk on 2/1/17.
//
//

#import "ABCommons.h"

@implementation ABCommons

#pragma mark - Conditional Oriented

+ (BOOL)notNull:(id)object {
    
    if ([object isEqual:[NSNull null]] || [object isKindOfClass:[NSNull class]] || object == nil) {
        return false;
    } else {
        return true;
    }
    
}

+ (BOOL)isNull:(id)object {
    
    if ([object isEqual:[NSNull null]] || [object isKindOfClass:[NSNull class]] || object == nil) {
        return true;
    } else {
        return false;
    }
    
}

+ (BOOL)notNil:(id)object {
    
    if (object == nil) {
        return false;
    } else {
        return true;
    }
    
}

+ (BOOL)isNil:(id)object {
    
    if (object == nil) {
        return true;
    } else {
        return false;
    }
    
}

+ (BOOL)notBlank:(NSString *)text {
    
    if ([ABCommons notNull:text]) {
        
        if (![text isEqualToString:@""]) {
            return YES;
        }
        
    }
    
    return NO;
}

#pragma mark - String Modification Oriented

+ (NSString *)removeSpecialCharacters:(NSString *)text {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    return  [[text componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
}

+ (NSString *)trimWhiteSpace:(NSString *)text {
    
    if ([ABCommons notNull:text]) {
        text = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return text;
}

+ (NSString *)trimMultiSpace:(NSString *)text {
    
    if ([ABCommons notNull:text]) {
        
        while ([text containsString:@"  "]) {
            text = [text stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        }
        
        while ([text containsString:@"\n\n"]) {
            text = [text stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        }
        
    }
    
    return text;
}

+ (NSString *)trimWhiteAndMultiSpace:(NSString *)text {
    
    if ([ABCommons notNull:text]) {
        text = [ABCommons trimWhiteSpace:text];
        text = [ABCommons trimMultiSpace:text];
    }
    
    return text;
}

+ (NSString *)removeSpaces:(NSString *)text {
    text = [self trimWhiteAndMultiSpace:text];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return text;
}

+ (BOOL)isValidEntry:(NSString *)text {
    
    if ([ABCommons notNull:text]) {
        
        if ([ABCommons notBlank:[ABCommons removeSpaces:text]]) {
            return YES;
        }
        
    }
    
    return NO;
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

+ (BOOL)isLandscape {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGFloat width = screenRect.size.width;
    CGFloat height = screenRect.size.height;
    
    if (UIDeviceOrientationIsPortrait(orientation)) {
        
        if (height < width) {
            return YES;
        } else {
            return NO;
        }
        
    } else {
        
        if (height > width) {
            return NO;
        } else {
            return YES;
        }
        
    }
}

@end
