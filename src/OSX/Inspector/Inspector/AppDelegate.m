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

@interface AppDelegate ()

@property (strong, nonatomic) GSImageScrollingTextView *imageScrollingTextView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.hasMenuBarIcon = YES;
    self.window.attachedToMenuBar = YES;
    [self.window.statusItemView.imageView setImage:[NSImage imageNamed:@"MenuBarIcon"]];
    
    [self.window.statusItemView setHighlighted:YES];
    
    NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"StatusMenu"];
    NSMenuItem *settingsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..." action:@selector(menuSettings) keyEquivalent:@""];
    
    [statusMenu addItem:settingsMenuItem];
    [statusMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About Inspector" action:@selector(menuAbout) keyEquivalent:@""];
    [statusMenu addItem:aboutMenuItem];
    

    [statusMenu addItemWithTitle:@"Quit" action:@selector(menuQuit) keyEquivalent:@""];
    
    [self.window.statusItemView setMenu:statusMenu];
}

- (void)menuSettings {
    
}

- (void)menuAbout {
    
}

- (void)menuQuit {
    
}

@end
