//
//  ViewController.m
//  VkMessage
//
//  Created by Влад Агиевич on 15.03.15.
//  Copyright (c) 2015 Uubo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController() <NSURLConnectionDelegate>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *vkApiRequestString;
@property (nonatomic) NSInteger lastReadMessageID;
@property (nonatomic) NSInteger state;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self getLastReadMessageID];
    
    [self beginLoop];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)getLastReadMessageID
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?out=0&count=10&access_token=%@",
                           self.vkApiRequestString, @"messages.get.xml", self.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.state = 1;
    [connection start]; 
}

- (void)beginLoop
{
    //while (1) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@?out=0&count=10&last_message_id=%@&access_token=%@",
                               self.vkApiRequestString, @"messages.get.xml",
                               [NSString stringWithFormat:@"%li",
                                (long)self.lastReadMessageID],
                               self.accessToken];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        self.state = 2;
        [connection start];
    //    sleep(10);
    //}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response received");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *err = nil;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error: &err];
    
    if (self.state == 1) {
        NSArray *midNodes = [doc nodesForXPath:@"/response/message/mid" error:&err];
        
        self.lastReadMessageID = [[midNodes[0] stringValue] integerValue];
        
    } else if (self.state == 2) {
        NSArray *messageNodes = [doc nodesForXPath:@"/response/message" error:&err];
        
        for (NSXMLNode *messageNode in messageNodes) {
            NSArray *messageNodeChildren = [messageNode children];
            for (NSXMLNode *child in messageNodeChildren) {
                NSLog(@"\n\n");
                NSString *childName = [child name];
                if ([childName isEqualToString:@"mid"]) {
                    NSLog(@"%@ - %@", @"mid", [child stringValue]);
                } else if ([childName isEqualToString:@"uid"]) {
                    NSLog(@"%@ - %@", @"uid", [child stringValue]);
                } else if ([childName isEqualToString:@"body"]) {
                    NSLog(@"%@ - %@", @"body", [child stringValue]);
                }
            }
        }
    }
}


- (NSString *)accessToken
{
    if (_accessToken) {
        return _accessToken;
    } else {
        _accessToken = @"b574f1a4d8606febb7ff3fa8653b58c8ee2ab63dd275ca2cf8cb7eefb6b1d712cd03ad31c34f83929ef27";
        return _accessToken;
    }
}

- (NSString *)vkApiRequestString
{
    if (_vkApiRequestString) {
        return _vkApiRequestString;
    } else {
        _vkApiRequestString = @"https://api.vk.com/method/";
        return _vkApiRequestString;
    }
}

@end
