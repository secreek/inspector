//
//  InspectorTests.m
//  InspectorTests
//
//  Created by Xinrong Guo on 13-5-20.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "InspectorTests.h"
#import "ConfigFileReader.h"

@implementation InspectorTests

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
    STAssertEquals(configFileReader.normalDelay, 10.0, @"normal-delay");
    STAssertEquals(configFileReader.errorDelay, 1.0, @"error-delay");
    STAssertEquals(configFileReader.delay, 0.0, @"delay");
    STAssertEquals(configFileReader.changeDelayWhenError, YES, @"changeDelayWhenError");
    STAssertNotNil(configFileReader.scriptPath, @"script path");
    STAssertNil(configFileReader.command, @"command");
    STAssertEquals(configFileReader.refreshScript, YES, @"refresh script");
    STAssertNotNil(configFileReader.logPath, @"log path");

}

- (void)testConfigFileReaderCommand {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"command.insp" ofType:nil];
    NSLog(@"%@", path);
    ConfigFileReader *configFileReader = [[ConfigFileReader alloc] initWithInspFolderPath:path];
    STAssertEquals(configFileReader.normalDelay, 0.0, @"normal-delay");
    STAssertEquals(configFileReader.errorDelay, 0.0, @"error-delay");
    STAssertEquals(configFileReader.delay, 10.0, @"delay");
    STAssertEquals(configFileReader.changeDelayWhenError, NO, @"changeDelayWhenError");
    STAssertNil(configFileReader.scriptPath, @"script path");
    STAssertNotNil(configFileReader.command, @"command");
    STAssertEquals(configFileReader.refreshScript, NO, @"refresh script");
    STAssertNotNil(configFileReader.logPath, @"log path");
}

- (void)testScriptRunnerScript {
    
}

- (void)testScriptRunnerCommand {
    
}

@end
