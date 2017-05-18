//
//  CTKPageViewController.m
//  Ethanol
//
//  Created by Stephane Copin on 6/30/14.
//  Copyright © 2014 Stéphane Copin. All rights reserved.
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

#import "CTKPageViewController.h"
#import "CTKPageViewControllerTitleView.h"
#import "CTKPageViewControllerTitleView+Private.h"

#import <objc/runtime.h>

#define kTitleViewHorizontalMargin 80.0f
#define kTitleViewMaxHeight 26.0f

#define kPageControlHeight 6.0f

#define kPageControlTopMargin 2.0f

#define kTitleViewCompactMinimumAlpha 0.45f
#define kTitleViewRegularMinimumAlpha 0.45f

#define kTitleViewDefaultFontSize 17.0

static NSString *const CTKViewTintColorDidChangeNotification = @"CTKViewTintColorDidChangeNotification";

typedef void (^ CTKDisplayLinkTriggeredBlock)(CADisplayLink *displayLink);

@interface CTKInternalWeakReference : NSObject

@property (nonatomic, weak, nullable) id reference;

@end

@implementation CTKInternalWeakReference

@end

@interface CTKInternalWeakTarget: CTKInternalWeakReference

@property (nonatomic, assign) SEL selector;

@end

@implementation CTKInternalWeakTarget

- (void)run:(id)sender {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  [self.reference performSelector:self.selector withObject:sender];
#pragma clang diagnostic pop
}

@end

@interface UIViewController ()

@property (nonatomic, weak, nullable) CTKPageViewController *pageViewController;

@end

@interface UIView (TintColorDidChangeNotification)

- (void)ethanol_tintColorDidChange;

@end

@implementation UIView (TintColorDidChangeNotification)

+ (void)load {
  SEL originalSelector = @selector(tintColorDidChange);
  SEL swizzledSelector = @selector(ethanol_tintColorDidChange);
  Method originalMethod = class_getInstanceMethod([self class], originalSelector);
  Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);

  class_addMethod([self class],
                  originalSelector,
                  method_getImplementation(swizzledMethod),
                  method_getTypeEncoding(swizzledMethod));

  method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)ethanol_tintColorDidChange {
  [self ethanol_tintColorDidChange];

  [[NSNotificationCenter defaultCenter] postNotificationName:CTKViewTintColorDidChangeNotification object:self];
}

@end

@interface CTKPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate, CTKPageViewControllerTitleViewDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIScrollView *internalScrollView;
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) NSLayoutConstraint *titleViewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *titleViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *titleViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *titleViewCenterYConstraint;
@property (nonatomic, strong, readonly) NSMutableArray<UILabel *> *generatedTitleLabels;
@property (nonatomic, assign) NSInteger previousPage;
@property (nonatomic, assign) NSInteger expectedPage;
@property (nonatomic, assign) UIUserInterfaceSizeClass newHorizontalSizeClass;
@property (nonatomic, assign) BOOL hasViewAppeared;

@end

@implementation CTKPageViewController
@synthesize generatedTitleLabels = _generatedTitleLabels;
@synthesize viewControllers = _viewControllers;
@synthesize titleView = _titleView;

- (id)init {
  return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:nil];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self != nil) {
    [self ctk_commonInit];
  }
  return self;
}

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary *)options {
  self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
  if (self != nil) {
    [self ctk_commonInit];
  }
  return self;
}

- (void)ctk_commonInit {
  [super setDataSource:self];
  [super setDelegate:self];

  _displayPagedTitleView = YES;

  self.viewControllers = @[];
}

- (void)dealloc {
  [self.displayLink invalidate];
  self.displayLink = nil;

  if (self.isViewLoaded) {
    [self removeObserver:self forKeyPath:@"navigationController" context:NULL];

    [self.navigationBar removeObserver:self forKeyPath:@"titleTextAttributes" context:NULL];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTKViewTintColorDidChangeNotification object:self.navigationController.navigationBar];
  }

  self.viewControllers = @[];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self addObserver:self forKeyPath:@"navigationController" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewTintColorDidChangeNotificationHandler:) name:CTKViewTintColorDidChangeNotification object:self.navigationController.navigationBar];

  if (self.navigationController.navigationBar != nil) {
    [self.navigationController.navigationBar addObserver:self forKeyPath:@"titleTextAttributes" options:0 context:NULL];

    self.navigationBar = self.navigationController.navigationBar;

    [self updatePageControlsTintColor];
  }

  self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
  [self activateTitleViewConstraints];

  self.previousPage = NSNotFound;
  self.expectedPage = NSNotFound;
  [self updateCurrentPageAnimated:NO completion:nil];

  self.newHorizontalSizeClass = UIUserInterfaceSizeClassUnspecified;

  CTKInternalWeakTarget *weakReference = [[CTKInternalWeakTarget alloc] init];
  weakReference.reference = self;
  weakReference.selector = @selector(updateTitleViewPosition:);
  self.displayLink = [CADisplayLink displayLinkWithTarget:weakReference selector:@selector(run:)];
  NSRunLoop *runner = [NSRunLoop currentRunLoop];
  [self.displayLink addToRunLoop:runner forMode:NSRunLoopCommonModes];

  self.internalScrollView = (UIScrollView *)[[self class] searchForViewOfType:[UIScrollView class] inView:self.view];
  self.internalScrollView.scrollsToTop = false;
}

- (void)activateTitleViewConstraints {
  [self deactivateTitleViewConstraints];

  if (!self.displayPagedTitleView) {
    return;
  }

  self.navigationItem.titleView = self.titleView;

  if (self.titleView.superview == nil || self.navigationBar == nil) {
    return;
  }

  self.titleView.translatesAutoresizingMaskIntoConstraints = NO;

  self.titleViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.navigationBar attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
  self.titleViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.navigationBar attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-2.0 * kTitleViewHorizontalMargin];
  self.titleViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.navigationBar attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
  self.titleViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.navigationBar attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];

  self.titleViewHeightConstraint.active = YES;
  self.titleViewWidthConstraint.active = YES;
  self.titleViewCenterYConstraint.active = YES;
  self.titleViewCenterXConstraint.active = YES;
}

- (void)deactivateTitleViewConstraints {
  self.titleViewHeightConstraint.active = NO;
  self.titleViewWidthConstraint.active = NO;
  self.titleViewCenterYConstraint.active = NO;
  self.titleViewCenterXConstraint.active = NO;

  self.titleView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (!self.hasViewAppeared) {
    self.hasViewAppeared = YES;

    [self updateNavigationItemTitleView];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self activateTitleViewConstraints];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self deactivateTitleViewConstraints];

  [super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:@"navigationController"]) {
    if (self.navigationController.navigationBar != nil) {
      [self.navigationController.navigationBar addObserver:self forKeyPath:@"titleTextAttributes" options:0 context:NULL];

      self.navigationBar = self.navigationController.navigationBar;
    } else {
      [self.navigationController.navigationBar removeObserver:self forKeyPath:@"titleTextAttributes" context:NULL];

      self.navigationBar = nil;
    }
  } else if ([keyPath isEqualToString:@"titleTextAttributes"]) {
    for (UILabel *label in self.generatedTitleLabels) {
      label.font = [self.navigationBar titleTextAttributes][NSFontAttributeName];
      label.textColor = [self.navigationBar titleTextAttributes][NSForegroundColorAttributeName];
    }
  } else if ([keyPath isEqualToString:@"title"] || [keyPath isEqualToString:@"navigationItem.title"] || [keyPath isEqualToString:@"navigationItem.titleView"]) {
    UIViewController *viewController = object;
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound || index >= self.titleView.titleViews.count) {
      return;
    }

    [self.titleView replaceTitleViewsAtIndexes:[NSIndexSet indexSetWithIndex:index]
                                withTitleViews:@[[self titleViewForViewController:viewController]]
                                      animated:NO];

    [self updateNavigationItemTitleView];
  }
}

- (void)viewTintColorDidChangeNotificationHandler:(NSNotification *)notification {
  [self updatePageControlsTintColor];
}

- (void)updatePageControlsTintColor {
  self.titleView.compactPageControl.currentPageIndicatorTintColor = self.navigationBar.tintColor;
  self.titleView.compactPageControl.pageIndicatorTintColor = [self.navigationBar.tintColor colorWithAlphaComponent:0.25];
  self.titleView.regularPageControl.currentPageIndicatorTintColor = self.navigationBar.tintColor;
}

+ (UIView *)searchForViewOfType:(Class)class inView:(UIView *)baseView {
  if ([baseView isKindOfClass:[UIScrollView class]]) {
    return baseView;
  }

  for (UIView *subview in baseView.subviews) {
    UIView *foundView = [self searchForViewOfType:class inView:subview];
    if (foundView != nil) {
      return foundView;
    }
  }
  return nil;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

  [self.titleView animateTitleToHorizontalSizeClass:newCollection.horizontalSizeClass usingCoordinator:coordinator];
  self.titleView.compactPageControl.currentPage = self.currentPage;
  self.newHorizontalSizeClass = newCollection.horizontalSizeClass;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

  [self.titleView animateTitleToSize:size usingCoordinator:coordinator];
  if (self.newHorizontalSizeClass != UIUserInterfaceSizeClassUnspecified) {
    [self.titleView animateTitleToHorizontalSizeClass:self.newHorizontalSizeClass usingCoordinator:coordinator];
    self.newHorizontalSizeClass = UIUserInterfaceSizeClassUnspecified;
  }
}

- (void)willChangeToPage:(NSInteger)page {

}

- (void)didChangeToPage:(NSInteger)page {

}

- (nonnull UIViewController *)viewControllerForPageAtIndex:(NSInteger)pageIndex {
  return [[UIViewController alloc] init];
}

- (void)setCurrentPage:(NSInteger)page {
  [self setCurrentPage:page animated:NO];
}

- (void)setCurrentPage:(NSInteger)page animated:(BOOL)animated {
  if (page == _currentPage) {
    return;
  }

  self.previousPage = self.currentPage;
  [self willChangeValueForKey:@"currentPage"];
  [self willChangeToPage:page];
  _currentPage = page;
  self.titleView.compactPageControl.currentPage = page;
  __weak CTKPageViewController *weakSelf = self;
  [self updateCurrentPageAnimated:animated completion:^(BOOL finished) {
    weakSelf.previousPage = page;
    [weakSelf didChangeToPage:page];
    [weakSelf updateNavigationItemTitleView];
  }];
  [self didChangeValueForKey:@"currentPage"];
}

- (void)updateCurrentPageAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
  if (self.viewControllers.count == 0) {
    return;
  }

  UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
  if (animated && self.previousPage != NSNotFound && self.currentPage < self.previousPage) {
    direction = UIPageViewControllerNavigationDirectionReverse;
  }

  [self setViewControllers:@[self.viewControllers[self.currentPage]]
                 direction:direction
                  animated:animated
                completion:^(BOOL finished) {
                  if (animated && completion != nil) {
                    completion(finished);
                  }
                }];

  self.titleView.currentPosition = [self currentPosition];
  if (!animated && completion != nil) {
    completion(true);
  }
}

- (UIViewController *)currentViewController {
  return self.viewControllers.count != 0 ? self.viewControllers[self.currentPage] : 0;
}

- (NSMutableArray *)generatedTitleLabels {
  if (_generatedTitleLabels == nil) {
    _generatedTitleLabels = [NSMutableArray array];
  }
  return _generatedTitleLabels;
}

- (CTKPageViewControllerTitleView *)titleView {
  if (_titleView == nil) {
    _titleView = [[CTKPageViewControllerTitleView alloc] init];
    _titleView.delegate = self;
  }
  return _titleView;
}

#pragma mark - UIPageViewController delegate methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
  NSInteger page = [self.viewControllers indexOfObject:viewController];
  if (--page < 0) {
    return nil;
  }

  UIViewController *nextViewController = self.viewControllers[page];
  return nextViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
  NSInteger page = [self.viewControllers indexOfObject:viewController];
  if (++page >= self.viewControllers.count) {
    return nil;
  }

  UIViewController *nextViewController = self.viewControllers[page];
  return nextViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
  self.previousPage = self.currentPage;
  NSInteger newPage = [self.viewControllers indexOfObject:pendingViewControllers.firstObject];
  [self willChangeToPage:newPage];
  self.expectedPage = newPage;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
  NSInteger page = [self.viewControllers indexOfObject:super.viewControllers.firstObject];
  _currentPage = page;
  self.titleView.compactPageControl.currentPage = page;
  self.expectedPage = NSNotFound;

  [self didChangeToPage:page];
  [self updateNavigationItemTitleView];
}

#pragma mark - CTKPageViewControllerTitleView delegate methods

- (void)pageViewControllerTitleView:(CTKPageViewControllerTitleView *)pageViewControllerTitleView didTapOnTitleViewAtIndex:(NSInteger)index {
  [self setCurrentPage:index animated:YES];
}

#pragma mark - Custom setters

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
  [self willChangeValueForKey:@"viewControllers"];
  for (UIViewController *viewController in _viewControllers) {
    [viewController removeObserver:self forKeyPath:@"title" context:NULL];
    [viewController removeObserver:self forKeyPath:@"navigationItem.title" context:NULL];
    [viewController removeObserver:self forKeyPath:@"navigationItem.titleView" context:NULL];
    viewController.pageViewController = nil;
  }

  _viewControllers = viewControllers;

  for (UIViewController *viewController in viewControllers) {
    [viewController addObserver:self forKeyPath:@"title" options:0 context:NULL];
    [viewController addObserver:self forKeyPath:@"navigationItem.title" options:0 context:NULL];
    [viewController addObserver:self forKeyPath:@"navigationItem.titleView" options:0 context:NULL];
    viewController.pageViewController = self;
  }

  [self updateCurrentPageAnimated:NO completion:nil];

  NSMutableArray *titleViews = [NSMutableArray array];
  for (UIViewController *viewController in self.viewControllers) {
    [titleViews addObject:[self titleViewForViewController:viewController]];
  }
  self.titleView.titleViews = titleViews;
  [self didChangeValueForKey:@"viewControllers"];

  [self updateNavigationItemTitleView];
}

- (void)setDisplayPagedTitleView:(BOOL)displayPagedTitleView {
  _displayPagedTitleView = displayPagedTitleView;
  [self updateNavigationItemTitleView];
}

#pragma mark - Custom getters

- (UIView *)titleViewForViewController:(UIViewController *)viewController {
  if (viewController.navigationItem.titleView != nil) {
    UIView *titleView = viewController.navigationItem.titleView;
    if (titleView.translatesAutoresizingMaskIntoConstraints) {
      // Add true width & height constraints instead
      NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:titleView.bounds.size.width];
      NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:titleView.bounds.size.height];

      titleView.translatesAutoresizingMaskIntoConstraints = NO;

      [titleView addConstraints:@[widthConstraint, heightConstraint]];
    }
    return titleView;
  } else {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [self.navigationBar titleTextAttributes][NSFontAttributeName] ?: [UIFont boldSystemFontOfSize:kTitleViewDefaultFontSize];
    label.text = viewController.navigationItem.title ?: viewController.title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [self.navigationController.navigationBar titleTextAttributes][NSForegroundColorAttributeName];
    NSShadow *shadow = [self.navigationController.navigationBar titleTextAttributes][NSShadowAttributeName];
    if (shadow != nil) {
      label.shadowOffset = shadow.shadowOffset;
      label.shadowColor = shadow.shadowColor;
    }

    [label sizeToFit];

    [self.generatedTitleLabels addObject:label];

    return label;
  }
}

#pragma mark - Display Link

- (void)updateTitleViewPosition:(CADisplayLink *)displayLink {
  if (self.titleView.hidden || self.previousPage == NSNotFound) {
    return;
  }

  NSInteger expectedPage;
  if (self.expectedPage != NSNotFound) {
    expectedPage = self.expectedPage;
  } else {
    expectedPage = self.currentPage;
  }
  CGFloat offset = (CGFloat)(expectedPage - self.previousPage);
  if (offset < 0) {
    offset = -offset;
  }
  self.titleView.currentPosition = [self currentPosition] * ((expectedPage != self.previousPage) ? offset : 1.0f);
}

#pragma mark - Helper method

- (void)updateNavigationItemTitleView {
  if (!self.hasViewAppeared) {
    return;
  }

  if (self.displayPagedTitleView) {
    self.navigationItem.title = nil;
    self.navigationItem.titleView = self.titleView;
    [self activateTitleViewConstraints];
  } else {
    [self deactivateTitleViewConstraints];
    self.navigationItem.title = self.currentViewController.navigationItem.title;
    self.navigationItem.titleView = self.currentViewController.navigationItem.titleView;
  }
}

- (BOOL)isRegularHorizontalSizeClass {
  return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
}

- (void)setDelegate:(id<UIPageViewControllerDelegate> _Nullable)delegate {
  if (self.delegate == nil) {
    return;
  }
}

- (void)setDataSource:(id<UIPageViewControllerDataSource> _Nullable)dataSource {
  if (self.dataSource == nil) {
    return;
  }
}

- (CGFloat)currentPosition {
  NSUInteger offset = 0;
  UIViewController *firstVisibleViewController;
  while (offset < self.viewControllers.count && (firstVisibleViewController = self.viewControllers[offset]).view.superview == nil) {
    ++offset;
  }

  if (offset >= self.viewControllers.count) {
    CGFloat offset = self.internalScrollView.contentOffset.x;
    offset /= self.view.frame.size.width;
    return offset;
  }

  CGRect rect = [[firstVisibleViewController.view superview] convertRect:firstVisibleViewController.view.frame fromView:self.view];
  rect.origin.x /= self.view.frame.size.width;
  rect.origin.x += (CGFloat)offset;
  return rect.origin.x;
}

@end

static char pageViewControllerKey;

@implementation UIViewController (PageViewController)

- (CTKPageViewController *)pageViewController {
  return [objc_getAssociatedObject(self, &pageViewControllerKey) reference];
}

- (void)setPageViewController:(CTKPageViewController *)pageViewController {
  if (pageViewController != nil) {
    CTKInternalWeakReference *weakReference = [[CTKInternalWeakReference alloc] init];
    weakReference.reference = pageViewController;
    objc_setAssociatedObject(self, &pageViewControllerKey, weakReference, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  } else {
    objc_setAssociatedObject(self, &pageViewControllerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

- (NSInteger)pageIndex {
  if (self.pageViewController == nil) {
    return NSNotFound;
  }
  return [self.pageViewController.viewControllers indexOfObject:self];
}

@end
