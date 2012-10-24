//
//  ARTextView.m
//  ARKit
//
//  Created by Adam Rothman on 7/15/12.
//
//  A UITextView that supports placeholder text.
//

#import "ARTextView.h"

@implementation ARTextView

@synthesize placeholderText=_placeholderText;

- (void)setPlaceholderText:(NSString *)placeholderText {
  _placeholderText = placeholderText;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];

  // Draw placeholder if set and no text
  if (self.placeholderText && !self.text.length) {
    CGRect placeholderRect;
    placeholderRect.origin = CGPointMake(8, 8);
    placeholderRect.size = [self.placeholderText sizeWithFont:self.font
                                            constrainedToSize:CGSizeMake(self.bounds.size.width - 16, self.bounds.size.height - 16)];

    [[UIColor colorWithRed:179.0/255.0
                     green:179.0/255.0
                      blue:179.0/255.0
                     alpha:1] set];
    [self.placeholderText drawInRect:placeholderRect
                            withFont:self.font];
  }
}

@end
