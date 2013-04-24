//
//  UIColor+ARKit.h
//  ARKit
//
//  Created by Adam Rothman on 4/21/13.
//
//  Make your life a little more colorful.
//

#import "UIColor+ARKit.h"

@implementation UIColor (ARKit)

+ (UIColor *)colorWithHex:(NSUInteger)hex {
  return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}

@end
