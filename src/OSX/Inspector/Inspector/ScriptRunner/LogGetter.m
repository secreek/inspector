//
//  LogGetter.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-6.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "LogGetter.h"
#import "INSPLogUtlils.h"
#import <AFNetworking.h>

@interface LogGetter ()

@property (weak, nonatomic) AFHTTPRequestOperation *lastOperation;

@end

@implementation LogGetter

- (void)startGettinglogContentWithPath:(NSString *)path {
    if ([path rangeOfString:@"://"].location == NSNotFound) {
        self.logURL = [NSURL fileURLWithPath:path];
        
    }
    else {
        self.logURL = [NSURL URLWithString:path];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_logURL];
    if (self.lastOperation) {
        // cancle last to prevent old request arrive later than new request
        [_lastOperation cancel];
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.lastOperation = operation;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *content = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", content);
        
        [_delegate logGetter:self didGetLogContent:content];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        INSPALog(@"%@", [error localizedDescription]);
        
        [_delegate logGetter:self didFailWithError:error];
    }];
    [operation start];
}

@end
