//
//  LogGetter.h
//  Inspector
//
//  Created by Xinrong Guo on 13-5-6.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LogGetterDelegate;

@interface LogGetter : NSObject

@property (weak, nonatomic) id<LogGetterDelegate> delegate;

@property (strong, nonatomic) NSURL *logURL;

- (void)startGettinglogContentWithPath:(NSString *)path;

@end

@protocol LogGetterDelegate <NSObject>

- (void)logGetter:(LogGetter *)logGetter didGetLogContent:(NSString *)content;
- (void)logGetter:(LogGetter *)logGetter didFailWithError:(NSError *)error;

@end
