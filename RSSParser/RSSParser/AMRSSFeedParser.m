//
//  AMRSSFeedParser.m
//  RSSParser
//
//  Created by Alexander Mack on 17.10.12.
//  Copyright (c) 2012 Alexander Mack. All rights reserved.
//

#import "AMRSSFeedParser.h"
#import "AMRSSFeedChannel.h"
#import "AMRSSFeedItem.h"
#import "NSObject+PrintProperties.h"
#import "AMRSSFeedEnclosureItem.h"
#import "NSDate+Extensions.h"

typedef enum {
    AMParsingElementTypeChannel = 0,
    AMParsingElementTypeItem = 1
} AMParsingElementType;

@interface AMRSSFeedParser()

@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) AMRSSFeedChannel *channel;
@property (nonatomic, strong) AMRSSFeedItem *currentItem;
@property (nonatomic, strong) id currentlyParsingElement;               //channel or item
@property (nonatomic, strong) NSDictionary *dictCurrentElementAttributes;   //element attributes
@property (nonatomic, assign) AMParsingElementType parsingElementType;
@property (nonatomic, strong) NSString *currentElementName;
@property (nonatomic, strong) NSString *currentCharacters;              //characters are not returned at once
@property (nonatomic, strong) NSDictionary *dictElementToSelectorMapper;

@end

@implementation AMRSSFeedParser

- (id) init;
{
    self = [super init];
    
    if(self) {
        self.dictCurrentElementAttributes = [[NSDictionary alloc] init];
    }
    
    return self;
}

- (void) parse:(NSData *) aRSSFeed parseError:(NSError **) aParseError;
{
    [self setup];
    
    self.parser = [[NSXMLParser alloc] initWithData:aRSSFeed];
    self.parser.delegate = self;
    
    self.parser.shouldProcessNamespaces = NO;
    self.parser.shouldReportNamespacePrefixes = NO;
    self.parser.shouldResolveExternalEntities = NO;
    
    [self.parser parse];
    
    if(aParseError && [self.parser parserError]) {
        *aParseError = [self.parser parserError];
    }
}

#pragma mark -
#pragma mark Init Element to Selector Mapping

- (void) setup;
{
    NSArray *arrayKeys = [NSArray arrayWithObjects:
                          @"title",
                          @"description",
                          @"link",
                          @"copyright",
                          @"language",
                          @"managingEditor",
                          @"pubDate",
                          @"lastBuildDate",
                          @"ttl",
                          @"generator",
                          @"category",
                          @"enclosure",
                          @"webMaster",
                          @"author",
                          @"comments",
                          @"source",
                          @"guid",
                          nil];
    
    NSString *titleHandler = NSStringFromSelector(@selector(handleTitleCharacters:));
    NSString *descriptionHandler = NSStringFromSelector(@selector(handleDescriptionCharacters:));
    NSString *linkHandler = NSStringFromSelector(@selector(handleLinkCharacters:));
    NSString *copyrightHandler = NSStringFromSelector(@selector(handleCopyrightCharacters:));
    NSString *languageHandler = NSStringFromSelector(@selector(handleLanguageharacters:));
    NSString *managingEditorHandler = NSStringFromSelector(@selector(handleManagingEditorCharacters:));
    NSString *pubDateHandler = NSStringFromSelector(@selector(handlePubDateCharacters:));
    NSString *lastBuildDateHandler = NSStringFromSelector(@selector(handleLastBuildDateCharacters:));
    NSString *ttlHandler = NSStringFromSelector(@selector(handleTimeToLiveCharacters:));
    NSString *generatorHandler = NSStringFromSelector(@selector(handleGeneratorCharacters:));
    NSString *categoryHandler = NSStringFromSelector(@selector(handleCategoryCharacters:));
    NSString *enclosureHandler = NSStringFromSelector(@selector(handleEnclosureCharacters:));
    NSString *webmaster = NSStringFromSelector(@selector(handleWebmasterCharacters:));
    NSString *comments = NSStringFromSelector(@selector(handleCommentsCharacters:));
    NSString *source = NSStringFromSelector(@selector(handleSourceCharacters:));
    NSString *author = NSStringFromSelector(@selector(handleAuthorCharacters:));
    NSString *guid = NSStringFromSelector(@selector(handleGuidCharacters:));
    
    NSArray *arrayHanlderMethods = [NSArray arrayWithObjects:
                                    titleHandler,
                                    descriptionHandler,
                                    linkHandler,
                                    copyrightHandler,
                                    languageHandler,
                                    managingEditorHandler,
                                    pubDateHandler,
                                    lastBuildDateHandler,
                                    ttlHandler,
                                    generatorHandler,
                                    categoryHandler,
                                    enclosureHandler,
                                    webmaster,
                                    author,
                                    comments,
                                    source,
                                    guid,
                                    nil];
    
    self.dictElementToSelectorMapper = [NSDictionary dictionaryWithObjects:arrayHanlderMethods
                                                                   forKeys:arrayKeys];
    
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict;
{
    //check channel items first
    //channel element indicates start of channel
    if ([elementName isEqualToString:@"channel"]) {
        self.channel = [[AMRSSFeedChannel alloc] init];
        self.parsingElementType = AMParsingElementTypeChannel;
    }
    //item element indicates start of feed item
    else if([elementName isEqualToString:@"item"]) {
        self.currentItem = [[AMRSSFeedItem alloc] init];
        self.parsingElementType = AMParsingElementTypeItem;
    }
    
    //save elementName for later distinction
    self.currentElementName = elementName;
    
    //save attributes
    self.dictCurrentElementAttributes = attributeDict;
    
    //init new string for the element text
    self.currentCharacters = @"";
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    self.currentCharacters = [NSString stringWithFormat:@"%@%@",self.currentCharacters, string];
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName;
{

    //channel element indicates end of channel
    if ([elementName isEqualToString:@"channel"]) {

    }
    //item element indicates end of feed item
    else if([elementName isEqualToString:@"item"]) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.channel.items];
        [array addObject:self.currentItem];
        self.channel.items = array;
    } else {
     
        //if its a standard element, we do have a selector to handle it
        SEL handlerMethod = NSSelectorFromString([self.dictElementToSelectorMapper objectForKey:self.currentElementName]);
        //check if we parsing a standard element
        if(handlerMethod) {
            [self performSelector:handlerMethod withObject:self.currentCharacters];
        } else {    //we are parsing an custom element
            [self handleCustomPropertyWithValue:self.currentCharacters];
        }
        
        //not needed anymore, current element finished
        self.currentCharacters = nil;
        
    }
}

#pragma mark -
#pragma mark Handler Methods For Parsing

#pragma mark -
#pragma mark Custom Properties

- (void) handleCustomPropertyWithValue:(NSString *) aValue;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:

            break;
        case AMParsingElementTypeItem:
        {
            NSMutableDictionary *dictProperties = [[NSMutableDictionary alloc]
                                                   initWithDictionary:self.currentItem.dictCustomProperties];
            [dictProperties setObject:aValue forKey:self.currentElementName];
            self.currentItem.dictCustomProperties = dictProperties;
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Handler Methods for Elements in Channel and Item

- (void) handleTitleCharacters:(NSString *) aTitle;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.title = aTitle;
            break;
        case AMParsingElementTypeItem:
            self.currentItem.title = aTitle;
            break;
        default:
            break;
    }
}

- (void) handleDescriptionCharacters:(NSString *) aDescription;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.feedDescription = aDescription;
            break;
        case AMParsingElementTypeItem:
            self.currentItem.feedDescription = aDescription;
            break;
        default:
            break;
    }
}

- (void) handleLinkCharacters:(NSString *) aLink;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.link = aLink;
            break;
        case AMParsingElementTypeItem:
            self.currentItem.link = aLink;
            break;
        default:
            break;
    }
}

- (void) handlePubDateCharacters:(NSString *) aPubDate;
{
    //parse the date to proper format
    NSDate *date = [NSDate dateFromRFC822String:aPubDate];
    
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.pubDate = date;
            break;
        case AMParsingElementTypeItem:
            self.currentItem.pubDate = date;
            break;
        default:
            break;
    }
}

- (void) handleCategoryCharacters:(NSString *) aCategory;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.category = aCategory;
            break;
        case AMParsingElementTypeItem:
            self.currentItem.category = aCategory;
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Channel Elements

- (void) handleLastBuildDateCharacters:(NSString *) aLastBuildDate;
{
    //parse date to proper format
    NSDate *lastBuildDate = [NSDate dateFromRFC822String:aLastBuildDate];
    
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.lastBuildDate = lastBuildDate;
            break;
        default:
            break;
    }
}

- (void) handleManagingEditorCharacters:(NSString *) aManagingEditor;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.managingEditor = aManagingEditor;
            break;
        default:
            break;
    }
}

- (void) handleGeneratorCharacters:(NSString *) aGenerator;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.generator = aGenerator;
            break;
        default:
            break;
    }
}

- (void) handleTimeToLiveCharacters:(NSString *) aTTL;
{
    //parse ttl
    
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.timeToLive = [aTTL integerValue];
            break;
        default:
            break;
    }
}

- (void) handleCopyrightCharacters:(NSString *) aCopyright;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.copyright = aCopyright;
            break;
        default:
            break;
    }
}

- (void) handleLanguageCharacters:(NSString *) aLanguage;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.language = aLanguage;
            break;
        default:
            break;
    }
}

- (void) handleWebmasterCharacters:(NSString *) aWebmaster;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.webmaster = aWebmaster;
            break;
        default:
            break;
    }
}

- (void) handleCommentsCharacters:(NSString *) aComments;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeItem:
            self.currentItem.commentsURL = aComments;
            break;
        default:
            break;
    }
}

- (void) handleSourceCharacters:(NSString *) aSource;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeItem:
            self.currentItem.source = aSource;
            break;
        default:
            break;
    }
}

- (void) handleAuthorCharacters:(NSString *) aAuthor;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeItem:
            self.currentItem.author = aAuthor;
            break;
        default:
            break;
    }
}

- (void) handleGuidCharacters:(NSString *) aGuid;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeItem:
            self.currentItem.guid = aGuid;
            break;
        default:
            break;
    }
}
- (void) handleEnclosureCharacters:(NSString *) aEnclosure;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeItem:
        {
            //extract attributes
            NSString *url = [self.dictCurrentElementAttributes objectForKey:@"url"];
            NSString *type = [self.dictCurrentElementAttributes objectForKey:@"type"];
            NSInteger length = [[self.dictCurrentElementAttributes objectForKey:@"length"] intValue];
            
            //create enclosure element
            AMRSSFeedEnclosureItem *enclosureItem = [[AMRSSFeedEnclosureItem alloc] init];
            enclosureItem.url = url;
            enclosureItem.type = type;
            enclosureItem.length = length;
            
            //add to channel item
            NSMutableArray *arrayEnclosures = [NSMutableArray arrayWithArray:
                                               self.currentItem.arrayEnclosures];
            [arrayEnclosures addObject:enclosureItem];
            self.currentItem.arrayEnclosures = arrayEnclosures;
        }
            break;
        default:
            break;
    }
}

- (void) handleLanguageharacters:(NSString *) aLanguage;
{
    //check which rss element we are at
    switch (self.parsingElementType) {
        case AMParsingElementTypeChannel:
            self.channel.language = aLanguage;
            break;
        default:
            break;
    }
}

@end
