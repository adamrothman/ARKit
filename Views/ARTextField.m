//
//  ARTextView.m
//  ARKit
//
//  Created by Adam Rothman on 7/15/12.
//
//  A UITextField with padding.
//

#import "ARTextField.h"

@implementation ARTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.origin.x + 7,
                    bounds.origin.y + 6,
                    bounds.size.width - 14,
                    bounds.size.height - 12);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

@end
