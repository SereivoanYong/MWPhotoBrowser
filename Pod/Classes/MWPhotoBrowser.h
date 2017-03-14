//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif

@class MWPhotoBrowser;

NS_ASSUME_NONNULL_BEGIN

@protocol MWPhotoBrowserDelegate <NSObject>

@required
- (NSInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSInteger)index;

@optional
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSInteger)index;
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSInteger)index;
- (nullable NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSInteger)index selectedDidChange:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;

@end

@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak, nullable) IBOutlet id<MWPhotoBrowserDelegate> delegate;

/// Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
@property (nonatomic, assign) BOOL zoomsPhotosToFill;

/// Whether to display left and right nav arrows on toolbar (defaults to NO)
@property (nonatomic, assign) BOOL displaysNavArrows;

/// Show action button to allow sharing, copying, etc (defaults to YES)
@property (nonatomic, assign) BOOL displaysActionButton;

/// Whether selection buttons are shown on each image (defaults to NO)
@property (nonatomic, assign) BOOL displaysSelectionButtons;

/// Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
@property (nonatomic, assign) BOOL alwaysShowsControls;

/// Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
@property (nonatomic, assign, getter=isGridEnabled) BOOL gridEnabled;
@property (nonatomic, assign, getter=isSwipeToDismissEnabled) BOOL swipeToDismissEnabled;

/// Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
@property (nonatomic, assign) BOOL startsOnGrid;

/// Auto-play first video
@property (nonatomic, assign) BOOL automaticallyPlaysOnAppear;


@property (nonatomic, assign) NSTimeInterval delayToHideElements;
@property (nonatomic, assign, readonly) NSUInteger currentIndex;

// Customise image selection icons as they are the only icons with a colour tint
// Icon should be located in the app's main bundle
@property (nonatomic, strong, nullable) NSString *customImageSelectedIconName;
@property (nonatomic, strong, nullable) NSString *customImageSelectedSmallIconName;

// Init
- (instancetype)initWithPhotos:(NSArray<id<MWPhoto>> *)photos;
- (instancetype)initWithDelegate:(nullable id<MWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
