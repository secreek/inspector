//
//  ScriptRunner.h
//  Inspector
//
//  Created by Xinrong Guo on 13-5-5.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ScriptRunnerType_Script,
    ScriptRunnerType_Command,
}ScriptRunnerType;;

@interface ScriptRunner : NSObject

@property (readonly, nonatomic) ScriptRunnerType type;

- (id)initWithScriptURL:(NSURL *)url refresh:(BOOL)refresh;
- (id)initWithCommand:(NSString *)command;

- (void)runWithTimeInterval:(NSTimeInterval) timeInterval;
- (void)stop;

@end
