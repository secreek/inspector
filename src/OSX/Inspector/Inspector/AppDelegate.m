//
//  AppDelegate.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-3.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "AppDelegate.h"
#import "GSImageScrollingTextView.h"
#import "OBMenuBarWindow.h"
#import "ConfigFileReader.h"
#import "ScriptRunner.h"

@interface AppDelegate ()

@property (strong, nonatomic) ScriptRunner *runner;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.hasMenuBarIcon = YES;
    self.window.attachedToMenuBar = YES;
    
    [[[self statueItemView] imageView] setImage:[NSImage imageNamed:@"MenuBarIcon"]];
    
    [[self statueItemView] setHighlighted:YES];
    
    NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"StatusMenu"];
    NSMenuItem *settingsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..." action:@selector(menuSettings) keyEquivalent:@""];
    
    [statusMenu addItem:settingsMenuItem];
    [statusMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About Inspector" action:@selector(menuAbout) keyEquivalent:@""];
    [statusMenu addItem:aboutMenuItem];
    
    [statusMenu addItemWithTitle:@"Quit" action:@selector(menuQuit) keyEquivalent:@""];
    
    [[self statueItemView] setMenu:statusMenu];
    
    [self runTest];
}

#pragma mark - helper

- (GSImageScrollingTextView *)statueItemView {
    return self.window.statusItemView;
}

#pragma mark - Menu

- (void)menuSettings {
    [[self statueItemView] setText:@"Lorem lorem lorem lorem lorem."];
}

- (void)menuAbout {
    [[self statueItemView] setText:@""];
}

- (void)menuQuit {
    [[self statueItemView] setText:@"Some text"];
}

#pragma mark - For Tests

- (void)runTest {
    [self testConfigFileReader];
    [self testScriptRunner];
    //    [self testCommandRunner];
    
    [self performSelector:@selector(stopRunner) withObject:nil afterDelay:10];
}

- (void)testConfigFileReader {
    ConfigFileReader *reader = [[ConfigFileReader alloc] initWithInspFolderPath:@"/Users/ultragtx/Desktop/test.insp"];
    [reader normalIcon];
}

- (void)testScriptRunner {
    _runner = [[ScriptRunner alloc] initWithScriptPath:@"/Users/ultragtx/Desktop/test.insp/test.sh" refresh:NO];
    
    //    ScriptRunner *runner = [[ScriptRunner alloc] initWithScriptPath:@"http://example.org/run.sh" refresh:NO];
    
    [_runner runWithTimeInterval:2];
}

- (void)testCommandRunner {
    _runner = [[ScriptRunner alloc] initWithCommand:@"ls -a"];
    
    [_runner runWithTimeInterval:2];
}

- (void)stopRunner {
    [_runner stop];
}

@end
