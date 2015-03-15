//
//  ViewController.m
//  VkMessage
//
//  Created by Влад Агиевич on 15.03.15.
//  Copyright (c) 2015 Uubo. All rights reserved.
//

#import "ViewController.h"
#include "SerialPortSample.h"
#include <string.h>

@interface ViewController() <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *vkApiRequestString;
@property (nonatomic) NSInteger lastReadMessageID;
@property (nonatomic) NSInteger state;
@property (nonatomic) int fileDescriptor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileDescriptor = openSerialPort("/dev/cu.usbmodem1431");

    self.lastReadMessageID = 0;
    
    [self getMessages];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void)getMessages
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?out=0&count=10&last_message_id=%li&access_token=%@",
                                   self.vkApiRequestString, @"messages.get.xml",
                                   (long)self.lastReadMessageID,
                                   self.accessToken];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
            
            [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response received");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *err = nil;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error: &err];
    
    NSArray *messageNodes = [doc nodesForXPath:@"/response/message" error:&err];
    if (messageNodes.count) {
        self.lastReadMessageID = [[[messageNodes[0] childAtIndex:0] stringValue] integerValue];
        
        for (NSXMLNode *messageNode in messageNodes) {
            NSArray *messageNodeChildren = [messageNode children];
            for (NSXMLNode *child in messageNodeChildren) {
                NSLog(@"");
                NSString *childName = [child name];
                if ([childName isEqualToString:@"mid"]) {
                    NSLog(@"%@ - %@", @"mid", [child stringValue]);
                } else if ([childName isEqualToString:@"uid"]) {
                    NSInteger uid = [[child stringValue] integerValue];
                    if (uid == 38705281) {
                        [self sendCommandToArduino: 1];
                    } else if (uid == 12512860) {
                        [self sendCommandToArduino: 0];
                    }
                } else if ([childName isEqualToString:@"body"]) {
                    NSLog(@"%@ - %@", @"body", [child stringValue]);
                }
            }
        }
    }
}

- (void)sendCommandToArduino:(NSUInteger)cmd
{
    NSLog(@"Ready to send command");
    
    char command[10];
    sprintf(command, "%lu", (unsigned long)cmd);
    write(self.fileDescriptor, command, strlen(command));
//    read(self.fileDescriptor, command, 10);
//    usleep(100000);
    
    //closeSerialPort(fileDescriptor);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection finished loading");
    usleep(500000);
    [self getMessages];
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
