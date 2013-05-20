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
#import "NSString+ImageName.h"
#import "INSPLogUtlils.h"

#define INSP_V_APPENDERRORTEXT YES
#define INSP_V_MAXTEXTWIDTH_RATIO 0.10

@interface AppDelegate ()

@property (strong, nonatomic) PreferencesWindowController *preferencesWC;

@property (assign, nonatomic) IBOutlet NSTextView *logTextView;

@property (strong, nonatomic) ConfigFileReader *confFileReader;
@property (strong, nonatomic) ScriptRunner *runner;
@property (strong, nonatomic) LogGetter *logGetter;

@property (assign, nonatomic) int lastStatusCode;
@property (strong, nonatomic) NSString *lastErrorLine;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupVisualRelated];
    [self setupNotifications];
    
    self.logGetter = [[LogGetter alloc] init];
    [_logGetter setDelegate:self];
    
    [self checkArguments];
    
    // [self runTest];
}

- (void)setupVisualRelated {
    // setup status item
    self.window.hasMenuBarIcon = YES;
    self.window.attachedToMenuBar = YES;
    self.window.obDelegate = self;
    
    [[[self statueItemView] imageView] setImage:[NSImage imageNamed:@"MenuBarIcon"]];
    
    // reset max textWidth
    
    [[self statueItemView] setMaxTextWidth:[self mainScreenWidth] * INSP_V_MAXTEXTWIDTH_RATIO];
    
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

- (void)setupNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleScreenParameterChange) name:NSApplicationDidChangeScreenParametersNotification object:nil];
}

#pragma mark - Passing in arguments

- (void)checkArguments {
    NSString *configFolderPath = [self configFolderPathFromArguments];
    
    if (configFolderPath) {
        self.confFileReader = [[ConfigFileReader alloc] initWithInspFolderPath:configFolderPath];
        if (_confFileReader.scriptPath) {
            self.runner = [[ScriptRunner alloc] initWithScriptPath:_confFileReader.scriptPath refresh:_confFileReader.refreshScript];
        }
        else if (_confFileReader.command){
            self.runner = [[ScriptRunner alloc] initWithCommand:_confFileReader.command];
        }
        else {
            return;
        }
        
        [_runner setDelegate:self];
        if (_confFileReader.changeDelayWhenError) {
            [_runner runWithTimeInterval:_confFileReader.normalDelay];
        }
        else {
            [_runner runWithTimeInterval:_confFileReader.delay];
        }
        
        
        [[[self statueItemView] imageView] setImage:_confFileReader.normalIcon];
    }
}

- (NSString *)configFolderPathFromArguments {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    NSDictionary *env = [[NSProcessInfo processInfo] environment];
    
    NSString *file = [args lastObject];
    NSString *pwd = [env objectForKey:@"PWD"];
    
    INSPDLog(@"file:[%@]", file);
    INSPDLog(@"pwd:[%@]", pwd);
    
    // TODO: test only remove later
//    file = @"/Users/ultragtx/DevProjects/Cocoa/Project/inspector/src/test/apollo13.insp";
//    file = @"/Users/ultragtx/Desktop/test.insp";
    
    // Check if is *.insp
    if (file.length > 5) {
        NSRange tailRange = NSMakeRange([file length] - 5, 5);
        INSPDLog(@"%@", NSStringFromRange(tailRange));
        NSRange resultRange = [file rangeOfString:@".insp" options:NSCaseInsensitiveSearch range:tailRange];
        if (resultRange.location != NSNotFound) {
            INSPDLog(@"avaliable insp folder");
            
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

- (CGFloat)mainScreenWidth {
    return [[NSScreen mainScreen] frame].size.width;
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
    if (_lastStatusCode == 0 && [_window isVisible]) {
        [_logGetter startGettinglogContentWithPath:_confFileReader.logPath];
    }
}

- (void)scriptRunner:(ScriptRunner *)runner didFailDownloadingScriptWithError:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

#pragma mark - Setter

- (void)setLastStatusCode:(int)statusCode {
    if (statusCode != 0) {
        // Error
        INSPDLog(@"Get Error");
        [[[self statueItemView] imageView] setImage:[_confFileReader errorIconForcurrentMainScreenResolution]];
        [_logGetter startGettinglogContentWithPath:_confFileReader.logPath];
        if (_confFileReader.changeDelayWhenError) {
            [_runner setTimeInterval:_confFileReader.errorDelay];
        }
    }
    else {
        // Normal
        [[[self statueItemView] imageView] setImage:[_confFileReader normalIconForCurrentMainScreenResolution]];
        if (_lastStatusCode != statusCode) {
            // previous error, set to normal
            [[self statueItemView] setText:nil];
            if (_confFileReader.changeDelayWhenError) {
                [_runner setTimeInterval:_confFileReader.normalDelay];
            }
        }
    }
    _lastStatusCode = statusCode;
}

- (void)setLastErrorLine:(NSString *)errorLine {
    if (![_lastErrorLine isEqualToString:errorLine]) {
        _lastErrorLine = errorLine;
        [[self statueItemView] setText:_lastErrorLine waitForPreviousFinishScrolling:YES];
    }
}

#pragma mark - Notifications

- (void)handleScreenParameterChange {
    // Rest image
    if (_lastStatusCode != 0) {
        // Error
        NSImage *errorIcon = [_confFileReader errorIconForcurrentMainScreenResolution];
        if (errorIcon) {
            [[[self statueItemView] imageView] setImage:errorIcon];
        }
    }
    else {
        // Normal
        NSImage *normalIcon = [_confFileReader normalIconForCurrentMainScreenResolution];
        if (normalIcon) {
            [[[self statueItemView] imageView] setImage:normalIcon];
        }
    }
    
    [[self statueItemView] setMaxTextWidth:[self mainScreenWidth] * INSP_V_MAXTEXTWIDTH_RATIO];
}

#pragma mark - LogGetter delegate

- (void)logGetter:(LogGetter *)logGetter didGetLogContent:(NSString *)content {
    if ([_window isVisible]) {
        [_logTextView setString:content];
        [_logTextView scrollToEndOfDocument:self];
    }
    
    if (_lastStatusCode != 0) {
        // show error
        NSArray *components = [content componentsSeparatedByString:@"\n"];
        NSEnumerator *enumerator = [components reverseObjectEnumerator];
        NSString *lastLine;
        while (lastLine = [enumerator nextObject]) {
            if (lastLine.length > 0) {
                break;
            }
        }
        self.lastErrorLine = lastLine;
    }
}

- (void)logGetter:(LogGetter *)logGetter didFailWithError:(NSError *)error {
//    NSAlert *alert = [NSAlert alertWithError:error];
//    [alert runModal];
    
    // If logfile cannot be reached, show the error in the textView
    // Mostly the reason is the log file has not been created.
    [_logTextView setString:[error description]];
}

#pragma mark - OBMenuBarWindow delegate

- (void)obWindowDidAppear:(OBMenuBarWindow *)window {
    if (_confFileReader) {
        [_logGetter startGettinglogContentWithPath:_confFileReader.logPath];
    }
}

#pragma mark - Terminate

- (void)applicationWillTerminate:(NSNotification *)notification {
    [ScriptRunner clearCache];
}

#pragma mark - For Tests

- (void)runTest {
//    [self testConfigFileReader];
//    [self testScriptRunner];
//    [self testCommandRunner];
    
//    [self performSelector:@selector(stopRunner) withObject:nil afterDelay:10];
//    [self performSelector:@selector(testChangeTextWidth) withObject:nil afterDelay:3];
//    [self performSelector:@selector(testAppendText) withObject:nil afterDelay:3];
//    [self testImageName];
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
    _runner = [[ScriptRunner alloc] initWithCommand:@"curl www.baidu.com"];
    
    [_runner runWithTimeInterval:2];
}

- (void)stopRunner {
    [_runner stop];
}

- (void)testChangeTextWidth {
    [[self statueItemView] setMaxTextWidth:100];
}

- (void)testAppendText {
    [[self statueItemView] setText:@"PPPPPPPPPPPPP OOOOOOOOOO" waitForPreviousFinishScrolling:YES];
}

- (void)testImageName {
    NSLog(@"HighRes: %@", [NSString highResImageNameFromNormalResImageName:@"asdfioj"]);
}



@end
