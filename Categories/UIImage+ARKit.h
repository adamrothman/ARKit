//
//  UIImage+ARKit.h
//  ARKit
//
//  Created by Adam Rothman on 3/11/13.
//  Copyright (c) 2013 Adam Rothman. All rights reserved.
//
//  Borrowed and condensed from http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/
//

#import <UIKit/UIKit.h>

@interface UIImage (ARKit)

- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize transparentBorder:(NSUInteger)borderSize cornerRadius:(NSUInteger)cornerRadius interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;

@end
