//
//  PageControlTests.m
//  ControlsKit
//
//  Created by Bastien Falcou on 8/20/15.
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

#import <XCTest/XCTest.h>

#import "CTKPageControl.h"
#import "TestViewController.h"

@interface CTKPageControl (PrivateTests)

@property (nonatomic, strong) NSMutableArray<__kindof UIView *> *dotsArray;

- (CGFloat)xOriginForDotAtIndex:(NSInteger)dotIndex;
- (void)didTapDot:(id)sender;

@end

@interface PageControlTests : XCTestCase

@property (nonatomic, strong) UIImage *inactiveLeftImage;
@property (nonatomic, strong) UIImage *inactiveMiddleImage;
@property (nonatomic, strong) UIImage *inactiveRightImage;

@property (nonatomic, strong) UIImage *activeLeftImage;
@property (nonatomic, strong) UIImage *activeMiddleImage;
@property (nonatomic, strong) UIImage *activeRightImage;

@end

@implementation PageControlTests

- (void)setUp {
  [super setUp];
  
  self.inactiveLeftImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.inactiveMiddleImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.inactiveRightImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  
  self.activeLeftImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.activeMiddleImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.activeRightImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

#pragma mark - Test Load View

- (void)testLoadPageControlInView {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
  TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
  [testViewController loadView];
  
  XCTAssertNotNil(testViewController.testPageControl);
  XCTAssertTrue([testViewController.testPageControl isKindOfClass:[CTKPageControl class]]);
}

#pragma mark - Default Dots

- (void)testPageControlNumberOfPages {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  
  XCTAssertEqual(pageControl.dotsArray.count, 5);
}

- (void)testPageControlChangeNumberOfPages {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.numberOfPages = 10;
  pageControl.numberOfPages = 3;
  
  XCTAssertEqual(pageControl.dotsArray.count, 3);
}

- (void)testPageControlNegativeNumberOfPages {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = -1;
  
  XCTAssertEqual(pageControl.dotsArray.count, 0);
}

- (void)testPageControlNumberOfPagesInferiorToCurrentPage {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 4;
  pageControl.numberOfPages = 2;
  
  XCTAssertEqual(pageControl.currentPage, 1);
}

- (void)testPageControlDefaultCurrentPage {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  
  XCTAssertEqual(pageControl.currentPage, 0);
}

- (void)testPageControlChangeCurrentPageColor {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 3;
  
  XCTAssertEqualObjects([(UIView *)pageControl.dotsArray[3] backgroundColor], pageControl.currentPageIndicatorTintColor);
}

- (void)testPageControlNegativeCurrentPage {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = -1;
  
  XCTAssertEqual(pageControl.currentPage, 0);
}

- (void)testPageControlCurrentPageSuperiorToNumberOfPages {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 10;
  
  XCTAssertEqual(pageControl.currentPage, pageControl.numberOfPages - 1);
}

- (void)testPageControlChangeOtherPagesColor {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  for (UIView *dot in pageControl.dotsArray) {
    if (dot != pageControl.dotsArray[0]) {
      XCTAssertEqualObjects(dot.backgroundColor, pageControl.pageIndicatorTintColor);
    }
  }
}

- (void)testPageControlChangeFrameDefaultDots {
  CTKPageControl *pageControl = [[CTKPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 100.0f)];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  CGFloat previousOriginX = [pageControl.dotsArray[0] frame].origin.x;
	pageControl.frame = CGRectMake(0.0f, 0.0f, 400.0f, 100.0f);
	[pageControl layoutIfNeeded];
  
  XCTAssert([pageControl.dotsArray[0] frame].origin.x > previousOriginX);
}

- (void)testXOriginForDotAtIndexPathValue {
  CTKPageControl *pageControl = [[CTKPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 100.0f)];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  XCTAssertEqual([pageControl xOriginForDotAtIndex:2], pageControl.frame.size.width / 2.0f - [pageControl.dotsArray[2] frame].size.width / 2.0f);
}

- (void)testXOriginForDotAtIndexPathNegativeValue {
  CTKPageControl *pageControl = [[CTKPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 100.0f)];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  XCTAssertEqual([pageControl xOriginForDotAtIndex:-1], INFINITY);
}

#pragma mark - View Changes And Sizes

- (void)testPageControlSizeToFit {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  [pageControl sizeToFit];
	[pageControl layoutIfNeeded];
  
  for (UIView *dot in pageControl.dotsArray) {
    XCTAssertEqual(dot.frame.origin.y, 0.0f);
  }
}

- (void)testPageControlIntrinsicContentSize {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
	pageControl.currentPage = 0;
	pageControl.frame = CGRectMake(0.0f, 0.0f, pageControl.intrinsicContentSize.width, pageControl.intrinsicContentSize.height);
	[pageControl layoutIfNeeded];
  
  for (UIView *dot in pageControl.dotsArray) {
    XCTAssertEqual(dot.frame.origin.y, 0.0f);
  }
	
	XCTAssertEqual(pageControl.frame.size.width, (pageControl.dotsSize.width + pageControl.dotsSpace) * pageControl.numberOfPages - pageControl.dotsSpace);
}

- (void)testPageControlCustomDotsSize {
	CTKPageControl *pageControl = [[CTKPageControl alloc] init];
	pageControl.numberOfPages = 5;
	pageControl.currentPage = 0;
	pageControl.dotsSpace = 5.0f;
	pageControl.dotsSize = CGSizeMake(30.0f, 20.0f);
	pageControl.frame = CGRectMake(0.0f, 0.0f, pageControl.intrinsicContentSize.width, pageControl.intrinsicContentSize.height);
	[pageControl layoutIfNeeded];

	for (UIView *dot in pageControl.dotsArray) {
		XCTAssertEqual(dot.frame.origin.y, 0.0f);
	}

	XCTAssertEqual(pageControl.frame.size.width, (pageControl.dotsSize.width + pageControl.dotsSpace) * pageControl.numberOfPages - pageControl.dotsSpace);
}

- (void)testPageControlLayoutSubviews {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  CGFloat previousOriginX = [pageControl.dotsArray[0] frame].origin.x;
  pageControl.frame = CGRectMake(0.0f, 0.0f, 400.0f, 100.0f);
  
  [pageControl setNeedsLayout];
  [pageControl layoutIfNeeded];
  
  XCTAssert([pageControl.dotsArray[0] frame].origin.x > previousOriginX);
}

- (void)testPageControlSizeForNumberOfPagesNoPages {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 0;
  [pageControl sizeToFit];
  
  XCTAssertEqual(pageControl.frame.size.width, 0.0f);
  XCTAssertEqual(pageControl.frame.size.height, 0.0f);
}

- (void)testPageControlSizeForNumberOfPagesOnePage {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 1;
  [pageControl sizeToFit];
  
  XCTAssertEqual(pageControl.frame.size.width, [pageControl.dotsArray[0] frame].size.width);
  XCTAssertEqual(pageControl.frame.size.height, [pageControl.dotsArray[0] frame].size.height);
}

- (void)testPageControlSizeForNumberOfPagesTwoPages {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 2;
  [pageControl sizeToFit];
  
  XCTAssertEqual(pageControl.frame.size.width, [pageControl.dotsArray[0] frame].size.width * 2.0f + pageControl.dotsSpace);
  XCTAssertEqual(pageControl.frame.size.height, [pageControl.dotsArray[0] frame].size.height);
}

- (void)testPageControlSizeForNumberOfPagesTenPages {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 10;
  [pageControl sizeToFit];
  
  XCTAssertEqual(pageControl.frame.size.width, [pageControl sizeForNumberOfPages:10].width);
  XCTAssertEqual(pageControl.frame.size.height, [pageControl sizeForNumberOfPages:10].height);
}

- (void)testDistanceBetweenDotsChange {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 2;
  pageControl.dotsSpace = 10.0f;
  [pageControl sizeToFit];
  
  XCTAssertEqual(pageControl.frame.size.width, [pageControl.dotsArray[0] frame].size.width + 10.0f + [pageControl.dotsArray[1] frame].size.width);
}

#pragma mark - Custom Dot Images

- (void)testPageControlCustomImagesInactiveAllTheSame {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageInactive = self.activeMiddleImage;
  pageControl.middleDotImageInactive = self.activeMiddleImage;
  pageControl.rightDotImageInactive = self.activeMiddleImage;
  
  for (UIImageView *dot in pageControl.dotsArray) {
    if ([dot isKindOfClass:[UIImageView class]]) {
      XCTAssertEqualObjects(dot.image, self.activeMiddleImage);
    }
  }
}

- (void)testPageControlCustomImagesActiveAllTheSameCurrent {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageActive = self.inactiveMiddleImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveMiddleImage;
  
  XCTAssertEqualObjects([pageControl.dotsArray[0] image], self.inactiveMiddleImage);
}

- (void)testPageControlCustomImagesActiveAllTheSameOthers {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageActive = self.activeLeftImage;
  pageControl.middleDotImageActive = self.activeMiddleImage;
  pageControl.rightDotImageActive = self.activeRightImage;

	XCTAssertEqualObjects([pageControl.dotsArray[0] image], self.activeLeftImage);
}

- (void)testPageControlCustomImagesActiveLeft {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;
  
  XCTAssertEqualObjects([pageControl.dotsArray[0] image], self.inactiveLeftImage);
}

- (void)testPageControlCustomImagesActiveLeftOthersDifferent {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 4;
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;

	XCTAssertEqualObjects([pageControl.dotsArray[4] image], self.inactiveRightImage);
}

- (void)testPageControlCustomImagesInactiveMiddle {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;
  
  pageControl.leftDotImageInactive = self.inactiveLeftImage;
  pageControl.middleDotImageInactive = self.inactiveMiddleImage;
  pageControl.rightDotImageInactive = self.inactiveRightImage;
  
  for (UIImageView *dot in pageControl.dotsArray) {
    if (dot != [pageControl.dotsArray firstObject] && dot != [pageControl.dotsArray lastObject]) {
      XCTAssertEqualObjects(dot.image, self.inactiveMiddleImage);
    }
  }
}

- (void)testPageControlCustomImagesInactiveMiddleOthersDifferent {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 4; // Arbitrary value
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;
  
  pageControl.leftDotImageInactive = self.inactiveLeftImage;
  pageControl.middleDotImageInactive = self.inactiveMiddleImage;
  pageControl.rightDotImageInactive = self.inactiveRightImage;
  
  UIImage *imageLeft = (UIImage *)[pageControl.dotsArray[0] image];
  UIImage *imageRight = (UIImage *)[pageControl.dotsArray[4] image];
  
  XCTAssert(imageLeft != self.inactiveMiddleImage);
  XCTAssert(imageRight != self.inactiveMiddleImage);
}

- (void)testPageControlMiddleDotImageActiveOnePage {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 1;
  pageControl.currentPage = 0;
  
  pageControl.middleDotImageActive = self.activeMiddleImage;
  
  UIImage *imageDot = (UIImage *)[pageControl.dotsArray[0] image];
  
  XCTAssertEqualObjects(imageDot, self.activeMiddleImage);
}

- (void)testPageControlMiddleImageActive {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 2;
  
  pageControl.middleDotImageActive = self.activeMiddleImage;
  
  UIImage *imageDot = (UIImage *)[pageControl.dotsArray[2] image];
  
  XCTAssertEqualObjects(imageDot, self.activeMiddleImage);
}

#pragma mark - Properties

- (void)testPageControlHidesForSinglePageFirst {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.hidesForSinglePage = YES;
  pageControl.numberOfPages = 1;
  
  XCTAssertEqual(pageControl.dotsArray.count, 0);
}

- (void)testPageControlHidesForSinglePageAfterward {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
	pageControl.numberOfPages = 1;
	XCTAssertEqual(pageControl.dotsArray.count, 1);
	pageControl.hidesForSinglePage = YES;
	XCTAssertEqual(pageControl.dotsArray.count, 0);
	pageControl.numberOfPages = 0;
	XCTAssertEqual(pageControl.dotsArray.count, 0);
	pageControl.hidesForSinglePage = NO;
	XCTAssertEqual(pageControl.dotsArray.count, 0);
	pageControl.numberOfPages = 1;
	XCTAssertEqual(pageControl.dotsArray.count, 1);
}

- (void)testPageControlDefersCurrentPageDisplayBeforeUpdate {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  pageControl.defersCurrentPageDisplay = YES;
  pageControl.currentPage = 4;
  
  XCTAssertEqualObjects([pageControl.dotsArray[4] backgroundColor], pageControl.pageIndicatorTintColor);
}

- (void)testPageControlDefersCurrentPageDisplayAfterUpdate {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  pageControl.defersCurrentPageDisplay = YES;
  pageControl.currentPage = 4;
  [pageControl updateCurrentPageDisplay];
  
  XCTAssertEqualObjects([pageControl.dotsArray[4] backgroundColor], pageControl.currentPageIndicatorTintColor);
}

- (void)testPageControlResetDotsTintColor {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 4;
  pageControl.pageIndicatorTintColor = [UIColor redColor];
  pageControl.pageIndicatorTintColor = nil;
  
  XCTAssertEqualObjects([pageControl.dotsArray[0] backgroundColor], [[UIColor whiteColor] colorWithAlphaComponent:0.5f]);
}

- (void)testPageControlResetCurrentDotTintColor {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  pageControl.currentPageIndicatorTintColor = [UIColor redColor];
  pageControl.currentPageIndicatorTintColor = nil;
  
  XCTAssertEqualObjects([pageControl.dotsArray[0] backgroundColor], [UIColor whiteColor]);
}

#pragma mark - Actions

- (void)testPageControlTapDot {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  UIView *dotView = pageControl.dotsArray[2];
  [pageControl didTapDot:dotView.gestureRecognizers[0]];
  
  XCTAssertEqual(pageControl.currentPage, 2);
}

- (void)testPageControlTapDotInvalidType {
  CTKPageControl *pageControl = [[CTKPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  UIView *dotView = pageControl.dotsArray[2];
  [pageControl didTapDot:dotView];
  
  XCTAssertNotEqual(pageControl.currentPage, 2);
}

@end
