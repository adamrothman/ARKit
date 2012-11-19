//
//  ARTextView.h
//  ARKit
//
//  Created by Adam Rothman on 7/15/12.
//
//  A UITextView that supports placeholder text.
//
//  You must configure the text view's delegate so that textViewDidChange:
//  calls setNeedsDisplay on the text view (to make the placeholder disappear
//  or reappear as appropriate).
//

#import <UIKit/UIKit.h>

@interface ARTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;

@end
