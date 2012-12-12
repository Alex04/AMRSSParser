//
//  AMRSSFeedParser.h
//  RSSParser
//
//  Created by Alexander Mack on 17.10.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMRSSFeedParser : NSObject <NSXMLParserDelegate>

- (void) parse:(NSData *) aRSSFeed parseError:(NSError **) aParseError;

@end
