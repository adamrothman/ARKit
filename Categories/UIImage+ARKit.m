//
//  UIImage+ARKit.m
//  ARKit
//
//  Created by Adam Rothman on 3/11/13.
//
//  Borrowed and condensed from http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/
//

#import "UIImage+ARKit.h"

@implementation UIImage (ARKit)

// Returns true if the image has an alpha layer
- (BOOL)hasAlpha {
  CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
  return (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha {
  if ([self hasAlpha]) {
    return self;
  }
  CGImageRef imageRef = self.CGImage;
  size_t width = CGImageGetWidth(imageRef);
  size_t height = CGImageGetHeight(imageRef);
  // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
  CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height, 8, 0, CGImageGetColorSpace(imageRef), kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
  // Draw the image into the context and retrieve the new image, which will now have an alpha layer
  CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
  CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
  UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
  // Clean up
  CGContextRelease(offscreenContext);
  CGImageRelease(imageRefWithAlpha);
  return imageWithAlpha;
}

// Returns a copy of the image with a transparent border of the given size added around its edges.
// If the image has no alpha layer, one will be added to it.
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize {
  // If the image does not have an alpha layer, add one
  UIImage *image = [self imageWithAlpha];
  CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
  // Build a context that's the same dimensions as the new size
  CGContextRef bitmap = CGBitmapContextCreate(NULL, newRect.size.width, newRect.size.height, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
  // Draw the image in the center of the context, leaving a gap around the edges
  CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
  CGContextDrawImage(bitmap, imageLocation, self.CGImage);
  CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
  // Create a mask to make the border transparent, and combine it with the image
  CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
  CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
  UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
  // Clean up
  CGContextRelease(bitmap);
  CGImageRelease(borderImageRef);
  CGImageRelease(maskImageRef);
  CGImageRelease(transparentBorderImageRef);
  return transparentBorderImage;
}

// Creates a mask that makes the outer edges transparent and everything else opaque
// The size must include the entire mask (opaque part + transparent border)
// The caller is responsible for releasing the returned reference by calling CGImageRelease
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
  // Build a context that's the same dimensions as the new size
  CGContextRef maskContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaNone);
  // Start with a mask that's entirely transparent
  CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
  CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
  // Make the inner part (within the border) opaque
  CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
  CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
  // Get an image of the context
  CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
  // Clean up
  CGContextRelease(maskContext);
  CGColorSpaceRelease(colorSpace);
  return maskImageRef;
}

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize transparentBorder:(NSUInteger)borderSize cornerRadius:(NSUInteger)cornerRadius interpolationQuality:(CGInterpolationQuality)quality {
  UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(thumbnailSize, thumbnailSize) interpolationQuality:quality];
  // Crop out any part of the image that's larger than the thumbnail size
  // The cropped rect must be centered on the resized image
  // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
  CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2), round((resizedImage.size.height - thumbnailSize) / 2), thumbnailSize, thumbnailSize);
  UIImage *croppedImage = [resizedImage croppedImage:cropRect];
  UIImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize] : croppedImage;
  
  return [transparentBorderImage roundedCornerImage:cornerRadius borderSize:borderSize];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
  BOOL drawTransposed;
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      drawTransposed = YES;
      break;
    default:
      drawTransposed = NO;
  }
  return [self resizedImage:newSize transform:[self transformForOrientation:newSize] drawTransposed:drawTransposed interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality {
  CGFloat horizontalRatio = bounds.width / self.size.width;
  CGFloat verticalRatio = bounds.height / self.size.height;
  CGFloat ratio;
  switch (contentMode) {
    case UIViewContentModeScaleAspectFill:
      ratio = MAX(horizontalRatio, verticalRatio);
      break;
    case UIViewContentModeScaleAspectFit:
      ratio = MIN(horizontalRatio, verticalRatio);
      break;
    default:
      [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
  }
  return [self resizedImage:CGSizeMake(self.size.width * ratio, self.size.height * ratio) interpolationQuality:quality];
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize transform:(CGAffineTransform)transform drawTransposed:(BOOL)transpose interpolationQuality:(CGInterpolationQuality)quality {
  CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
  CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
  CGImageRef imageRef = self.CGImage;
  // Build a context that's the same dimensions as the new size
  CGContextRef bitmap = CGBitmapContextCreate(NULL, newRect.size.width, newRect.size.height, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
  // Rotate and/or flip the image if required by its orientation
  CGContextConcatCTM(bitmap, transform);
  // Set the quality level to use when rescaling
  CGContextSetInterpolationQuality(bitmap, quality);
  // Draw into the context; this scales the image
  CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
  // Get the resized image from the context and a UIImage
  CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
  UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
  // Clean up
  CGContextRelease(bitmap);
  CGImageRelease(newImageRef);
  return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
  CGAffineTransform transform = CGAffineTransformIdentity;
  switch (self.imageOrientation) {
    case UIImageOrientationDown:           // EXIF = 3
    case UIImageOrientationDownMirrored:   // EXIF = 4
      transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
    case UIImageOrientationLeft:           // EXIF = 6
    case UIImageOrientationLeftMirrored:   // EXIF = 5
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
    case UIImageOrientationRight:          // EXIF = 8
    case UIImageOrientationRightMirrored:  // EXIF = 7
      transform = CGAffineTransformTranslate(transform, 0, newSize.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
  }
  switch (self.imageOrientation) {
    case UIImageOrientationUpMirrored:     // EXIF = 2
    case UIImageOrientationDownMirrored:   // EXIF = 4
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    case UIImageOrientationLeftMirrored:   // EXIF = 5
    case UIImageOrientationRightMirrored:  // EXIF = 7
      transform = CGAffineTransformTranslate(transform, newSize.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
  }
  return transform;
}

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
  // If the image does not have an alpha layer, add one
  UIImage *image = [self imageWithAlpha];
  // Build a context that's the same dimensions as the new size
  CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), CGImageGetBitmapInfo(image.CGImage));
  // Create a clipping path with rounded corners
  CGContextBeginPath(context);
  [self addRoundedRectToPath:CGRectMake(borderSize, borderSize, image.size.width - borderSize * 2, image.size.height - borderSize * 2) context:context ovalWidth:cornerSize ovalHeight:cornerSize];
  CGContextClosePath(context);
  CGContextClip(context);
  // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
  CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
  // Create a CGImage from the context
  CGImageRef clippedImage = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  // Create a UIImage from the CGImage
  UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
  CGImageRelease(clippedImage);
  return roundedImage;
}

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
  if (ovalWidth == 0 || ovalHeight == 0) {
    CGContextAddRect(context, rect);
    return;
  }
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGContextScaleCTM(context, ovalWidth, ovalHeight);
  CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
  CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
  CGContextMoveToPoint(context, fw, fh / 2);
  CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1);
  CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1);
  CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1);
  CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1);
  CGContextClosePath(context);
  CGContextRestoreGState(context);
}

@end
