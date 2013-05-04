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

- (id)initWithTextWidth:(CGFloat)width {
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
        [_scrollingTextView setString:@"Some long long long text"];
        
        [self addSubview:_imageView];
        [self addSubview:_scrollingTextView];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
//    self.highlighted = YES;
    if ([self.menuBarWindow isMainWindow] || (self.menuBarWindow.isVisible && self.menuBarWindow.attachedToMenuBar))
    {
        [self.menuBarWindow orderOut:self];
    }
    else
    {
        [NSApp activateIgnoringOtherApps:YES];
        [self.menuBarWindow makeKeyAndOrderFront:self];
        
        if ([self.menuBarWindow.obDelegate respondsToSelector:@selector(obWindowDidAppear:)]) {
            [self.menuBarWindow.obDelegate obWindowDidAppear:self.menuBarWindow];
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
//    self.highlighted = NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    [_scrollingTextView setHighlighted:highlighted];
    [_imageView setHighlighted:highlighted];
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    // Drawing code here.
//}

@end
