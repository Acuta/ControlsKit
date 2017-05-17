//
//  CTKPageControl.m
//  ControlsKit
//
//  Created by Bastien Falcou on 1/9/15.
//  Copyright © 2015 Bastien Falcou. All rights reserved.
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

#import "CTKPageControl.h"

const CGSize kCTKPageControlDefaultSize = {7.0f, 7.0f};

#define kPageControlDotsOriginalWidth 7.0f
#define kPageControlDotsOriginalHeight 7.0f
#define kPageControlDotsOriginalSpace 6.0f
#define kUndefinedFloatValue INFINITY
#define kDefaultCurrentPageTintColor [UIColor whiteColor]
#define kDefaultPageTintColor [[UIColor whiteColor] colorWithAlphaComponent:0.5f]

@interface CTKPageControl ()

/**
 *  Size for dots section (from the first to the last one)
 */
@property (nonatomic, assign) CGSize sizeForDotSection;

/**
 *  Array of dots sorted from left to right
 */
@property (nonatomic, strong) NSMutableArray<__kindof UIView *> *dotsArray;

@end

@implementation CTKPageControl

- (instancetype)init {
  if (self = [super init]) {
    [self setUp];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self setUp];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setUp];
  }
  return self;
}

- (void)setUp {
  _dotsArray = [[NSMutableArray alloc] init];
  _dotsSpace = kPageControlDotsOriginalSpace;
  _pageIndicatorTintColor = kDefaultPageTintColor;
  _currentPageIndicatorTintColor = kDefaultCurrentPageTintColor;
  _defersCurrentPageDisplay = NO;
  _hidesForSinglePage = NO;
  _dotsSize = kCTKPageControlDefaultSize;
  [self updateDots];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateDots];
}

- (void)updateDots {
  [self forceUpdateDots:NO];
}

- (void)forceUpdateDots:(BOOL)forced {
  if (self.defersCurrentPageDisplay && forced == NO) {
    return;
  }

  // Remove previous subviews.
  for (UIView *subView in self.dotsArray) {
    [subView removeFromSuperview];
  }
  [self.dotsArray removeAllObjects];

  [self updateSizeForDotSection];
  for (NSInteger i = 0; i < [self numberOfDotsToDisplay]; i++) {
    CGSize dotSize = CGSizeMake(kUndefinedFloatValue, kUndefinedFloatValue);

    // Update dot size.
    if (self.numberOfPages == 1 && self.middleDotImageActive) {
      dotSize = self.middleDotImageActive.size;
    } else {
      if (i == self.currentPage) {
        if (i == 0 && self.leftDotImageActive) {
          dotSize = self.leftDotImageActive.size;
        } else if (i == self.numberOfPages - 1 && self.rightDotImageActive) {
          dotSize = self.rightDotImageActive.size;
        } else if (self.middleDotImageActive) {
          dotSize = self.middleDotImageActive.size;
        }
      } else {
        if (i == 0 && self.leftDotImageInactive) {
          dotSize = self.leftDotImageInactive.size;
        } else if (i == self.numberOfPages - 1 && self.rightDotImageInactive) {
          dotSize = self.rightDotImageInactive.size;
        } else if (self.middleDotImageInactive) {
          dotSize = self.middleDotImageInactive.size;
        }
      }
    }

    // Update dot if needed (if custom size has been set).
    if (dotSize.width != kUndefinedFloatValue) {
      UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake([self xOriginForDotAtIndex:i], (self.frame.size.height - dotSize.height) / 2.0f, dotSize.width, dotSize.height)];
      view.backgroundColor = [UIColor clearColor];

      // Assign new image.
      if (self.numberOfPages == 1) {
        view.image = self.middleDotImageActive;
      } else {
        if (i == self.currentPage) {
          if (i == 0) {
            view.image = self.leftDotImageActive;
          } else if (i == self.numberOfPages - 1) {
            view.image = self.rightDotImageActive;
          } else {
            view.image = self.middleDotImageActive;
          }
        } else {
          if (i == 0) {
            view.image = self.leftDotImageInactive;
          } else if (i == self.numberOfPages - 1) {
            view.image = self.rightDotImageInactive;
          } else {
            view.image = self.middleDotImageInactive;
          }
        }
      }
      [self addSubview:view];
      [self.dotsArray addObject:view];
      [self setupGestureRecognizerForView:view];
    } else {
      UIView *view = [[UIView alloc] initWithFrame:CGRectMake([self xOriginForDotAtIndex:i], (self.frame.size.height - self.dotsSize.height) / 2.0f, self.dotsSize.width, self.dotsSize.height)];
      view.backgroundColor = i == self.currentPage ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
      view.layer.cornerRadius = MIN(view.bounds.size.width, view.bounds.size.height) / 2.0f;
      view.layer.masksToBounds = YES;

      [self addSubview:view];
      [self.dotsArray addObject:view];
      [self setupGestureRecognizerForView:view];
    }
  }
  [self invalidateIntrinsicContentSize];
}

- (void)updateSizeForDotSection {
  self.sizeForDotSection = CGSizeMake([self totalWidthForNumberOfPages:self.numberOfPages], [self maxHeightForNumberOfPages:self.numberOfPages]);
}

- (void)updateCurrentPageDisplay {
  [self forceUpdateDots:YES];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
  return CGSizeMake([self totalWidthForNumberOfPages:pageCount], [self maxHeightForNumberOfPages:pageCount]);
}

- (void)didTapDot:(id)sender {
  if (![sender isKindOfClass:[UITapGestureRecognizer class]]) {
    return;
  }

  NSInteger dotIndex = [self.dotsArray indexOfObject:[(UITapGestureRecognizer *)sender view]];
  if (dotIndex != self.currentPage) {
    self.currentPage = dotIndex;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

#pragma mark - Helper Methods

- (NSInteger)numberOfDotsToDisplay {
  if (self.numberOfPages == 1) {
    return self.hidesForSinglePage ? 0 : 1;
  }

  return self.numberOfPages;
}

- (void)setupGestureRecognizerForView:(UIView *)view {
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDot:)];
  [view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - Calculate Sizes

- (CGSize)leftDotSize {
  if (self.currentPage == 0) {
    if (self.leftDotImageActive) {
      return self.leftDotImageActive.size;
    } else {
      return self.dotsSize;
    }
  } else {
    if (self.leftDotImageInactive) {
      return self.leftDotImageInactive.size;
    } else {
      return self.dotsSize;
    }
  }
}

- (CGSize)rightDotSize {
  if (self.currentPage == self.numberOfPages - 1) {
    if (self.rightDotImageActive) {
      return self.rightDotImageActive.size;
    } else {
      return self.dotsSize;
    }
  } else {
    if (self.rightDotImageInactive) {
      return self.rightDotImageInactive.size;
    } else {
      return self.dotsSize;
    }
  }
}

- (CGSize)middleDotSizeSelected:(BOOL)selected {
  if (selected) {
    if (self.middleDotImageActive) {
      return self.middleDotImageActive.size;
    } else {
      return self.dotsSize;
    }
  } else {
    if (self.middleDotImageInactive) {
      return self.middleDotImageInactive.size;
    } else {
      return self.dotsSize;
    }
  }
}

- (CGFloat)middleDotsSectionWidthForNumberOfPages:(NSInteger)numberOfPages {
  CGFloat sectionWidth = 0.0f;

  if (self.currentPage != 0 && self.currentPage < numberOfPages - 1) {
    sectionWidth += [self middleDotSizeSelected:YES].width;
    sectionWidth += (numberOfPages - 3) * [self middleDotSizeSelected:NO].width;
  } else {
    sectionWidth += (numberOfPages - 2) * [self middleDotSizeSelected:NO].width;
  }

  sectionWidth += self.dotsSpace * (numberOfPages - 3);
  return sectionWidth;
}

- (CGFloat)totalWidthForNumberOfPages:(NSInteger)numberOfPages {
  if (numberOfPages == 0) {
    return 0.0f;
  } else if (numberOfPages == 1) {
    return self.hidesForSinglePage ? 0.0f : [self middleDotSizeSelected:YES].width;
  } else if (numberOfPages == 2) {
    return [self leftDotSize].width + self.dotsSpace + [self rightDotSize].width;
  } else {
    return [self leftDotSize].width + self.dotsSpace + [self middleDotsSectionWidthForNumberOfPages:numberOfPages] + self.dotsSpace + [self rightDotSize].width;
  }
}

- (CGFloat)maxHeightForNumberOfPages:(NSInteger)numberOfPages {
  CGFloat maxHeight = 0.0f;

  if (numberOfPages == 0) {
    maxHeight = 0.0f;
  } else if (numberOfPages == 1) {
    maxHeight = self.hidesForSinglePage ? 0.0f : [self middleDotSizeSelected:YES].height;
  } else if (numberOfPages == 2) {
    maxHeight = fmax([self rightDotSize].height, [self leftDotSize].height);
  } else {
    maxHeight = fmax(fmax([self rightDotSize].height, [self leftDotSize].height),fmax([self middleDotSizeSelected:YES].height, [self middleDotSizeSelected:NO].height));
  }
  return maxHeight;
}

#pragma mark - Calculate x origin for dots

- (CGFloat)xOriginFirstDot {
  return (self.frame.size.width - self.sizeForDotSection.width) / 2.0f;
}

- (CGFloat)xOriginForDotAtIndex:(NSInteger)dotIndex {
  if (dotIndex < 0 || dotIndex > self.numberOfPages - 1) {
    return kUndefinedFloatValue;
  }

  CGFloat sectionWidth = [self xOriginFirstDot];

  if (self.currentPage != 0 && self.currentPage < dotIndex) {
    sectionWidth += [self middleDotSizeSelected:YES].width;
    sectionWidth += (dotIndex - 1) * [self middleDotSizeSelected:NO].width;
  } else {
    sectionWidth += dotIndex * [self middleDotSizeSelected:NO].width;
  }

  sectionWidth += self.dotsSpace * dotIndex;
  return sectionWidth;
}

#pragma mark - UIView overriden methods

- (void)sizeToFit {
  CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
  self.bounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
}

- (CGSize)intrinsicContentSize {
  return [self sizeForNumberOfPages:self.numberOfPages];
}

#pragma mark - Custom setters

- (void)setNumberOfPages:(NSInteger)numberOfPages {
  if (numberOfPages < 0) {
    _numberOfPages = 0;
  }

  _numberOfPages = numberOfPages;
  if (numberOfPages <= self.currentPage && self.currentPage > 0) {
    self.currentPage = numberOfPages - 1;
  }

  [self updateDots];
}

- (void)setCurrentPage:(NSInteger)page {
  if (page <= 0) {
    _currentPage = 0;
  } else if (page >= self.numberOfPages) {
    _currentPage = self.numberOfPages - 1;
  } else {
    _currentPage = page;
  }
  [self updateDots];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
  _pageIndicatorTintColor = pageIndicatorTintColor ? pageIndicatorTintColor : kDefaultPageTintColor;
  [self updateDots];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
  _currentPageIndicatorTintColor = currentPageIndicatorTintColor ? currentPageIndicatorTintColor : kDefaultCurrentPageTintColor;
  [self updateDots];
}

- (void)setDotsSpace:(CGFloat)dotsGauge {
  _dotsSpace = dotsGauge;
  [self updateDots];
}

- (void)setDotsSize:(CGSize)dotsSize {
  _dotsSize = dotsSize;
  [self updateDots];
}

- (void)setLeftDotImageActive:(UIImage *)leftDotImageActive {
  _leftDotImageActive = leftDotImageActive;
  [self updateDots];
}

- (void)setMiddleDotImageActive:(UIImage *)middleDotImageActive {
  _middleDotImageActive = middleDotImageActive;
  [self updateDots];
}

- (void)setRightDotImageActive:(UIImage *)rightDotImageActive {
  _rightDotImageActive = rightDotImageActive;
  [self updateDots];
}

- (void)setLeftDotImageInactive:(UIImage *)leftDotImageInactive {
  _leftDotImageInactive = leftDotImageInactive;
  [self updateDots];
}

- (void)setMiddleDotImageInactive:(UIImage *)middleDotImageInactive {
  _middleDotImageInactive = middleDotImageInactive;
  [self updateDots];
}

- (void)setRightDotImageInactive:(UIImage *)rightDotImageInactive {
  _rightDotImageInactive = rightDotImageInactive;
  [self updateDots];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
  _hidesForSinglePage = hidesForSinglePage;
  [self updateDots];
}

@end
