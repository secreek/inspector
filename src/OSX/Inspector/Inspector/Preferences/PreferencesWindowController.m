//
//  PreferencesWindowController.m
//  
//
//  Created by Xinrong Guo on 13-5-8.
//
//

#import "PreferencesWindowController.h"
#import <InstantMessage/IMService.h>
#import "INSPLogUtlils.h"

#define STR_STATUS_NOT_INSTALLED @"Shell support not installed"
#define STR_STATUS_INSTALLED @"Shell support installed"

#define STR_BUTTON_NOT_INSTALLED @"Install"
#define STR_BUTTON_INSTALLED @"Uninstall"

#define STR_SHELLSUPPORT_PATH @"/usr/local/bin/insp"

@interface PreferencesWindowController ()

@property (assign, nonatomic) IBOutlet NSButton *installButton;
@property (assign, nonatomic) IBOutlet NSTextField *installStatusLabel;
@property (assign, nonatomic) IBOutlet NSImageView *statusIndicator;

@property (assign, nonatomic) BOOL installed;

@end

@implementation PreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self setupView];
}

#pragma mark - Shell Support

- (void)setupView {
    [self checkStatus];
}

- (void)setInstalled:(BOOL)installed {
    if (installed) {
        [_statusIndicator setImage:[NSImage imageNamed:[IMService imageNameForStatus:IMPersonStatusAvailable]]];
        [_installStatusLabel setStringValue:STR_STATUS_INSTALLED];
        [_installButton setTitle:STR_BUTTON_INSTALLED];
    }
    else {
        [_statusIndicator setImage:[NSImage imageNamed:[IMService imageNameForStatus:IMPersonStatusAway]]];
        [_installStatusLabel setStringValue:STR_STATUS_NOT_INSTALLED];
        [_installButton setTitle:STR_BUTTON_NOT_INSTALLED];
    }
    _installed = installed;
}

- (void)checkStatus {
    NSFileManager *manager = [NSFileManager defaultManager];
    self.installed = [manager fileExistsAtPath:STR_SHELLSUPPORT_PATH];
}

- (IBAction)installButtonClicked:(id)sender {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    NSString *script;
    
    if (_installed) {
        script = [NSString stringWithFormat:@"rm %@", STR_SHELLSUPPORT_PATH];
    }
    else {
        NSArray *execBinaryPath = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
//        script = [NSString stringWithFormat:@"", execBinaryPath, STR_SHELLSUPPORT_PATH];
        
        script = [NSString stringWithFormat:@"printf \"#! /bin/bash \\n%@ \\$1 &\" > %@", execBinaryPath, STR_SHELLSUPPORT_PATH];
        INSPDLog(@"%@", script);
        
    }
    
    NSArray *args = [NSArray arrayWithObjects:@"-l", @"-c", script, nil];
    [task setArguments:args];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];
    NSData *data = [file readDataToEndOfFile];
    NSString *execResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([task terminationStatus] != 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error install shell support" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:execResult];
        [alert runModal];
    }
    else {
        if (!_installed) {
            NSNumber *permissions = [NSNumber numberWithUnsignedLong: 493];
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:permissions forKey:NSFilePosixPermissions];
            NSError *error;
            [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:STR_SHELLSUPPORT_PATH  error:&error];
            if (error) {
                INSPALog(@"%@", [error description]);
                NSAlert *alert = [NSAlert alertWithMessageText:@"Error install shell support" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:[error localizedDescription]];
                [alert runModal];
            }
        }
        self.installed = !_installed;
    }
}



@end
