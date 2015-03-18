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

#define SLEEP_US_TIME 1000000

@interface ViewController() <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *vkApiRequestString;
@property (nonatomic) NSInteger lastReadMessageID;
@property (nonatomic) NSInteger state;
@property (nonatomic) int fileDescriptor;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *questionButton;
@property (nonatomic) BOOL buttonPressed;
@property (nonatomic, strong) NSArray *serialPorts;
@property (weak) IBOutlet NSTextField *textLabel;
@property (nonatomic, strong) NSArray *onAnswers;
@property (nonatomic, strong) NSArray *offAnswers;
@property (nonatomic, strong) NSArray *onRequests;
@property (nonatomic, strong) NSArray *offRequests;
@property (nonatomic) NSInteger counter;

@end

@implementation ViewController

- (IBAction)pressButton:(NSButton *)sender {
    
    if ([self.startButton.title isEqualToString:@"Start"]) {
        
        for (NSString* port in self.serialPorts) {
            
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
    self.serialPorts =  [NSArray arrayWithObjects:@"/dev/cu.usbmodem1411", @"/dev/cu.usbmodem1431", @"/dev/tty.usbmodem1411", @"/dev/tty.usbmodem1431", nil];
    self.offAnswers = [NSArray arrayWithObjects:@"ok", @"ща выключу", @"вас поняла", @"варя все сделает", @"варя выключит", nil];
    self.onAnswers = [NSArray arrayWithObjects:@"Бут сделано, хозяин", @"да, сэр", @"как пожелаете, господин", @"именно это я и сделаю", @"вы несомненно правы, повелитель", nil];
    self.onRequests = [NSArray arrayWithObjects:@"Жги", @"Зажигай", @"жги", @"зажигай", @"Поддай огоньку", @"включи", @"вкл", nil];
    self.offRequests = [NSArray arrayWithObjects:@"Выкл", @"Заебала", @"Ослепни", @"Вырубай", @"Сильно светит", @"Ок", nil];
    
    self.lastReadMessageID = 0;
    self.counter = 0;
   //[self sendMessage:@"сука" to:12512860];
    
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)sendMessage:(NSString *)message to:(NSInteger)uid
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?uid=%li&message=%@&&access_token=%@",
                           self.vkApiRequestString, @"messages.send", (long)uid, [self urlEncode:message], self.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conSend = [NSURLConnection connectionWithRequest:request delegate:nil];
    
    [conSend start];
    NSLog(@"%@ was sent to %ld", message, uid);
}

- (void)getMessages
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?out=0&count=10&last_message_id=%li&access_token=%@",
                                   self.vkApiRequestString, @"messages.get.xml",
                                   (long)self.lastReadMessageID,
                                   self.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conGet = [NSURLConnection connectionWithRequest:request delegate:self];
    [conGet start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   // NSLog(@"%@", connection);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    NSError *err = nil;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error: &err];
    [self parseMyXML:doc];
    
}

-(void)parseMyXML:(NSXMLDocument *)doc
{

    NSError *err = nil;
    NSArray *messageNodes = [doc nodesForXPath:@"/response/message" error:&err];
   
    if (messageNodes.count) {
        self.lastReadMessageID = [[[messageNodes[0] childAtIndex:0] stringValue] integerValue];
        
        if (self.counter > 0) {
        
            for (NSXMLNode *messageNode in messageNodes) {
                NSArray *messageAttributes = [messageNode children];
                NSInteger uid = 0;
                NSString *messagetext;
                for (NSXMLNode *attribute in messageAttributes) {
                    
                    if ([[attribute name] isEqualToString:@"uid"]){
                        uid = [[attribute stringValue] integerValue];
                    } else if ([[attribute name] isEqualToString:@"body"]){
                        messagetext = [attribute stringValue];
                    }
                }
                
                NSLog(@"%@ from %li", messagetext, uid);
    
                
                if ([self.onRequests containsObject:messagetext]){
                    NSUInteger index = arc4random() % [self.onAnswers count];
                    [self sendCommandToArduino: 1];
                    [self sendMessage:[self.onAnswers objectAtIndex:index] to:uid];
                    
                } else if ([self.offRequests containsObject:messagetext]){
                    [self sendCommandToArduino: 0];
                    NSUInteger index = arc4random() % [self.offAnswers count];
                    [self sendMessage:[self.offAnswers objectAtIndex:index]  to:uid];
                    
                } else {
                    [self sendMessage:[NSString stringWithFormat:@"Что вы имеете в виду под '%@'?", messagetext]  to:uid];
                }
            }
        }
        else {
            self.counter++;
        }
    
    }
   
}

- (void)sendCommandToArduino:(NSUInteger)cmd
{
    //NSLog(@"Ready to send command");
    
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
        //NSLog(@"Connection finished loading");
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

- (NSString *)urlEncode:(NSString *)str {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
}

@end
