//
//  Vk.m
//  vk_reader
//
//  Created by Евгений Клышко on 15.03.15.
//  Copyright (c) 2015 uubo. All rights reserved.
//

#import "Vk.h"

@interface Vk() <NSURLConnectionDelegate>

@property (nonatomic, strong) NSString* responseString;

@end

@implementation Vk

-(id)init
{
    self = [super init];
    if (self){
        
        NSString *accesToken = @"b574f1a4d8606febb7ff3fa8653b58c8ee2ab63dd275ca2cf8cb7eefb6b1d712cd03ad31c34f83929ef27";
        NSString *urlString = [@"https://api.vk.com/method/messages.get.xml?out=0&count=10&access_token=" stringByAppendingString:accesToken];
//        NSURL *url = [NSURL URLWithString:@"http://google.com"];
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
//        [connection start];
//        NSURL *url = [NSURL URLWithString:@"http://ya.ru"];
//       NSData *data = [NSData dataWithContentsOfURL:url];
//       NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//       NSLog(@"ret=%@", ret);
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isMemberOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [httpResponse statusCode];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}




@end

