//
//  AppDelegate.h
//  Inspector
//
//  Created by Xinrong Guo on 13-5-3.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScriptRunner.h"
#import "LogGetter.h"
#import "OBMenuBarWindow.h"

@interface AppDelegate : NSObject
<
NSApplicationDelegate,
ScriptRunnerDelegate,
LogGetterDelegate,
OBMenuBarWindowDelegate
>

@property (assign) IBOutlet OBMenuBarWindow *window;

@end
