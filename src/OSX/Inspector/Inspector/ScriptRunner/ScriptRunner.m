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
//@property (assign, nonatomic) NSTimeInterval timeInterval;

@property (assign, nonatomic) BOOL isRunning;
@property (assign, nonatomic) NSTimeInterval lastExecuteTime;
@property (strong, nonatomic) NSURL *cachedScriptFileURL;

@property (weak, nonatomic) AFHTTPRequestOperation *lastOperation;

@end

@implementation ScriptRunner {
    dispatch_queue_t _excuteQueue;
}

- (id)initWithScriptPath:(NSString *)path refresh:(BOOL)refresh {
    self = [super init];
    if (self) {
        _type = ScriptRunnerType_Script;
        
        _refreshScript = refresh;
        
        if ([path rangeOfString:@"://"].location == NSNotFound) {
            _scriptURL = [NSURL fileURLWithPath:path];
        }
        else {
            _scriptURL = [NSURL URLWithString:path];
        }
        
        _scriptFileName = _scriptURL.lastPathComponent;
        
        INSPDLog(@"--%@", _scriptURL);
        INSPDLog(@"--%@", _scriptFileName);
        
        [self commonInitialize];
    }
    return self;
}

- (id)initWithCommand:(NSString *)command {
    self = [super init];
    if (self) {
        _type = ScriptRunnerType_Command;
        
        _command = command;
        
        [self commonInitialize];
    }
    return self;
}

- (void)commonInitialize {
    // create dispatch queue
    _excuteQueue = dispatch_queue_create("ExecuteQueue", NULL);
}

#pragma mark - Control

- (void)prepare {
    if (_type == ScriptRunnerType_Script) {
        [self downloadScript];
    }
    else {
        [self asyncExecute];
    }
}

- (void)runWithTimeInterval:(NSTimeInterval) timeInterval {
    self.timeInterval = timeInterval;
    self.isRunning = YES;
    
    [self prepare];   
}

- (void)stop {
    self.isRunning = NO;
}

#pragma mark - Async Execute

- (void)asyncExecute {
    if (_isRunning) {
        if (_timeInterval == 0) {
            _isRunning = NO; // stop next if _timeInterval is 0
        }
        
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval interval = currentTime - self.lastExecuteTime;
        NSTimeInterval sleepTime = 0.0;
        if (interval < _timeInterval) {
            sleepTime =  MIN(_timeInterval - interval, _timeInterval);
        }
        
        if (_type == ScriptRunnerType_Script) {
            dispatch_async(_excuteQueue, ^{
                [NSThread sleepForTimeInterval:sleepTime];
                INSPDLog(@"$$Running---");
                [self runScript];
                self.lastExecuteTime = [[NSDate date] timeIntervalSince1970];
                INSPDLog(@"$$Finish----");
                [self asyncExecute];
            });
        }
        else {
            dispatch_async(_excuteQueue, ^{
                [NSThread sleepForTimeInterval:sleepTime];
                INSPDLog(@"$$Running---");
                [self runCommand];
                self.lastExecuteTime = [[NSDate date] timeIntervalSince1970];
                INSPDLog(@"$$Finish----");
                [self asyncExecute];
            });
        }
    }
}

#pragma mark - Script
// Run on spread thread
- (void)runScript {
    if (_refreshScript || _cachedScriptFileURL == nil) {
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
        self.cachedScriptFileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%.0lf_%d_%@", currentTime, randNum, _scriptFileName] relativeToURL:appCacheDirURL];
        
        INSPDLog(@"%@", [_cachedScriptFileURL absoluteString]);
        
        // Save file content
        BOOL success = NO;
        if ([manager createDirectoryAtURL:appCacheDirURL withIntermediateDirectories:YES attributes:nil error:&error]) {
            success = [_scriptContent writeToURL:_cachedScriptFileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                INSPALog(@"%@", [error description]);
            }
        }
        
        // Set excutable
        if (success) {
            NSNumber *permissions = [NSNumber numberWithUnsignedLong: 493];
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:permissions forKey:NSFilePosixPermissions];
            // This actually sets the permissions
            success = [manager setAttributes:attributes ofItemAtPath:[_cachedScriptFileURL path]  error:&error];
            if (error) {
                INSPALog(@"%@", [error description]);
            }
        }
    }
    
    // Run
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[_cachedScriptFileURL path]];
//    NSTask *task = [[NSTask alloc] init];
//    [task setLaunchPath:@"/bin/bash"];
    
    NSArray *args = [NSArray arrayWithObjects:@"-l", @"-c", [NSString stringWithFormat:@"sh %@", [_cachedScriptFileURL path]], nil];
    [task setArguments:args];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];
    NSData *data = [file readDataToEndOfFile];
    NSString *execResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    INSPDLog(@"Execresult: \n[%@]", execResult);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(scriptRunner:didFinishExecutionWithStatusCode:result:)]) {
            [_delegate scriptRunner:self didFinishExecutionWithStatusCode:[task terminationStatus] result:execResult];
        }
    });
}

- (void)downloadScript {
    if (_refreshScript || _scriptContent.length == 0) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_scriptURL];
        
        if (self.lastOperation) {
            // cancle last to prevent old request arrive later than new request
            INSPDLog(@"cancle last");
            [_lastOperation cancel];
        }
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        self.lastOperation = operation;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.scriptContent = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
            INSPDLog(@"%@", _scriptContent);
            if ([_delegate respondsToSelector:@selector(scriptRunner:didGetScriptContent:)]) {
                [_delegate scriptRunner:self didGetScriptContent:_scriptContent];
            }
            
            [self asyncExecute];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            INSPALog(@"%@", [error localizedDescription]);
            [_delegate scriptRunner:self didFailDownloadingScriptWithError:error];
            
        }];
        [operation start];
    } else {
        [self asyncExecute];
    }
}

#pragma mark - Command
// Run on spread thread
- (void)runCommand {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    NSArray *args = [NSArray arrayWithObjects:@"-l", @"-c", _command, nil];
    [task setArguments:args];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];
    NSData *data = [file readDataToEndOfFile];
    NSString *execResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    INSPDLog(@"Execresult: \n[%@]", execResult);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(scriptRunner:didFinishExecutionWithStatusCode:result:)]) {
            [_delegate scriptRunner:self didFinishExecutionWithStatusCode:[task terminationStatus] result:execResult];
        }
    });
}

#pragma mark - Class Method

+ (void)clearCache {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSURL *cacheDirURL = [manager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *appCacheDirURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Script/", appID] relativeToURL:cacheDirURL];
    
    
    NSArray *contents = [manager contentsOfDirectoryAtURL:appCacheDirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    if (error) {
        INSPALog(@"%@", [error description]);
    }
    else {
        for (NSURL *fileURL in contents) {
            [manager removeItemAtURL:fileURL error:&error];
        }
    }
    
}

@end
