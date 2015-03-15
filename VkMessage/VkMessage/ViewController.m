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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *urlString = [NSString stringWithFormat:@"%@%@?out=0&count=10&access_token=%@",
                           self.vkApiRequestString, @"messages.get.xml", self.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response received");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseString);
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
