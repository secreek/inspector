//
//  GSImageScrollingTextView.h
//  Inspector
//
//  Created by Xinrong Guo on 13-5-4.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GSImageView.h"

@class FBScrollingTextView;
@class OBMenuBarWindow;
@class GSImageView;

@interface GSImageScrollingTextView : NSView
<
NSMenuDelegate
>

@property (strong, nonatomic) FBScrollingTextView *scrollingTextView;
@property (strong, nonatomic) GSImageView *imageView;

@property (weak, nonatomic) OBMenuBarWindow *menuBarWindow;
@property (assign, nonatomic) BOOL highlighted;

- (id)initWithTextWidth:(CGFloat)width;

@end
