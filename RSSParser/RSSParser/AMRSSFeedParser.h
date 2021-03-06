//
//  AMRSSFeedParser.h
//  RSSParser
//
//  Created by Alexander Mack on 17.10.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMRSSFeedChannel;

typedef void (^AMARSSFeedParserDidFinishParsing) (AMRSSFeedChannel *channel);

typedef void (^AMARSSFeedParserDidFailWithError) (NSError *error);

@interface AMRSSFeedParser : NSObject <NSXMLParserDelegate>


- (void) parse:(NSData *) aRSSFeed
     onSuccess:(AMARSSFeedParserDidFinishParsing) onSuccessBlock
     onFailure:(AMARSSFeedParserDidFailWithError) onFailureBlock;

@end
