//
//  main.m
//  vk_reader
//
//  Created by Евгений Клышко on 15.03.15.
//  Copyright (c) 2015 uubo. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *accesToken = @"b574f1a4d8606febb7ff3fa8653b58c8ee2ab63dd275ca2cf8cb7eefb6b1d712cd03ad31c34f83929ef27&access_token=72dae3f40baee22a38584e07c431";
        NSString *urlString = [@"api.vk.com/method/messages.get.xml?out=0&count=10&access_token=" stringByAppendingString:accesToken];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [request setHTTPMethod:@"GET"];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        
    }
    return 0;
}
