//
//  AMRSSFeedItem.h
//  RSSParser
//
//  Created by Alexander Mack on 17.10.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMRSSFeedChannel.h"

@interface AMRSSFeedItem : NSObject

//mandatory
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *feedDescription;
@property(nonatomic, copy) NSString *link;

//optional
@property(nonatomic, copy) NSString *author;
@property(nonatomic, copy) NSString *source;
@property(nonatomic, copy) NSString *commentsURL;
@property(nonatomic, strong) NSDate *pubDate;
@property(nonatomic, copy) NSString *guid;
@property(nonatomic, copy) NSString *category;
@property(nonatomic, strong) NSArray *arrayEnclosures;
@property(nonatomic, strong) AMRSSFeedChannel *channel;

//custom properties
@property(nonatomic, strong) NSDictionary *dictCustomProperties;

@end
