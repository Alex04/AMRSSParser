AMRSSParser
===========

AMRSSParser is simple rss parser for iOS. Unlike the MWFeedParser, AMRSSParser does not download the feed so that you can still use your current networking framework like AFNetworking.
 
How to use
===========
 
Lets say you have finished the download of your feed with AFNetworking and want to parse the rss feed data:


```
//...
[self.requestManager GET:aPath
                  parameters:self.requestParameters
                     success:^(AFHTTPRequestOperation *operation, NSData *responseData) {
                         // Initiate our parser
                         AMRSSFeedParser *parser = [[AMRSSFeedParser alloc] init];
                         [parser parse:responseData onSuccess:^(AMRSSFeedChannel *channel) {
                             //Do anything you want with the channel and it's containing objects
                         } onFailure:^(NSError *error) {
                             //Okay, there was an error parsing the data - call the given error block onFailure if available
                             if(onFailure) {
                                 onFailure(nil, error);
                             }
                         }];
                     }
                     failure:onFailure];

```


ARC
===========
AMRSSParser uses ARC

Contact
===========
http://www.ama-dev.com

License
===========
AMRSSParser is licensed under the MIT License.

