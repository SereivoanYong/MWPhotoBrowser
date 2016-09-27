//
//  UIImage+MWPhotoBrowser.h
//  Pods
//
//  Created by Michael Waterfall on 05/07/2015.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MWPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle;
+ (UIImage *)clearImageWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
