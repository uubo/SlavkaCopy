//
//  ViewController.m
//  VkMessage
//
//  Created by Влад Агиевич on 15.03.15.
//  Copyright (c) 2015 Uubo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController() <NSURLConnectionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *url = [NSURL URLWithString:@"http://ya.ru"];
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
    NSLog(@"hui");
}

@end
