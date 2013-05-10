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

@property (assign, nonatomic) OBMenuBarWindow *menuBarWindow;
@property (assign, nonatomic) BOOL highlighted;
@property (assign, nonatomic) CGFloat maxTextWidth;

- (id)initWithMaxTextWidth:(CGFloat)width;

- (void)setText:(NSString *)text;
- (void)setText:(NSString *)text waitForPreviousFinishScrolling:(BOOL)shouldWait;

@end
