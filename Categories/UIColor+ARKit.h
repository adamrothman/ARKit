//
//  UIColor+ARKit.h
//  ARKit
//
//  Created by Adam Rothman on 4/21/13.
//
//  Make your life a little more colorful.
//

#import <UIKit/UIKit.h>

@interface UIColor (ARKit)

// Create a UIColor from a hexadecimal integer like 0xffffff
+ (UIColor *)colorWithHex:(NSUInteger)hex;

@end
