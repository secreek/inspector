//
//  FBScrollingTextView.m
//  FBScrollingTextView
//
//  Created by Fábio Bernardo on 2/6/11.
//

#import "FBScrollingTextView.h"
#import <QuartzCore/QuartzCore.h>

#define kFBScrollingTextViewSpacing 0.7

#define kFBScrollingTextViewDefaultScrollingSpeed 2
#define kFBScrollingTextViewStartScrollingDelay 0.3

#define kCursorYOffset 2.0f

@interface FBScrollingTextView ()

@property (strong, nonatomic) NSFont *font;

@property (strong, nonatomic) NSString *nextString;

// Status for scrolling

@property (assign, nonatomic) BOOL prevScrollEnd;

@end

@implementation FBScrollingTextView
@synthesize scrollingSpeed;
@synthesize string;
@synthesize font;

- (void)scrollText {	
	cursor.x-=1;
	[self setNeedsDisplay:YES];
}

- (void)startScrolling {
	if (!tickTockScroll) {		
		tickTockScroll = [NSTimer scheduledTimerWithTimeInterval:refreshRate/scrollingSpeed target:self selector:@selector(scrollText) userInfo:nil repeats:YES];
	}
	tickTockStartScrolling = nil;
}

- (void)stopScrolling {
    [tickTockScroll invalidate];
    tickTockScroll = nil;
}

- (CGFloat)stringWidth {
	if (!string) return 0;
	NSSize stringSize = [string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil]];
	return stringSize.width;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
//        [self setWantsLayer:YES];
//        [self.layer setBorderWidth:1.0f];
//        [self.layer setBorderColor:CGColorCreateGenericRGB(0.0f, 1.0f, 0.0f, 1.0f)];
        
        // Initialization code.			
		scrollingSpeed = kFBScrollingTextViewDefaultScrollingSpeed;
		refreshRate = 0.05;
		cursor = NSMakePoint(0, kCursorYOffset);
		self.font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
        self.maxWidth = frame.size.width;
    }
    return self;
}


- (void)setString:(NSString *)_string {
	if (tickTockScroll) {
		[tickTockScroll invalidate];
		tickTockScroll = nil;
	}
	if (tickTockStartScrolling) {
		[tickTockStartScrolling invalidate];
		tickTockStartScrolling = nil;
	}
	
	cursor = NSMakePoint(0, kCursorYOffset);
	string = _string;
    self.nextString = string;
//	CGRect thisFrame = [super frame];
    CGFloat stringWidth = [self stringWidth];
	if (stringWidth > _maxWidth) {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, _maxWidth, self.frame.size.height)];
		if (!tickTockStartScrolling) {
			tickTockStartScrolling = [NSTimer scheduledTimerWithTimeInterval:kFBScrollingTextViewStartScrollingDelay target:self selector:@selector(startScrolling) userInfo:nil repeats:NO];
		}
	}
    else {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, stringWidth, self.frame.size.height)];
    }
	[self setNeedsDisplay:YES];
}

- (void)setString:(NSString *)newString waitForPreviousFinishScrolling:(BOOL)shouldWait {
    if (shouldWait) {
        // Discussion:
        // When string A is current scrolling string, stirng B came and string C comes
        // Choose 1 to ignore string B, show string C after string A finish scroling
        // Choose 2 to combine string B and C, show the combined string after string A finish scrolling
        
        /************ 1 *************/
        self.nextString = newString;
        
        /************ 2 *************/
        /*if (string == _nextString) {
            self.nextString = newString;
        }
        else {
            self.nextString = [NSString stringWithFormat:@"%@ %@", _nextString, newString];
        }*/
        
        if (tickTockScroll == nil) {
            self.string = _nextString;
        }
    }
    else {
        self.string = _nextString;
    }
}

- (void)setMaxWidth:(CGFloat)maxWidth {
    _maxWidth = maxWidth;
    [self setString:string];
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    // Drawing code.
    
    if (_highlighted) {
//        NSLog(@"%@", [NSColor selectedMenuItemColor]);
        [[NSColor selectedMenuItemColor] set];
        NSRectFill([self bounds]);
    }
    
	CGFloat sWidth = round([self stringWidth]);	
	CGFloat rWidth = round(rect.size.width);
	CGFloat spacing = round(rWidth*kFBScrollingTextViewSpacing);
	
	if ((cursor.x*-1) == sWidth) {
        // A full circle of scroll
		CGFloat diff = spacing - (sWidth+cursor.x);
		cursor.x = rWidth-diff;
        string = _nextString;
	}
    
    NSColor *fontColor = _highlighted ? [NSColor whiteColor] : [NSColor blackColor];
    
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, fontColor, NSForegroundColorAttributeName, nil];
    
	[string drawAtPoint:cursor withAttributes:attrs];
	
	CGFloat diff = spacing - (sWidth+cursor.x);	
	if (diff >= 0) {
		NSPoint point = NSMakePoint(rWidth-diff, cursor.y);
		[_nextString drawAtPoint:point withAttributes:attrs];
	}
}


- (void)dealloc {
	[tickTockScroll invalidate];
	tickTockScroll = nil;
	[tickTockStartScrolling invalidate];
	tickTockStartScrolling = nil;
}


@end
