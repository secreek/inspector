//
//  ConfigFileReader.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-5.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "ConfigFileReader.h"
#import "INSPLogUtlils.h"
#import "NSDictionary+IZM_JSONSupport.h"
#import "NSString+ImageName.h"

@interface ConfigFileReader ()

@property (strong, nonatomic) NSFileManager *fileManager;

@property (strong, nonatomic) NSDictionary *configDict;

@property (strong, nonatomic) NSImage *normalIcon;
@property (strong, nonatomic) NSImage *errorIcon;
@property (strong, nonatomic) NSImage *normalIcon2x;
@property (strong, nonatomic) NSImage *errorIcon2x;
@property (strong, nonatomic) NSString *logPath;
@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSString *scriptPath;
@property (assign, nonatomic) BOOL refreshScript;
@property (assign, nonatomic) NSTimeInterval delay;
@property (assign, nonatomic) NSTimeInterval normalDelay;
@property (assign, nonatomic) NSTimeInterval errorDelay;
@property (assign, nonatomic) BOOL changeDelayWhenError;

@end

@implementation ConfigFileReader

- (id)initWithInspFolderPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.fileManager = [[NSFileManager alloc] init];
        
        self.inspFolderPath = path;
    }
    return self;
}

- (void)setInspFolderPath:(NSString *)inspFolderPath {
    _inspFolderPath = inspFolderPath;
    
    NSError *error;
    
    // NSArray *inspContents = [_fileManager contentsOfDirectoryAtPath:inspFolderPath error:&error];
    // NSLog(@"%@", [inspContents description]);
    
    if (error) {
        INSPALog(@"%@", [error description]);
    }
    
    NSString *configFilePath = [NSString stringWithFormat:@"%@/config.json", _inspFolderPath];
    NSLog(@"%@", configFilePath);
    
    self.configDict = [NSDictionary izm_dictionaryWithContentsOfJSONFilePath:configFilePath];
    
    NSLog(@"%@", [_configDict description]);
    
    // Images
    
    NSString *iconNormalFileName = [_configDict objectForKey:@"icon-normal"];
    NSString *iconErrorFileName = [_configDict objectForKey:@"icon-error"];
    
    NSString *iconNormalPath = [NSString stringWithFormat:@"%@/%@", _inspFolderPath, iconNormalFileName];
    NSString *iconErrorPath = [NSString stringWithFormat:@"%@/%@", _inspFolderPath, iconErrorFileName];
    
    self.normalIcon = [[NSImage alloc] initWithContentsOfFile:iconNormalPath];
    self.errorIcon = [[NSImage alloc] initWithContentsOfFile:iconErrorPath];
    
    if (!_normalIcon) {
        INSPALog(@"[WARNING]: Normal icon not found, use deafault!");
    }
    
    if (!_errorIcon) {
        INSPALog(@"[WARNING]: Error icon not found, use deafault!");
    }
    
    // Images2x
    
    NSString *iconNormal2xFileName = [NSString highResImageNameFromNormalResImageName:iconNormalFileName];
    NSString *iconError2xFileName = [NSString highResImageNameFromNormalResImageName:iconErrorFileName];
    NSString *iconNormal2xPath = [NSString stringWithFormat:@"%@/%@", _inspFolderPath, iconNormal2xFileName];
    NSString *iconError2xPath = [NSString stringWithFormat:@"%@/%@", _inspFolderPath, iconError2xFileName];
    
    self.normalIcon2x = [[NSImage alloc] initWithContentsOfFile:iconNormal2xPath];
    self.errorIcon2x = [[NSImage alloc] initWithContentsOfFile:iconError2xPath];
    
    // Log path
    self.logPath = [_configDict objectForKey:@"log"];
    if (!_logPath) {
        INSPALog(@"[ERROR]: Log path not found.");
    }
    
    // Script && Command
    
    self.scriptPath = [_configDict objectForKey:@"script"];
    
    if (!_scriptPath || [_scriptPath length] == 0) {
        // Command
        self.command = [_configDict objectForKey:@"command"];
        if (!_command) {
            INSPALog(@"[ERROR]: Script/Comman not found.")
        }
    }
    else {
        // Script
        if ([_scriptPath characterAtIndex:0] != '/') {
            self.scriptPath = [NSString stringWithFormat:@"%@/%@", inspFolderPath, _scriptPath];
        }
        
        NSString *refreshStr= [_configDict objectForKey:@"refresh-script"];
        if (refreshStr && [refreshStr caseInsensitiveCompare:@"true"] == NSOrderedSame) {
            self.refreshScript = YES;
        }
        else {
            self.refreshScript = NO;
        }
    }
    
    if ([_configDict objectForKey:@"normal-delay"]) {
        self.normalDelay = [[_configDict objectForKey:@"normal-delay"] floatValue];
        self.errorDelay = [[_configDict objectForKey:@"error-delay"] floatValue];
        self.changeDelayWhenError = YES;
    }
    else {
        self.delay = [[_configDict objectForKey:@"delay"] floatValue];
        self.changeDelayWhenError = NO;
    }
}

@end

@implementation ConfigFileReader (HighResSupport)

- (NSImage *)normalIconForCurrentMainScreenResolution {
    float factor = [[NSScreen mainScreen] backingScaleFactor];
    if (factor > 1 && _normalIcon2x) {
        return _normalIcon2x;
    }
    return _normalIcon;
}

- (NSImage *)errorIconForcurrentMainScreenResolution {
    float factor = [[NSScreen mainScreen] backingScaleFactor];
    if (factor > 1 && _errorIcon2x) {
        return _errorIcon2x;
    }
    return _errorIcon;
}

@end
