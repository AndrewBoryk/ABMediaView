//
//  ABCommons.h
//  Pods
//
//  Created by Andrew Boryk on 2/1/17.
//
//

#import <Foundation/Foundation.h>

@interface ABCommons : NSObject

/// Returns a color for a hex string
+ (UIColor*)colorWithHexString:(NSString*)hex;

#pragma mark - Conditional Oriented

/// Returns true if the object is not null or nil, otherwise returns false
+ (BOOL)notNull:(id)object;

/// Returns true if the object is null or nil, otherwise returns false
+ (BOOL)isNull:(id)object;

/// Returns true if the object is not nil, returns true if the object is null
+ (BOOL)notNil:(id)object;

/// Returns true if the object is nil, returns false if the object is null
+ (BOOL)isNil:(id)object;

/// Returns true if the object is not just spaces or blank, otherwise returns false
+ (BOOL)notBlank:(NSString *)text;

/// Determines if the view is in landscape mode and has rotated to landscape mode
+ (BOOL)isLandscape;

#pragma mark - String Modification Oriented

/*!
 * @brief Removes special characters from a string (%,#,&, etc.)
 * @param text the string looking to be converted
 * @return a string without special characters
 */
+ (NSString *)removeSpecialCharacters:(NSString *)text;

/// Trims white space and removes extra new lines from string
+ (NSString *)trimWhiteSpace:(NSString *)text;

/// Replaces instances of "\n\n" with "\n" and "  " with " "
+ (NSString *)trimMultiSpace:(NSString *)text;

/// Trims white space and removes extra new lines from string, and replaces instances of "\n\n" with "\n" and "  " with " "
+ (NSString *)trimWhiteAndMultiSpace:(NSString *)text;

/*!
 * @brief Removes spaces from a string
 * @param text The string that spaces will be removed from
 * @return A string without spaces
 */
+ (NSString *)removeSpaces:(NSString *)text;

/// Determine that string is not blank and not null
+ (BOOL)isValidEntry:(NSString *)text;

/// Returns the width of the view
+ (float)viewWidth;
@end
