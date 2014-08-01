//
//  AMRSSFeedChannel.h
//  RSSParser
//
//  Created by Alexander Mack on 17.10.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMRSSFeedChannel : NSObject

//mandatory
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *feedDescription;
@property(nonatomic, strong) NSString *link;

//optional
@property(nonatomic, strong) NSString *language;
@property(nonatomic, strong) NSString *copyright;
@property(nonatomic, strong) NSString *managingEditor;
@property(nonatomic, strong) NSDate *pubDate;
@property(nonatomic, strong) NSDate *lastBuildDate;
@property(nonatomic, assign) NSTimeInterval timeToLive;
@property(nonatomic, strong) NSString *generator;
@property(nonatomic, strong) NSString *category;
@property(nonatomic, strong) NSString *rating;
@property(nonatomic, assign) NSInteger skipHours;
@property(nonatomic, assign) NSInteger skipDays;
@property(nonatomic, strong) NSString *webmaster;

@property(nonatomic, strong) NSArray *enclosures;

@property(nonatomic, strong) NSArray *items;

@end
