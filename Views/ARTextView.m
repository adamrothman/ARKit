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

- (void)setPlaceholder:(NSString *)placeholder {
  _placeholder = [placeholder copy];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];

  // Draw placeholder if set and no text
  if (self.placeholder && !self.text.length) {
    CGRect placeholderRect;
    placeholderRect.origin = CGPointMake(8, 8);
    placeholderRect.size = [self.placeholder sizeWithFont:self.font constrainedToSize:CGSizeMake(self.bounds.size.width - 16, self.bounds.size.height - 16)];

    [[UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1] set];
    [self.placeholder drawInRect:placeholderRect withFont:self.font];
  }
}

@end
