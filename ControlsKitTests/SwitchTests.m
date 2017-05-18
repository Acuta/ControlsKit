//
//  SwitchTest.m
//  ControlsKit
//
//  Created by Bastien Falcou on 8/19/15.
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

#import "CTKSwitch.h"
#import "TestViewController.h"

@interface CTKSwitch (PrivateTests)

@property (nonatomic, retain, readwrite) UIImageView *backgroundImageView;

- (void)switchValueChanged:(id)sender;

@end

@interface SwitchTests : XCTestCase

@property (nonatomic, strong) UIImage *image;

@end

@implementation SwitchTests

- (void)setUp {
  [super setUp];

  self.image = [UIImage imageNamed:@"Switch-Test-Image" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

- (void)testLoadSwitchInView {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
  TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
  [testViewController loadView];

  XCTAssertNotNil(testViewController.testSwitch);
  XCTAssertTrue([testViewController.testSwitch isKindOfClass:[CTKSwitch class]]);
}

- (void)testTurnSwitchOnColorOnSwitch {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.onTintColor = [UIColor redColor];
  theSwitch.on = YES;

  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testTurnSwitchOffColorOffSwitch {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.on = NO;

  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testTurnSwitchOnColorOffSwitch {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.onTintColor = [UIColor redColor];
  theSwitch.on = NO;

  XCTAssertNotEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testTurnSwitchOffColorOnSwitch {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.on = YES;

  XCTAssertNotEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testOnBackgroundPicture {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.onImage = self.image;
  theSwitch.on = YES;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, self.image);
}

- (void)testOffBackgroundPicture {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.offImage = self.image;
  theSwitch.on = NO;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, self.image);
}

- (void)testOnBackgroundPictureOffStatus {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.onImage = self.image;
  theSwitch.on = NO;

  XCTAssertNotEqualObjects(theSwitch.backgroundImageView.image, self.image);
}

- (void)testOffBackgroundPictureOnStatus {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.offImage = self.image;
  theSwitch.on = YES;

  XCTAssertNotEqualObjects(theSwitch.backgroundImageView.image, self.image);
}

- (void)testResetOnColor {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.onTintColor = color;
  theSwitch.on = YES;
  theSwitch.onTintColor = nil;

  XCTAssertNotEqualObjects(theSwitch.backgroundColor, color);
}

- (void)testResetOffColor {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.offTintColor = color;
  theSwitch.on = NO;
  theSwitch.offTintColor = nil;

  XCTAssertNotEqualObjects(theSwitch.backgroundColor, color);
}

- (void)testResetOnBackgroundPicture {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.onImage = self.image;
  theSwitch.on = YES;
  theSwitch.onImage = nil;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, nil);
}

- (void)testResetOffBackgroundPicture {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.offImage = self.image;
  theSwitch.on = NO;
  theSwitch.offImage = nil;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, nil);
}

- (void)testSwitchOnImage {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.offImage = self.image;
  theSwitch.onImage = self.image;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, self.image);
}

- (void)testSwitchOnImageOffOnly {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.offImage = self.image;
  theSwitch.onImage = nil;

  XCTAssertNil(theSwitch.backgroundColor);
}

- (void)testSwitchChangeImage {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onImage = self.image;
  theSwitch.onImage = self.image;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, self.image);
}

- (void)testSwitchRemoveImage {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onImage = self.image;
  theSwitch.onImage = nil;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, nil);
}

- (void)testSwitchRemoveImageWithColors {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onTintColor = [UIColor greenColor];
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.onImage = self.image;
  theSwitch.onImage = nil;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, nil);
}

- (void)testSwitchSetOffImageWhenOn {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.offImage = self.image;

  XCTAssertEqualObjects(theSwitch.backgroundImageView.image, nil);
}

- (void)testSwitchOffTintColorOffSwitch {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = NO;
  theSwitch.offTintColor = [UIColor blueColor];

  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor blueColor]);
}

- (void)testChangeSwitchValue {
  CTKSwitch *theSwitch = [[CTKSwitch alloc] init];
  theSwitch.on = NO;
  theSwitch.offTintColor = [UIColor redColor];
  [theSwitch switchValueChanged:nil];

  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testSwitchBackgroundFrame {
	CTKSwitch *theSwitch = [[CTKSwitch alloc] initWithFrame:CGRectMake(3.0f, 3.0f, 20.0f, 20.0f)];
	XCTAssertTrue(CGRectEqualToRect(theSwitch.bounds, theSwitch.backgroundImageView.bounds));
	theSwitch.frame = CGRectMake(5.0f, 5.0f, 50.0f, 50.0f);
	[theSwitch layoutIfNeeded];
	XCTAssertTrue(CGRectEqualToRect(theSwitch.bounds, theSwitch.backgroundImageView.bounds));
}

@end
