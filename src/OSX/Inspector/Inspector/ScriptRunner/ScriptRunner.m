//
//  ScriptRunner.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-5.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "ScriptRunner.h"
#import "INSPLogUtlils.h"
#import <AFNetworking.h>

@interface ScriptRunner ()

@property (assign, nonatomic) ScriptRunnerType type;
@property (strong, nonatomic) NSURL *scriptURL;
@property (assign, nonatomic) BOOL refreshScript;
@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSString *scriptFileName;
@property (strong, nonatomic) NSString *scriptContent;

@property (assign, nonatomic) BOOL isRunning;

@end

@implementation ScriptRunner

- (id)initWithScriptPath:(NSString *)path refresh:(BOOL)refresh {
    self = [super init];
    if (self) {
        self.type = ScriptRunnerType_Script;
        
        self.refreshScript = refresh;
        
        if ([path rangeOfString:@"://"].location == NSNotFound) {
            self.scriptURL = [NSURL fileURLWithPath:path];
        }
        else {
            self.scriptURL = [NSURL URLWithString:path];
        }
        
        self.scriptFileName = _scriptURL.lastPathComponent;
        
        NSLog(@"--%@", _scriptURL);
        NSLog(@"--%@", _scriptFileName);
    }
    return self;
}

- (id)initWithCommand:(NSString *)command {
    self = [super init];
    if (self) {
        self.type = ScriptRunnerType_Command;
        
        self.command = command;
    }
    return self;
}

#pragma mark - Control

- (void)prepare {
    if (_type == ScriptRunnerType_Script) {
        [self downloadScript];
    }
}

- (void)runWithTimeInterval:(NSTimeInterval) timeInterval {
    
}

- (void)stop {
    
}

#pragma mark - Script

- (void)runScript {
    // File path
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSURL *cacheDirURL = [manager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *appCacheDirURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Script/", appID] relativeToURL:cacheDirURL];
    
    if (error) {
        INSPALog(@"%@", [error description]);
    }

    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    int randNum = rand();
    NSURL *scriptLocalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%.0lf_%d_%@", currentTime, randNum, _scriptFileName] relativeToURL:appCacheDirURL];
    
    NSLog(@"%@", [scriptLocalURL absoluteString]);
    
    // Save file content
    BOOL success = NO;
    if ([manager createDirectoryAtURL:appCacheDirURL withIntermediateDirectories:YES attributes:nil error:&error]) {
        success = [_scriptContent writeToURL:scriptLocalURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            INSPALog(@"%@", [error description]);
        }
    }
    
    // Set excutable
    if (success) {
        NSNumber *permissions = [NSNumber numberWithUnsignedLong: 493];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:permissions forKey:NSFilePosixPermissions];
        // This actually sets the permissions
        success = [manager setAttributes:attributes ofItemAtPath:[scriptLocalURL path]  error:&error];
        if (error) {
            INSPALog(@"%@", [error description]);
        }
    }
    
    // Run
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[scriptLocalURL path]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *execResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Execresult: \n[%@]", execResult);
    
    if ([_delegate respondsToSelector:@selector(scriptRunner:didFinishExecutionWithResult:)]) {
        [_delegate scriptRunner:self didFinishExecutionWithResult:execResult];
    }
}

- (void)downloadScript {
    NSURLRequest *request = [NSURLRequest requestWithURL:_scriptURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.scriptContent = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", _scriptContent);
        if ([_delegate respondsToSelector:@selector(scriptRunner:didGetScriptContent:)]) {
            [_delegate scriptRunner:self didGetScriptContent:_scriptContent];
        }
        
        [self runScript];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        INSPALog(@"%@", [error localizedDescription]);
        [_delegate scriptRunner:self didFailDownloadingScriptWithError:error];
        
    }];
    [operation start];
}



@end
