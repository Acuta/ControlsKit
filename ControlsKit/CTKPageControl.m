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
    UIImage * imageToUse;
    BOOL isActive = i == self.currentPage;
    if (self.numberOfPages == 1) {
      imageToUse = self.middleDotImageActive;
    } else if (i == 0) {
      imageToUse = isActive ? self.leftDotImageActive : self.leftDotImageInactive;
    } else if (i == self.numberOfPages - 1) {
      imageToUse = isActive ? self.rightDotImageActive : self.rightDotImageInactive;
    } else {
      imageToUse = isActive ? self.middleDotImageActive : self.middleDotImageInactive;
    }

    UIView *view;
    if (imageToUse != nil) {
      view = [[UIImageView alloc] initWithImage:imageToUse];
    } else {
      view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.dotsSize.width, self.dotsSize.height)];
      view.backgroundColor = isActive ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
      view.layer.cornerRadius = MIN(view.bounds.size.width, view.bounds.size.height) / 2.0f;
      view.layer.masksToBounds = YES;
    }

    view.frame = CGRectMake([self xOriginForDotAtIndex:i], (self.frame.size.height - view.frame.size.height) / 2.0f, view.frame.size.width, view.frame.size.height);
    [self addSubview:view];
    [self.dotsArray addObject:view];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDot:)]];
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

- (void)didTapDot:(UITapGestureRecognizer *)tapGestureRecognizer {
  NSInteger dotIndex = [self.dotsArray indexOfObject:tapGestureRecognizer.view];
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

#pragma mark - Calculate Sizes

- (CGSize)leftDotSize {
  if (self.currentPage == 0) {
    if (self.leftDotImageActive != nil) {
      return self.leftDotImageActive.size;
    } else {
      return self.dotsSize;
    }
  } else {
    if (self.leftDotImageInactive != nil) {
      return self.leftDotImageInactive.size;
    } else {
      return self.dotsSize;
    }
  }
}

- (CGSize)rightDotSize {
  if (self.currentPage == self.numberOfPages - 1) {
    if (self.rightDotImageActive != nil) {
      return self.rightDotImageActive.size;
    } else {
      return self.dotsSize;
    }
  } else if (self.rightDotImageInactive != nil) {
    return self.rightDotImageInactive.size;
  } else {
    return self.dotsSize;
  }
}

- (CGSize)middleDotSizeSelected:(BOOL)selected {
  if (selected) {
    if (self.middleDotImageActive != nil) {
      return self.middleDotImageActive.size;
    } else {
      return self.dotsSize;
    }
  } else  if (self.middleDotImageInactive != nil) {
    return self.middleDotImageInactive.size;
  } else {
    return self.dotsSize;
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
  if (numberOfPages == 0 || (numberOfPages == 1 && self.hidesForSinglePage)) {
    return 0.0f;
  } else if (numberOfPages == 1) {
    return [self middleDotSizeSelected:YES].width;
  }
  return [self leftDotSize].width + self.dotsSpace * 2.0 + [self middleDotsSectionWidthForNumberOfPages:numberOfPages] + [self rightDotSize].width;
}

- (CGFloat)maxHeightForNumberOfPages:(NSInteger)numberOfPages {
  CGFloat maxHeight = 0.0f;

  if (numberOfPages == 0 || (numberOfPages == 1 && self.hidesForSinglePage)) {
    maxHeight = 0.0f;
  } else if (numberOfPages == 1) {
    maxHeight = [self middleDotSizeSelected:YES].height;
  } else {
    maxHeight = fmax([self rightDotSize].height, [self leftDotSize].height);
    if (numberOfPages > 2) {
      maxHeight = fmax(maxHeight, fmax([self middleDotSizeSelected:YES].height, [self middleDotSizeSelected:NO].height));
    }
  }
  return maxHeight;
}

#pragma mark - Calculate x origin for dots

- (CGFloat)xOriginForDotAtIndex:(NSInteger)dotIndex {
  if (dotIndex < 0 || dotIndex > self.numberOfPages - 1) {
    return NAN;
  }

  CGFloat sectionWidth = (self.frame.size.width - self.sizeForDotSection.width) / 2.0f;

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
