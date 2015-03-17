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

#define SLEEP_US_TIME 2000000

@interface ViewController() <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *vkApiRequestString;
@property (nonatomic) NSInteger lastReadMessageID;
@property (nonatomic) NSInteger state;
@property (nonatomic) int fileDescriptor;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *questionButton;
@property (nonatomic) BOOL buttonPressed;
@property (nonatomic, strong) NSArray *portsArray;
@property (weak) IBOutlet NSTextField *textLabel;


@end

@implementation ViewController

- (IBAction)pressButton:(NSButton *)sender {
    
    if ([self.startButton.title isEqualToString:@"Start"]) {
        
        for (NSString* port in self.portsArray) {
            
            const char* portInC = [port cStringUsingEncoding:NSUTF8StringEncoding];
            self.fileDescriptor = openSerialPort(portInC);
            if (self.fileDescriptor != -1) {
                NSLog(@"Port with Arduino is found");
                self.textLabel.stringValue = @"working...";
                self.startButton.title = @"Stop";
                [self getMessages];
                break;
            }
            NSLog(@"Port with Arduino is not found!");
            self.textLabel.stringValue = @"no Arduino connection";
            
        }
        
        
        
    } else {
        
        self.startButton.title = @"Start";
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.portsArray =  [NSArray arrayWithObjects:@"/dev/cu.usbmodem1411", @"/dev/cu.usbmodem1431", @"/dev/tty.usbmodem1411", @"/dev/tty.usbmodem1431", nil];
    
    self.lastReadMessageID = 0;
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
                NSString *childName = [child name];
                if ([childName isEqualToString:@"body"]){
                    if ([[child stringValue] isEqualToString:@"жги"] || [[child stringValue] isEqualToString:@"Жги"] ) {
                        [self sendCommandToArduino: 1];
                    } else {
                        [self sendCommandToArduino: 0];
                    }
                }
                /*
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
                */
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
    if (![self.startButton.title isEqualToString:@"Start"]){
        NSLog(@"Connection finished loading");
        usleep(SLEEP_US_TIME);
        [self getMessages];
    }
    else if ([self.startButton.title isEqualToString:@"Start"]){
        closeSerialPort(self.fileDescriptor);
        self.textLabel.stringValue = @"";
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
