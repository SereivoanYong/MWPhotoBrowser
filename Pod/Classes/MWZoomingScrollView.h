//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"

@protocol MWPhoto;
@class MWPhotoBrowser, MWCaptionView;

NS_ASSUME_NONNULL_BEGIN

@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate>

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, nullable) id<MWPhoto> photo;
@property (nonatomic, weak) MWCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;

- (instancetype)initWithPhotoBrowser:(MWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
