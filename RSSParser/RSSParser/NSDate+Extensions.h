//
//  NSDate+Extensions.h
//  RSSParser
//
//  Created by Alexander Mack on 11.12.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

//According to the rss specifications all dates are in rfc822 format, but we can use others
+ (NSDate *)dateFromRFC822String:(NSString *)dateString;
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;
+ (NSDate *)dateFromRFC1123:(NSString*)value_;

@end
