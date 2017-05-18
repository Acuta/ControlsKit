//
//  CTKPageViewControllerTitleView.h
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

#import <UIKit/UIKit.h>

#import "CTKNibView.h"
#import "CTKPageControl.h"

NS_ASSUME_NONNULL_BEGIN

@class CTKPageViewControllerTitleView;

@protocol CTKPageViewControllerTitleViewDelegate <NSObject>

@optional
- (void)pageViewControllerTitleView:(CTKPageViewControllerTitleView *)pageViewControllerTitleView didTapOnTitleViewAtIndex:(NSInteger)index;

@end

@interface CTKPageViewControllerTitleView : CTKNibView

@property (nonatomic, weak, nullable) id<CTKPageViewControllerTitleViewDelegate> delegate;

@property (nonatomic, assign, readonly) CGFloat currentPosition;

@property (nonatomic, strong) IBOutlet CTKPageControl * regularPageControl;
@property (nonatomic, strong) IBOutlet CTKPageControl * compactPageControl;
@property (nonatomic, copy, nullable) NSArray<UIView *> * titleViews;

- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray *)array;

// if animated, indexes.count must be equal to array.count
- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray *)array animated:(BOOL)animated;

@property (nonatomic, assign) UIEdgeInsets titleViewInset;
@property (nonatomic, assign) IBInspectable CGFloat regularTitleViewSpacing; // Defaults to 20.0
@property (nonatomic, assign) UIOffset titleOffset;
@property (nonatomic, assign) UIOffset compactPageControlOffset;
@property (nonatomic, assign) UIOffset regularPageControlOffset;
@property (nonatomic, assign) IBInspectable CGFloat compactMinimumTitleAlpha;
@property (nonatomic, assign) IBInspectable CGFloat regularMinimumTitleAlpha;

@end

NS_ASSUME_NONNULL_END
