//
//  InspectorTests.m
//  InspectorTests
//
//  Created by Xinrong Guo on 13-5-20.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "InspectorTests.h"
#import "ConfigFileReader.h"
#import "AppDelegate.h"

@implementation InspectorTests {
    BOOL _scriptFinishRunning;
    BOOL _logFinishGetting;
}

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testConfigFileReaderScript {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"script.insp" ofType:nil];
    NSLog(@"%@", path);
    ConfigFileReader *configFileReader = [[ConfigFileReader alloc] initWithInspFolderPath:path];
    STAssertEquals(configFileReader.normalDelay, 10.0, @"normal-delay mismatch");
    STAssertEquals(configFileReader.errorDelay, 1.0, @"error-delay mismatch");
    STAssertEquals(configFileReader.delay, 0.0, @"delay mismatch");
    STAssertEquals(configFileReader.changeDelayWhenError, YES, @"changeDelayWhenError mismatch");
    STAssertNotNil(configFileReader.scriptPath, @"script path mismatch");
    STAssertNil(configFileReader.command, @"command mismatch");
    STAssertEquals(configFileReader.refreshScript, YES, @"refresh script mismatch");
    STAssertNotNil(configFileReader.logPath, @"log path mismatch");

}

- (void)testConfigFileReaderCommand {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"command.insp" ofType:nil];
    NSLog(@"%@", path);
    ConfigFileReader *configFileReader = [[ConfigFileReader alloc] initWithInspFolderPath:path];
    STAssertEquals(configFileReader.normalDelay, 0.0, @"normal-delay mismatch");
    STAssertEquals(configFileReader.errorDelay, 0.0, @"error-delay mismatch");
    STAssertEquals(configFileReader.delay, 10.0, @"delay mismatch");
    STAssertEquals(configFileReader.changeDelayWhenError, NO, @"changeDelayWhenError mismatch");
    STAssertNil(configFileReader.scriptPath, @"script path mismatch");
    STAssertNotNil(configFileReader.command, @"command mismatch");
    STAssertEquals(configFileReader.refreshScript, NO, @"refresh script mismatch");
    STAssertNotNil(configFileReader.logPath, @"log path mismatch");
}

- (void)testScriptRunnerScript {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"script" ofType:@"sh"];
    ScriptRunner *runner = [[ScriptRunner alloc] initWithScriptPath:path refresh:YES];
    [runner setDelegate:self];
    [runner runWithTimeInterval:1.0];
    
    while (!_scriptFinishRunning) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    _scriptFinishRunning = NO;
}

- (void)testScriptRunnerCommand {
    NSString *command = @"echo 'Fake Result'";
    ScriptRunner *runner = [[ScriptRunner alloc] initWithCommand:command];
    [runner setDelegate:self];
    [runner runWithTimeInterval:1.0];
    
    while (!_scriptFinishRunning) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    _scriptFinishRunning = NO;
}

- (void)testLogGetter {
    LogGetter *logGetter = [[LogGetter alloc] init];
    [logGetter setDelegate:self];
    [logGetter startGettinglogContentWithPath:@"/tmp/FakeLog.log"];
    
    while (!_logFinishGetting) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    _logFinishGetting = NO;
}

- (void)testCommandLine {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    
    NSString *file;
    file = @"/Users/ultragtx/DevProjects/Cocoa/Project/inspector/src/test/apollo13.insp";
    //    file = @"/Users/ultragtx/Desktop/test.insp";
    
    NSString *command = [NSString stringWithFormat:@"insp %@", file];
    
    NSArray *args = [NSArray arrayWithObjects:@"-l", @"-c", command, nil];
    [task setArguments:args];
    
    [task launch];
//    [task waitUntilExit];
//    [task terminate];
}

#pragma mark - Delegate

- (void)scriptRunner:(ScriptRunner *)runner didGetScriptContent:(NSString *)content {
    STAssertTrue([content isEqualToString:@"#!/bin/bash\ndate -u >> /tmp/FakeLog.log;echo 'Fake Result';"], @"Script content mismatch");
}

- (void)scriptRunner:(ScriptRunner *)runner didFinishExecutionWithStatusCode:(int)statusCode result:(NSString *)result {
    STAssertTrue(statusCode == 0, @"script execute code mismatch");
    STAssertTrue([result isEqualToString:@"Fake Result\n"], @"script execute result mismatch");
    _scriptFinishRunning = YES;
}

- (void)scriptRunner:(ScriptRunner *)runner didFailDownloadingScriptWithError:(NSError *)error {
    STFail(@"ScriptRunner didFailWithError %@", [error localizedDescription]);
}

- (void)logGetter:(LogGetter *)logGetter didGetLogContent:(NSString *)content {
    NSArray *comps = [content componentsSeparatedByString:@"\n"];
    STAssertTrue([comps count] > 0, @"log content mismatch");
    _logFinishGetting = YES;
}

- (void)logGetter:(LogGetter *)logGetter didFailWithError:(NSError *)error {
    STFail(@"LogGetter didFailWithError %@", [error localizedDescription]);
}

@end
