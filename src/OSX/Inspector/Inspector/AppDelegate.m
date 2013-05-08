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
#import "PreferencesWindowController.h"

@interface AppDelegate ()

@property (strong, nonatomic) PreferencesWindowController *preferencesWC;

@property (assign, nonatomic) IBOutlet NSTextView *logTextView;

@property (strong, nonatomic) ConfigFileReader *confFileReader;
@property (strong, nonatomic) ScriptRunner *runner;
@property (strong, nonatomic) LogGetter *logGetter;

@property (assign, nonatomic) int lastStatusCode;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupVisualRelated];
    
    self.logGetter = [[LogGetter alloc] init];
    [_logGetter setDelegate:self];
    
    [self checkArguments];
    
//    [self runTest];
}

- (void)setupVisualRelated {
    // setup status item
    self.window.hasMenuBarIcon = YES;
    self.window.attachedToMenuBar = YES;
    self.window.obDelegate = self;
    
    [[[self statueItemView] imageView] setImage:[NSImage imageNamed:@"MenuBarIcon"]];
    
    [[self statueItemView] setHighlighted:YES];
    
    // setup menu
    NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"StatusMenu"];
    NSMenuItem *settingsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..." action:@selector(menuSettings) keyEquivalent:@""];
    
    [statusMenu addItem:settingsMenuItem];
    [statusMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About Inspector" action:@selector(menuAbout) keyEquivalent:@""];
    [statusMenu addItem:aboutMenuItem];
    
    [statusMenu addItemWithTitle:@"Quit" action:@selector(menuQuit) keyEquivalent:@""];
    
    [[self statueItemView] setMenu:statusMenu];
    
    // setup preferences window controller
    self.preferencesWC = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];

}

#pragma mark - Passing in arguments

- (void)checkArguments {
    NSString *configFolderPath = [self configFolderPathFromArguments];
    
    if (configFolderPath) {
        self.confFileReader = [[ConfigFileReader alloc] initWithInspFolderPath:configFolderPath];
        self.runner = [[ScriptRunner alloc] initWithScriptPath:_confFileReader.scriptPath refresh:_confFileReader.refreshScript];
        [_runner setDelegate:self];
        [_runner runWithTimeInterval:_confFileReader.delay];
        
        [[[self statueItemView] imageView] setImage:_confFileReader.normalIcon];
    }
}

- (NSString *)configFolderPathFromArguments {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    NSDictionary *env = [[NSProcessInfo processInfo] environment];
    
    NSString *file = [args lastObject];
    NSString *pwd = [env objectForKey:@"PWD"];
    
    NSLog(@"file:[%@]", file);
    NSLog(@"pwd:[%@]", pwd);
    
    // TODO: test only remove later
//    file = @"/Users/ultragtx/DevProjects/Cocoa/Project/inspector/src/test/apollo13.insp";
//    file = @"/Users/ultragtx/Desktop/test.insp";
    
    // Check if is *.insp
    if (file.length > 5) {
        NSRange tailRange = NSMakeRange([file length] - 5, 5);
        NSLog(@"%@", NSStringFromRange(tailRange));
        NSRange resultRange = [file rangeOfString:@".insp" options:NSCaseInsensitiveSearch range:tailRange];
        if (resultRange.location != NSNotFound) {
            NSLog(@"avaliable insp folder");
            
            NSString *fullPath;
            if ([file characterAtIndex:0] == '/') {
                // Full path
                fullPath = file;
            }
            else {
                // Relatvie path
                fullPath = [NSString stringWithFormat:@"%@/%@", pwd, file];
            }
            
            return fullPath;
        }
    }
    
    return nil;
}

#pragma mark - helper

- (GSImageScrollingTextView *)statueItemView {
    return self.window.statusItemView;
}

#pragma mark - Menu

- (void)menuSettings {
    [_preferencesWC showWindow:self];
}

- (void)menuAbout {
    [[self statueItemView] setText:@""];
}

- (void)menuQuit {
//    [[self statueItemView] setText:@"Some text"];
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - ScriptRunner delegate

- (void)scriptRunner:(ScriptRunner *)runner didFinishExecutionWithStatusCode:(int)statusCode result:(NSString *)result {
    self.lastStatusCode = statusCode;
    if (_lastStatusCode != 0) {
        // Error
        NSLog(@"Get Error");
        [[[self statueItemView] imageView] setImage:_confFileReader.errorIcon];
        [_logGetter startGettinglogContentWithPath:_confFileReader.logPath];
        
    }
    else {
        // OK
        [[[self statueItemView] imageView] setImage:_confFileReader.normalIcon];
    }

}

- (void)scriptRunner:(ScriptRunner *)runner didFailDownloadingScriptWithError:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

#pragma mark - LogGetter delegate

- (void)logGetter:(LogGetter *)logGetter didGetLogContent:(NSString *)content {
    if ([_window isVisible]) {
        [_logTextView setString:content];
        [_logTextView scrollToEndOfDocument:self];
    }
    
    if (_lastStatusCode != 0) {
        // show error
        [[self statueItemView] setText:[[content componentsSeparatedByString:@"\n"] lastObject]];
    }
}

- (void)logGetter:(LogGetter *)logGetter didFailWithError:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

#pragma mark - OBMenuBarWindow delegate

- (void)obWindowDidAppear:(OBMenuBarWindow *)window {
    if (_confFileReader) {
        [_logGetter startGettinglogContentWithPath:_confFileReader.logPath];
    }
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
