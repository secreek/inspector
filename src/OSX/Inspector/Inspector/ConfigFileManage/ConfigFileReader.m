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

@interface ConfigFileReader ()

@property (strong, nonatomic) NSFileManager *fileManager;

@property (strong, nonatomic) NSDictionary *configDict;

@property (strong, nonatomic) NSImage *normalIcon;
@property (strong, nonatomic) NSImage *errorIcon;
@property (strong, nonatomic) NSString *logPath;
@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSString *scriptPath;
@property (assign, nonatomic) BOOL refreshScript;
@property (assign, nonatomic) NSTimeInterval delay;

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
    
    NSString *iconNormalPath = [NSString stringWithFormat:@"%@/%@", _inspFolderPath, [_configDict objectForKey:@"icon-normal"]];
    NSString *iconErrorPath = [NSString stringWithFormat:@"%@/%@", _inspFolderPath, [_configDict objectForKey:@"icon-error"]];
    
    self.normalIcon = [[NSImage alloc] initWithContentsOfFile:iconNormalPath];
    self.errorIcon = [[NSImage alloc] initWithContentsOfFile:iconErrorPath];
    
    if (!_normalIcon) {
        INSPALog(@"[WARNING]: Normal icon not found, use deafault!");
    }

    if (!_errorIcon) {
        INSPALog(@"[WARNING]: Error icon not found, use deafault!");
    }
    
    // Log path
    self.logPath = [_configDict objectForKey:@"log"];
    if (!_logPath) {
        INSPALog(@"[ERROR]: Log path not found.");
    }
    
    // Script && Command
    
    self.scriptPath = [_configDict objectForKey:@"script"];
    
    if (!_scriptPath || [_scriptPath length] == 0) {
        self.command = [_configDict objectForKey:@"command"];
        if (!_command) {
            INSPALog(@"[ERROR]: Script/Comman not found.")
        }
    }
    else {
        NSString *refreshStr= [_configDict objectForKey:@"refresh-script"];
        if (refreshStr && [refreshStr caseInsensitiveCompare:@"true"] == NSOrderedSame) {
            self.refreshScript = YES;
        }
        else {
            self.refreshScript = NO;
        }
    }
    
    self.delay = [[_configDict objectForKey:@"delay"] floatValue];
    
}



@end
