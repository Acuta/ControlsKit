//
//  CTKPageControl.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const CGSize kCTKPageControlDefaultSize;

@interface CTKPageControl : UIControl

/**
 *  Number of pages of the carousel, will define the number of dots.
 */
@property (nonatomic, assign) IBInspectable NSInteger numberOfPages;

/**
 *  Carousel page currently displayed. The corresponding dot will be displayed as active (all the other dots will be inactive).
 */
@property (nonatomic, assign) IBInspectable NSInteger currentPage;

/**
 *  Distance between two dots (whether they are custom images or built-in ones).
 */
@property (nonatomic, assign) IBInspectable CGFloat dotsSpace;

/**
 *  The size of the dots, if not using images.
 */
@property (nonatomic, assign) IBInspectable CGSize dotsSize;

/**
 *  Hide the the indicator if there is only one page. Default is NO.
 */
@property (nonatomic, assign) IBInspectable BOOL hidesForSinglePage;

/**
 *  TintColor for inactive page indicators (dots). You can specify your alpha for the provided custom color if needed.
 */
@property (nonatomic, strong, nullable) IBInspectable UIColor *pageIndicatorTintColor UI_APPEARANCE_SELECTOR;

/**
 *  TintColor for active page indicator. You can specify your alpha for the provided custom color if needed.
 */
@property (nonatomic, strong, nullable) IBInspectable UIColor *currentPageIndicatorTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Whether or not to apply the pageIndicatorTintColor and the currentPageIndicatorTintColor to the images.
 */
@property (nonatomic, assign) IBInspectable BOOL applyPageIndicatorTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Set the value of this property to true so that, when the user taps the control to go to a new page, the class defers updating the page control until it calls updateCurrentPageDisplay.
 *  Set the value to NO (the default) to have the page control updated immediately.
 */
@property (nonatomic, assign) IBInspectable BOOL defersCurrentPageDisplay;

/**
 *  Image for the top left dot (corresponding to the first page of the carousel).
 *  This image will be displayed when the state is active (current page is the first page).
 *  Default circle dot will be set if this property is set to nil.
 */
@property (nonatomic, strong, nullable) IBInspectable UIImage *leftDotImageInactive;

/**
 *  Image for all the dots in the middle, that are neither the top left dot nor the top right dot, this whatever the number of middle dots is.
 *  This image will be displayed when the state is active (for the dot corresponding to the current page).
 *  Default circle dot will be set if this property is set to nil.
 */
@property (nonatomic, strong, nullable) IBInspectable UIImage *middleDotImageInactive;

/**
 *  Image for the top left left (corresponding to the last page of the carousel).
 *  This image will be displayed when the state is active (current page is the last page).
 *  Default circle dot will be set if this property is set to nil.
 */
@property (nonatomic, strong, nullable) IBInspectable UIImage *rightDotImageInactive;

/**
 *  Same for top left dot when its state its inactive (current page is not the first page).
 */
@property (nonatomic, strong, nullable) IBInspectable UIImage *leftDotImageActive;

/**
 *  Same for dots in the middle when they are in they state inactive.
 */
@property (nonatomic, strong, nullable) IBInspectable UIImage *middleDotImageActive;

/**
 *  Same for top right dot when its state its inactive (current page is not the last page).
 */
@property (nonatomic, strong, nullable) IBInspectable UIImage *rightDotImageActive;

/**
 *  Returns minimum size required to display dots for given page count. Can be used to size control if page count could change.
 *
 *  @param pageCount Given page count.
 *
 *  @return Size for given number of pages.
 */
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

/**
 *  This method updates the page indicator so that the current page (the white dot) matches the value returned from currentPage.
 *  The class ignores this method if the value of defersCurrentPageDisplay is false. Setting the currentPage value directly updates the indicator immediately.
 */
- (void)updateCurrentPageDisplay;

@end

NS_ASSUME_NONNULL_END
