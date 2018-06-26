//
//  PlaceholderTextViewTests.m
//  ControlsKit
//
//  Created by Stephane Copin on 2/17/16.
//  Copyright © 2016 Bastien Falcou. All rights reserved.
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

#import "CTKPlaceholderTextView.h"
#import "TestViewController.h"

@interface CTKPlaceholderTextView (Private)

@property (nonatomic, weak) UILabel * placeholderLabel;

- (void)userSetText:(NSString *)text;
- (void)userSetAttributedText:(NSAttributedString *)attributedText;

@end

@implementation CTKPlaceholderTextView (Private)
@dynamic placeholderLabel;

- (void)userSetText:(NSString *)text {
  [super setText:text];
}

@end

@interface PlaceholderTextViewTests : XCTestCase

@end

@implementation PlaceholderTextViewTests

- (void)testPlaceholderInitWithFrame {
  CTKPlaceholderTextView * textView = [[CTKPlaceholderTextView alloc] initWithFrame:CGRectZero];
  XCTAssertFalse(textView.placeholderLabel.hidden);
  textView.text = @"placeholder should disappear";
  XCTAssertTrue(textView.placeholderLabel.hidden);
  textView.text = @"";
  XCTAssertFalse(textView.placeholderLabel.hidden);
}

- (void)testPlaceholderInitWithCoder {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
  TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
  [testViewController loadView];

  XCTAssertNotNil(testViewController.testPlaceholderTextView);
  XCTAssertFalse(testViewController.testPlaceholderTextView.placeholderLabel.hidden);
  testViewController.testPlaceholderTextView.text = @"placeholder should disappear";
  XCTAssertTrue(testViewController.testPlaceholderTextView.placeholderLabel.hidden);
  testViewController.testPlaceholderTextView.text = @"";
  XCTAssertFalse(testViewController.testPlaceholderTextView.placeholderLabel.hidden);
}

- (void)testPlaceholderPosition {
  CTKPlaceholderTextView * textView = [[CTKPlaceholderTextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
  XCTAssertEqual(textView.placeholderLabel.frame.origin.x, kCTKPlaceholderTextViewDefaultPlaceholderInset.left);
  textView.text = @"Text";
  XCTAssertEqual(textView.placeholderLabel.frame.origin.x, kCTKPlaceholderTextViewDefaultPlaceholderInset.left);
  textView.placeholderInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 5.0f);
  XCTAssertLessThanOrEqual(textView.placeholderLabel.frame.size.width, 45.0f);
  textView.placeholderInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
  textView.frame = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
  [textView layoutIfNeeded];
  XCTAssertLessThanOrEqual(textView.placeholderLabel.frame.size.width, 30.0f);
}

- (void)testPlaceholderHeight {
  CTKPlaceholderTextView * textView = [[CTKPlaceholderTextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 5.0f)];
  XCTAssertEqual(textView.placeholderLabel.frame.origin.x, kCTKPlaceholderTextViewDefaultPlaceholderInset.left);
  textView.textContainerInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
  textView.placeholder = @"Text";
  XCTAssertEqual(textView.placeholderLabel.frame.size.height, 5.0f);
  textView.textContainerInset = UIEdgeInsetsMake(0.0f, 0.0f, 4.0f, 0.0f);
  [textView layoutIfNeeded];
  XCTAssertEqual(textView.placeholderLabel.frame.size.height, 1.0f);
}

- (void)testPlaceholderText {
  CTKPlaceholderTextView * textView = [[CTKPlaceholderTextView alloc] initWithFrame:CGRectZero];
  textView.placeholder = @"test";
  XCTAssertEqualObjects(textView.placeholder, @"test");
  XCTAssertEqualObjects(textView.placeholderLabel.text, textView.placeholder);
  NSAttributedString * test = [[NSAttributedString alloc] initWithString:@"test"];
  textView.attributedPlaceholder = test;
  XCTAssertEqualObjects(textView.attributedPlaceholder, test);
  XCTAssertEqualObjects(textView.placeholderLabel.attributedText, test);
}

- (void)testPlaceholderVisibility {
  CTKPlaceholderTextView * textView = [[CTKPlaceholderTextView alloc] initWithFrame:CGRectZero];
  XCTAssertFalse(textView.placeholderLabel.hidden);
  textView.text = @"test";
  XCTAssertTrue(textView.placeholderLabel.hidden);
  textView.text = nil;
  XCTAssertFalse(textView.placeholderLabel.hidden);
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidBeginEditingNotification object:textView userInfo:nil];
  XCTAssertFalse(textView.placeholderLabel.hidden);
  [textView userSetText:@"t"];
  XCTAssertTrue(textView.placeholderLabel.hidden);
  [textView userSetText:@""];
  XCTAssertFalse(textView.placeholderLabel.hidden);
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidEndEditingNotification object:textView userInfo:nil];
  XCTAssertFalse(textView.placeholderLabel.hidden);
  [textView userSetAttributedText:[[NSAttributedString alloc] initWithString:@"t"]];
  XCTAssertFalse(textView.placeholderLabel.hidden);
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView userInfo:nil];
  XCTAssertTrue(textView.placeholderLabel.hidden);
  [textView userSetAttributedText:[[NSAttributedString alloc] initWithString:@""]];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView userInfo:nil];
  XCTAssertFalse(textView.placeholderLabel.hidden);
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidEndEditingNotification object:textView userInfo:nil];
  XCTAssertFalse(textView.placeholderLabel.hidden);
}

@end
