//
//  MWGridCell.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWGridViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MWGridCell : UICollectionViewCell

@property (nonatomic, weak, nullable) MWGridViewController *gridController;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) id<MWPhoto> photo;
@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (void)displayImage;

@end

NS_ASSUME_NONNULL_END
