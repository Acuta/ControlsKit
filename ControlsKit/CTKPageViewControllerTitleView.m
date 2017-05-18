//
//  CTKPageViewControllerTitleView.m
//  EthanolUIComponents
//
//  Created by Stephane Copin on 8/12/15.
//  Copyright © 2015 Stéphane Copin. All rights reserved.
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

#import "CTKPageViewControllerTitleView.h"
#import "CTKPageViewControllerTitleView+Private.h"

@interface CTKPageViewControllerTitleView ()

@property (nonatomic, assign) CGFloat currentPosition;
@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, strong) IBOutlet UIScrollView *compactTitlesScrollView;
@property (nonatomic, strong) IBOutlet UIView *regularTitlesContainer;
@property (nonatomic, strong) IBOutlet UIImageView *placeholderImageView;
@property (nonatomic, strong) IBOutlet UIView *regularPageControlContainer;
@property (nonatomic, strong) IBOutlet UIView *compactTitleView;
@property (nonatomic, strong) IBOutlet UIView *regularTitleView;
@property (nonatomic, weak) UIView *regularMaxWidthTitleView;
@property (nonatomic, weak) NSLayoutConstraint *regularPageControlContainerCenterXConstraint;
@property (nonatomic, assign) UIUserInterfaceSizeClass currentTitleViewSizeClass;
@property (nonatomic, assign) UIUserInterfaceSizeClass currentEffectiveSizeClass;
@property (nonatomic, assign) CGSize previousSize;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *compactPageControlCenterYConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *compactPageControlLeftConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *regularPageControlCenterYConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *regularPageControlLeftConstraint;

@end

@implementation CTKPageViewControllerTitleView

- (void)awakeFromNib {
  [super awakeFromNib];

  self.compactPageControlOffset = UIOffsetMake(0.0f, -3.0f);
  self.regularPageControlOffset = UIOffsetMake(0.0f, -3.0f);
  self.regularMinimumTitleAlpha = 0.7f;
  self.regularTitleViewSpacing = 20.0f;

  self.currentTitleViewSizeClass = UIUserInterfaceSizeClassUnspecified;
  [self generateTitleViewForSizeClass:self.traitCollection.horizontalSizeClass];
  [self updateTitleViewSizeClassAnimated:NO];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  // HACK: The navigation bar is changing the title view's bounds in a weird way when starting an app in landscape,
  // and then rotating to portrait mode.
  // This fixes the title's view frame and recenter it properly.

  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
  self.center = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));

  UIUserInterfaceSizeClass sizeClass = self.currentEffectiveSizeClass;
  if (sizeClass == UIUserInterfaceSizeClassUnspecified) {
    sizeClass = self.traitCollection.horizontalSizeClass;
  }
  [self generateTitleViewForSizeClass:sizeClass];

  [self updateTitleViewSizeClassAnimated:NO];
  [self updateTitleViewPosition];
}

- (void)generateTitleView {
  [self generateTitleViewForSizeClass:self.traitCollection.horizontalSizeClass force:YES];
  [self updateTitleViewSizeClassAnimated:YES];
}

- (void)generateTitleViewForSizeClass:(UIUserInterfaceSizeClass)sizeClass {
  return [self generateTitleViewForSizeClass:sizeClass force:NO];
}

- (void)generateTitleViewForSizeClass:(UIUserInterfaceSizeClass)sizeClass force:(BOOL)force {
  if (sizeClass == UIUserInterfaceSizeClassUnspecified) {
    return;
  }

  if (sizeClass == UIUserInterfaceSizeClassRegular && [self isRegularTitleViewTooLarge]) {
    sizeClass = UIUserInterfaceSizeClassCompact;
  }

  if (force || !CGSizeEqualToSize(self.bounds.size, self.previousSize) || self.currentTitleViewSizeClass != sizeClass) {
    self.currentEffectiveSizeClass = sizeClass;
    self.currentTitleViewSizeClass = sizeClass;

    if (sizeClass == UIUserInterfaceSizeClassRegular) {
      [self generateRegularTitleViews];
    } else {
      [self generateCompactTitleViews];
    }
    self.previousSize = self.bounds.size;

    [self updateTitleViewAlphaWithPosition:self.currentPosition];
  }
}

- (void)setTitleViews:(NSArray<UIView *> *)titleViews {
  [self willChangeValueForKey:@"titleViews"];
  _titleViews = [titleViews copy];
  [self didChangeValueForKey:@"titleViews"];

  [self generateTitleView];
}

- (void)setTitleOffset:(UIOffset)titleOffset {
  [self willChangeValueForKey:@"titleOffset"];
  _titleOffset = titleOffset;
  [self didChangeValueForKey:@"titleOffset"];

  [self generateTitleView];
}

- (void)setCompactPageControlOffset:(UIOffset)compactPageControlOffset {
  [self didChangeValueForKey:@"compactPageControlOffset"];
  _compactPageControlOffset = compactPageControlOffset;
  [self didChangeValueForKey:@"compactPageControlOffset"];

  self.compactPageControlLeftConstraint.constant = compactPageControlOffset.horizontal;
  self.compactPageControlCenterYConstraint.constant = compactPageControlOffset.vertical;
  [self layoutIfNeeded];
}

- (void)setRegularPageControlOffset:(UIOffset)regularPageControlOffset {
  [self didChangeValueForKey:@"regularPageControlOffset"];
  _regularPageControlOffset = regularPageControlOffset;
  [self didChangeValueForKey:@"regularPageControlOffset"];

  self.regularPageControlLeftConstraint.constant = regularPageControlOffset.horizontal;
  self.regularPageControlCenterYConstraint.constant = regularPageControlOffset.vertical;
  [self layoutIfNeeded];
}

- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray *)array {
  NSMutableArray *titleViews = [self.titleViews mutableCopy];
  [titleViews replaceObjectsAtIndexes:indexes withObjects:array];
  self.titleViews = titleViews;
}

- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray<UIView *> *)array animated:(BOOL)animated {
  if (!animated) {
    [self replaceTitleViewsAtIndexes:indexes withTitleViews:array];
    return;
  }

  NSAssert(indexes.count == array.count, @"-[CTKPageViewControllerTitleView replaceTitleViewsAtIndexes:withTitleViews:animated: doesn't support remove/inserting title views while replacing existing title views. Please provide the same number of items on both sides.");
  NSMutableArray<UIView *> *previousTitleViews = [NSMutableArray arrayWithCapacity:indexes.count];
  [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [previousTitleViews addObject:self.titleViews[idx]];
  }];

  for (UIView *newTitleView in array) {
    newTitleView.alpha = 0.0;
  }

  [UIView transitionWithView:self.titleView duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    [array enumerateObjectsUsingBlock:^(UIView *newTitleView, NSUInteger idx, BOOL *stop) {
      UIView *previousTitleView = previousTitleViews[idx];
      newTitleView.alpha = previousTitleView.alpha;
      previousTitleView.alpha = 0.0;
    }];
    [self replaceTitleViewsAtIndexes:indexes withTitleViews:array];
  } completion:nil];
}

- (void)updateTitleViewPosition {
  CGFloat position = self.currentPosition;
  self.compactTitlesScrollView.contentOffset = [self compactTitleScrollViewContentOffsetFromPagePosition:position];
  self.regularPageControlContainerCenterXConstraint.constant = (self.regularMaxWidthTitleView.bounds.size.width + self.regularTitleViewSpacing) * position + self.regularMaxWidthTitleView.bounds.size.width / 2.0;
  [self.regularPageControlContainer layoutIfNeeded];

  [self updateTitleViewAlphaWithPosition:position];
}

- (CGPoint)compactTitleScrollViewContentOffsetFromPagePosition:(CGFloat)pagePosition {
  return CGPointMake(pagePosition * self.bounds.size.width, 0.0f);
}

- (void)updateTitleViewAlphaWithPosition:(CGFloat)position {
  CGFloat minimumTitleAlpha = self.currentEffectiveSizeClass == UIUserInterfaceSizeClassRegular ? self.regularMinimumTitleAlpha : self.compactMinimumTitleAlpha;
  CGFloat (^ calculateProgress)(CGFloat, CGFloat) = ^CGFloat(CGFloat origin, CGFloat offset) {
    offset -= origin;
    offset  = (CGFloat)fabs(offset);
    // Linear function
    CGFloat a = (1.0f - minimumTitleAlpha) / (0.0f - 0.5f);
    CGFloat b = 1.0f - a * 0.0f;
    offset = a * offset + b;
    if (offset < minimumTitleAlpha) {
      return minimumTitleAlpha;
    } else if (offset > 1.0f) {
      return 1.0f;
    }
    return offset;
  };

  NSUInteger count = self.titleViews.count;
  for (NSUInteger i = 0;i < count;++i) {
    self.titleViews[i].alpha = calculateProgress(i * 1.0f, position);
  }
}

- (void)setCurrentPosition:(CGFloat)currentPosition {
  if (_currentPosition == currentPosition) {
    return;
  }

  [self willChangeValueForKey:@"currentPosition"];
  _currentPosition = currentPosition;
  [self didChangeValueForKey:@"currentPosition"];

  [self updateTitleViewPosition];
}

- (void)animateTitleToHorizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass usingCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  if (self.currentEffectiveSizeClass == horizontalSizeClass) {
    return;
  }

  self.placeholderImageView.image = [self snapshotOfView:self.titleView];
  self.titleView.alpha = 0.0;

  [self generateTitleViewForSizeClass:horizontalSizeClass];

  CGFloat compactTargetAlpha = self.currentEffectiveSizeClass == UIUserInterfaceSizeClassCompact ? 1.0 : 0.0;
  CGFloat regularTargetAlpha = 1.0 - compactTargetAlpha;
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    self.titleView.alpha = 1.0;
    self.placeholderImageView.alpha = 0.0;
    self.compactTitleView.alpha = compactTargetAlpha;
    self.regularTitleView.alpha = regularTargetAlpha;
  } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    self.placeholderImageView.image = nil;
    self.placeholderImageView.alpha = 1.0;
  }];
}

- (void)updateTitleViewSizeClassAnimated:(BOOL)animated {
  CGFloat compactTargetAlpha = 0.0f;
  CGFloat regularTargetAlpha = 0.0f;

  if (self.currentEffectiveSizeClass != UIUserInterfaceSizeClassUnspecified) {
    compactTargetAlpha = self.currentEffectiveSizeClass == UIUserInterfaceSizeClassCompact ? 1.0 : 0.0;
    regularTargetAlpha = 1.0 - compactTargetAlpha;
  }

  void (^ animationBlock)(void) = ^{
    self.compactTitleView.alpha = compactTargetAlpha;
    self.regularTitleView.alpha = regularTargetAlpha;
  };

  if (animated) {
    [UIView animateWithDuration:0.35 animations:animationBlock];
  } else {
    animationBlock();
  }
}

- (void)animateTitleToSize:(CGSize)size usingCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    [self updateTitleViewPosition];
  } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    [self updateTitleViewPosition];
  }];
}

- (void)generateCompactTitleViews {
  for (UIView *subview in self.compactTitlesScrollView.subviews) {
    [subview removeFromSuperview];
  }
  for (UIView *subview in self.regularTitlesContainer.subviews) {
    [subview removeFromSuperview];
  }

  UIView *previousContainerView = nil;
  for (NSInteger i = 0;i < self.titleViews.count;++i) {
    UIView *titleView = self.titleViews[i];

    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.clipsToBounds = false;

    [containerView addSubview:titleView];

    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:self.titleOffset.horizontal];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:self.titleOffset.vertical];

    [containerView addConstraints:@[centerXConstraint, centerYConstraint]];

    [self.compactTitlesScrollView addSubview:containerView];

    NSMutableArray *constraints = [NSMutableArray array];
    if (previousContainerView == nil) {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    } else {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    }
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

    if (i == self.titleViews.count - 1) {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    }

    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    [self.compactTitlesScrollView addConstraints:constraints];

    previousContainerView = containerView;
  }

  self.compactPageControl.numberOfPages = self.titleViews.count;

  self.regularPageControlContainerCenterXConstraint.active = NO;
  self.regularPageControlContainerCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.regularPageControlContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.regularTitleView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
  self.regularPageControlContainerCenterXConstraint.priority = UILayoutPriorityFittingSizeLevel;
  [self.regularTitleView addConstraint:self.regularPageControlContainerCenterXConstraint];
}

- (void)maxWidthView:(UIView **)maxWidthView andMaxHeightViewForRegularTitleView:(UIView **)maxHeightView {
  *maxWidthView = nil;
  *maxHeightView = nil;
  for (UIView *titleView in self.titleViews) {
    [titleView sizeToFit];

    if (titleView.bounds.size.width > (*maxWidthView).bounds.size.width) {
      *maxWidthView = titleView;
    }
    if (titleView.bounds.size.height > (*maxHeightView).bounds.size.height) {
      *maxHeightView = titleView;
    }
  }
}

- (BOOL)isRegularTitleViewTooLarge {
  if ((self.bounds.size.width == 0 || self.bounds.size.height == 0) || (self.titleViews.count == 0)) {
    return NO;
  }
  UIView *maxWidthView = nil;
  UIView *maxHeightView = nil;
  [self maxWidthView:&maxWidthView andMaxHeightViewForRegularTitleView:&maxHeightView];

  CGFloat totalWidth = maxWidthView.bounds.size.width * self.titleViews.count + self.regularTitleViewSpacing * (self.titleViews.count - 1);
  return totalWidth > self.bounds.size.width;
}

- (void)generateRegularTitleViews {
  UIView *maxWidthView = nil;
  UIView *maxHeightView = nil;
  [self maxWidthView:&maxWidthView andMaxHeightViewForRegularTitleView:&maxHeightView];

  for (UIView *subview in self.compactTitlesScrollView.subviews) {
    [subview removeFromSuperview];
  }
  for (UIView *subview in self.regularTitlesContainer.subviews) {
    [subview removeFromSuperview];
  }

  UIView * allTitlesView = [[UIView alloc] init];
  allTitlesView.translatesAutoresizingMaskIntoConstraints = NO;

  UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapOnRegularTitleContainerView:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  tapGestureRecognizer.numberOfTouchesRequired = 1;
  [allTitlesView addGestureRecognizer:tapGestureRecognizer];

  NSMutableArray *constraints = [NSMutableArray array];
  UIView *previousContainerView = nil;
  for (UIView *titleView in self.titleViews) {
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.clipsToBounds = false;

    [containerView addSubview:titleView];

    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:self.titleOffset.horizontal];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:self.titleOffset.vertical];

    [containerView addConstraints:@[centerXConstraint, centerYConstraint]];

    if (previousContainerView == nil) {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    } else {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:self.regularTitleViewSpacing]];
    }
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:maxHeightView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    [allTitlesView addSubview:containerView];

    previousContainerView = containerView;
  }

  [allTitlesView addConstraints:constraints];

  [constraints addObject:[NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeWidth multiplier:(CGFloat)self.titleViews.count constant:self.regularTitleViewSpacing * (self.titleViews.count > 0 ? self.titleViews.count - 1 : 0)]];
  [constraints addObject:[NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:maxHeightView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

  [allTitlesView addConstraints:constraints];

  [self.regularTitlesContainer addSubview:allTitlesView];

  NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.regularTitlesContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
  NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.regularTitlesContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];

  [self.regularTitlesContainer addConstraints:@[centerXConstraint, centerYConstraint]];

  self.regularMaxWidthTitleView = maxWidthView;

  self.regularPageControlContainerCenterXConstraint.active = NO;
  self.regularPageControlContainerCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.regularPageControlContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
  [self.regularTitleView addConstraint:self.regularPageControlContainerCenterXConstraint];
  [self updateTitleViewPosition];
}

- (UIImage *)snapshotOfView:(UIView *)view {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();
  return image;
}

- (void)userDidTapOnRegularTitleContainerView:(UITapGestureRecognizer *)tapGestureRecognizer {
  if (![self.delegate respondsToSelector:@selector(pageViewControllerTitleView:didTapOnTitleViewAtIndex:)]) {
    return;
  }

  CGPoint location = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
  NSInteger titleViewIndex = (NSInteger)(location.x / (tapGestureRecognizer.view.bounds.size.width / (CGFloat)self.titleViews.count));
  if (titleViewIndex < 0) {
    titleViewIndex = 0;
  }
  if (titleViewIndex >= self.titleViews.count) {
    titleViewIndex = self.titleViews.count - 1;
  }
  [self.delegate pageViewControllerTitleView:self didTapOnTitleViewAtIndex:titleViewIndex];
}

@end
