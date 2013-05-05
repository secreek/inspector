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

@interface AppDelegate ()

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
    
    [self testConfigFileReader];
}

#pragma mark - ConfigFileReader test

- (void)testConfigFileReader {
    ConfigFileReader *reader = [[ConfigFileReader alloc] initWithInspFolderPath:@"/Users/ultragtx/Desktop/test.insp"];
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

@end
