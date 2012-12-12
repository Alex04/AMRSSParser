//
//  AMRSSFeedItem.h
//  RSSParser
//
//  Created by Alexander Mack on 17.10.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMRSSFeedItem : NSObject

//mandatory
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *feedDescription;
@property(nonatomic, strong) NSString *link;

//optional
@property(nonatomic, strong) NSString *author;
@property(nonatomic, strong) NSString *source;
@property(nonatomic, strong) NSString *commentsURL;
@property(nonatomic, strong) NSDate *pubDate;
@property(nonatomic, strong) NSString *guid;
@property(nonatomic, strong) NSString *category;
@property(nonatomic, strong) NSArray *arrayEnclosures;

//custom properties
@property(nonatomic, strong) NSDictionary *dictCustomProperties;

@end
