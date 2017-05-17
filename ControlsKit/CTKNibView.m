//
//  CTKNibView.m
//  ControlsKit
//
//  Created by Stéphane Copin on 12/7/12.
//  Copyright © 2012 Stéphane Copin. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CTKNibView.h"

@interface CTKNibView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (assign, nonatomic) BOOL shouldAwakeFromNib;

@end

@implementation CTKNibView
@synthesize contentView = _contentView;

- (id)init {
  self = [super init];
  if (self) {
    self.shouldAwakeFromNib = YES;
    [self createFromNib];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.shouldAwakeFromNib = YES;
    [self createFromNib];
  }
  return self;
}

- (NSString *)nibName {
  NSString * baseName = NSStringFromClass([self class]);
  NSRange rangeOfDot = [baseName rangeOfString:@"."];
  return rangeOfDot.location == NSNotFound ? baseName : [baseName substringFromIndex:rangeOfDot.location + 1];
}

- (NSBundle *)nibBundle {
  return [NSBundle bundleForClass:[self class]];
}

- (UINib *)nib {
  return [UINib nibWithNibName:self.nibName bundle:self.nibBundle];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.shouldAwakeFromNib = NO;
  [self createFromNib];
}

- (void)createFromNib {
  if (self.contentView == nil) {
    [[self nib] instantiateWithOwner:self options:nil];
    // IF your code crashes here (Above or below), you probably forgot to link contentView in IB
    NSAssert(self.contentView != nil, @"contentView is nil. Did you forgot to link it in IB?");
    if (self.shouldAwakeFromNib) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
      [self awakeFromNib];
#pragma clang diagnostic pop
    }
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentView];
    
    NSLayoutConstraint * leadingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint * trailingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    NSLayoutConstraint * bottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    
    [self addConstraints:@[leadingConstraint, topConstraint, trailingConstraint, bottomConstraint]];
  }
}

@end
