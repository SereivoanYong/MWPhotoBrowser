//
//  UIViewTap.m
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import "MWTapDetectingView.h"

@implementation MWTapDetectingView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
	if (self) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = touch.tapCount;
	switch (tapCount) {
		case 1:
			[self handleSingleTap:touch];
			break;
		case 2:
			[self handleDoubleTap:touch];
			break;
		case 3:
			[self handleTripleTap:touch];
			break;
		default:
			break;
	}
	[self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
  if ([_tapDelegate respondsToSelector:@selector(view:singleTapDetected:)]) {
		[_tapDelegate view:self singleTapDetected:touch];
  }
}

- (void)handleDoubleTap:(UITouch *)touch {
  if ([_tapDelegate respondsToSelector:@selector(view:doubleTapDetected:)]) {
		[_tapDelegate view:self doubleTapDetected:touch];
  }
}

- (void)handleTripleTap:(UITouch *)touch {
  if ([_tapDelegate respondsToSelector:@selector(view:tripleTapDetected:)]) {
		[_tapDelegate view:self tripleTapDetected:touch];
  }
}

@end
