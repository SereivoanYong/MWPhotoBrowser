//
//  UIViewTap.h
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MWTapDetectingViewDelegate <NSObject>

@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end

@interface MWTapDetectingView : UIView

@property (nonatomic, weak, nullable) id<MWTapDetectingViewDelegate> tapDelegate;

@end

NS_ASSUME_NONNULL_END
