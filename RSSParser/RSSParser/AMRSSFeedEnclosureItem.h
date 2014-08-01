//
//  AMRSSFeedEnclosureItem.h
//  RSSParser
//
//  Created by Alexander Mack on 17.10.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMRSSFeedEnclosureItem : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) NSInteger length;

@end
