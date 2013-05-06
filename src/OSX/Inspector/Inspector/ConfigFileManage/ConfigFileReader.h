//
//  ConfigFileReader.h
//  Inspector
//
//  Created by Xinrong Guo on 13-5-5.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigFileReader : NSObject

- (id)initWithInspFolderPath:(NSString *)path;

@property (strong, nonatomic) NSString *inspFolderPath;

@property (readonly, nonatomic) NSImage *normalIcon;
@property (readonly, nonatomic) NSImage *errorIcon;
@property (readonly, nonatomic) NSString *logPath;
@property (readonly, nonatomic) NSString *command;
@property (readonly, nonatomic) NSString *scriptPath;
@property (readonly, nonatomic) BOOL refreshScript;
@property (readonly, nonatomic) NSTimeInterval delay;

@end
