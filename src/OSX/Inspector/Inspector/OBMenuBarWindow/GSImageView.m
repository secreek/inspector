//
//  GSImageView.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-4.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "GSImageView.h"

@implementation GSImageView

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_highlighted) {
        [[NSColor selectedMenuItemColor] set];
        NSRectFill([self bounds]);
    }
    
    [super drawRect:dirtyRect];
}

@end
