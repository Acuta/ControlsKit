//
//  NibViewTests.m
//  ControlsKit
//
//  Created by Stephane Copin on 9/10/15.
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

#import "NibViewTest.h"
#import "TestViewController.h"

@interface NibViewTests : XCTestCase

@end

@implementation NibViewTests

- (void)testNibViewInit {
  NibViewTest * nibView = [[NibViewTest alloc] init];
  
  XCTAssertNotNil(nibView.contentView);
  XCTAssertNotNil(nibView.label);
  XCTAssertTrue([nibView.label isKindOfClass:[UILabel class]]);
}

- (void)testNibViewInitWithFrame {
  NibViewTest * nibView = [[NibViewTest alloc] initWithFrame:CGRectZero];
  
  XCTAssertNotNil(nibView.contentView);
  XCTAssertNotNil(nibView.label);
  XCTAssertTrue([nibView.label isKindOfClass:[UILabel class]]);
}

- (void)testNibViewInitWithCoder {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
  TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
  [testViewController loadView];
  
  XCTAssertNotNil(testViewController.testNibView);
  XCTAssertTrue([testViewController.testNibView isKindOfClass:[CTKNibView class]]);
  XCTAssertNotNil(testViewController.testNibView.contentView);
  XCTAssertNotNil(testViewController.testNibView.label);
  XCTAssertTrue([testViewController.testNibView.label isKindOfClass:[UILabel class]]);
}

@end
