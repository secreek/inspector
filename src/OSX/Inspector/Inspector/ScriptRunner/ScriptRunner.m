//
//  ScriptRunner.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-5.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "ScriptRunner.h"
#import <AFNetworking.h>

@interface ScriptRunner ()

@property (assign, nonatomic) ScriptRunnerType type;

@end

@implementation ScriptRunner

- (id)initWithScriptURL:(NSURL *)url refresh:(BOOL)refresh {
    self = [super init];
    if (self) {
        self.type = ScriptRunnerType_Script;
    }
    return self;
}

- (id)initWithCommand:(NSString *)command {
    self = [super init];
    if (self) {
        self.type = ScriptRunnerType_Command;
    }
    return self;
}

- (void)runWithTimeInterval:(NSTimeInterval) timeInterval {
    
}

- (void)stop {
    
}

@end
