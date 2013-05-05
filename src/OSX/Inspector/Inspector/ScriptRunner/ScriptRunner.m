//
//  ScriptRunner.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-5.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "ScriptRunner.h"

@interface ScriptRunner ()

@property (assign, nonatomic) ScriptRunnerType type;

@end

@implementation ScriptRunner

- (id)initWithScriptURL:(NSURL *)url refresh:(BOOL)refresh delay:(NSTimeInterval) delay {
    self = [super init];
    if (self) {
        self.type = ScriptRunnerType_Script;
    }
    return self;
}

- (id)initWithCommand:(NSString *)command delay:(NSTimeInterval) delay {
    self = [super init];
    if (self) {
        self.type = ScriptRunnerType_Command;
    }
    return self;
}

@end
