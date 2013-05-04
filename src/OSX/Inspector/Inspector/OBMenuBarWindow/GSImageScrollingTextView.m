//
//  GSImageScrollingTextView.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-4.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "GSImageScrollingTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "OBMenuBarWindow.h"
#import "FBScrollingTextView.h"
#import "GSImageView.h"

@implementation GSImageScrollingTextView

- (id)initWithMaxTextWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width + 22, 22)];
    if (self) {
//        [self setWantsLayer:YES];
//        [self.layer setBorderWidth:1.0f];
//        [self.layer setBorderColor:[[NSColor greenColor] CGColor]];
        
        self.imageView = [[GSImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [_imageView setImageScaling:NSScaleProportionally];
        [_imageView setImageAlignment:NSImageAlignCenter];
        
        self.scrollingTextView = [[FBScrollingTextView alloc] initWithFrame:CGRectMake(22, 0, width, 22)];
        [_scrollingTextView setFont:[NSFont systemFontOfSize:13.0f]];
//        [_scrollingTextView setString:@"Some long long long text"];
//        [_scrollingTextView setString:@"Some text"];
        [_scrollingTextView setString:@""];
        
        [self setFrame:CGRectMake(0, 0, _scrollingTextView.frame.size.width + 22, 22)];
        
        
        [self addSubview:_imageView];
        [self addSubview:_scrollingTextView];
    }
    return self;
}

#pragma mark - Mouse Event

- (void)mouseDown:(NSEvent *)theEvent {
    if ([self.menuBarWindow isMainWindow] || (self.menuBarWindow.isVisible && self.menuBarWindow.attachedToMenuBar)) {
        [self.menuBarWindow orderOut:self];
    }
    else {
        [NSApp activateIgnoringOtherApps:YES];
        [self.menuBarWindow makeKeyAndOrderFront:self];
        
        if ([self.menuBarWindow.obDelegate respondsToSelector:@selector(obWindowDidAppear:)]) {
            [self.menuBarWindow.obDelegate obWindowDidAppear:self.menuBarWindow];
        }
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    if ([self.menuBarWindow isMainWindow] || (self.menuBarWindow.isVisible && self.menuBarWindow.attachedToMenuBar)) {
        [self.menuBarWindow orderOut:self];
    }
    
    [self.menuBarWindow.statusItem popUpStatusItemMenu:self.menu];
    [self.menu setDelegate:self];
}

#pragma mark setter

- (void)setHighlighted:(BOOL)highlighted {
    [_scrollingTextView setHighlighted:highlighted];
    [_imageView setHighlighted:highlighted];
}

- (void)setText:(NSString *)text {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [_scrollingTextView setString:text];
        [[self animator] setFrame:CGRectMake(0, 0, _scrollingTextView.frame.size.width + 22, 22)];
    } completionHandler:nil];
}

#pragma mark NSMenu delegate

- (void)menuWillOpen:(NSMenu *)menu {
    [self setHighlighted:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    [self setHighlighted:NO];
}

@end
