//
//  PageControlViewController.m
//  ControlsKitExample
//
//  Created by Bastien Falcou on 1/9/15.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
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

#import "PageControlViewController.h"

@import ControlsKit;

#define kPageControlDotsMinSpace 3.0f
#define kPageControlDotsMaxSpace 20.0f
#define kPageControlDotsSpaceDefaultValue 6.0f

#define kNumberOfDotsMinValue 1
#define kNumberOfDotsMaxValue 10
#define kNumberOfDotsDefaultValue 5

@interface PageControlViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet CTKPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UISwitch *setCustomDotsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *setCustomColorsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *updateDotsImmediatelySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hideDotIfOnlyOneSwitch;
@property (weak, nonatomic) IBOutlet UISlider *dotsSpaceSlider;
@property (weak, nonatomic) IBOutlet UILabel *dotsSpaceCurrentValueLabel;
@property (weak, nonatomic) IBOutlet UIStepper *numberOfDotsStepper;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDotsCurrentValueLabel;

@end

@implementation PageControlViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.setCustomDotsSwitch addTarget:self action:@selector(setCustomDotsSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
  [self.setCustomColorsSwitch addTarget:self action:@selector(setCustomColorsSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
  [self.updateDotsImmediatelySwitch addTarget:self action:@selector(updateDotsImmediatelySwitchDidChange:) forControlEvents:UIControlEventValueChanged];
  [self.hideDotIfOnlyOneSwitch addTarget:self action:@selector(hideDotIfOnlyOneSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
  
  [self.dotsSpaceSlider addTarget:self action:@selector(dotsSpaceSliderDidChange:) forControlEvents:UIControlEventValueChanged];
  self.dotsSpaceSlider.minimumValue = kPageControlDotsMinSpace;
  self.dotsSpaceSlider.maximumValue = kPageControlDotsMaxSpace;
  self.dotsSpaceSlider.value = kPageControlDotsSpaceDefaultValue;
  self.dotsSpaceCurrentValueLabel.text = [NSString stringWithFormat:@"%.2f", self.dotsSpaceSlider.value];
  
  [self.numberOfDotsStepper addTarget:self action:@selector(numberOfDotsStepperDidChange:) forControlEvents:UIControlEventValueChanged];
  self.numberOfDotsStepper.minimumValue = kNumberOfDotsMinValue;
  self.numberOfDotsStepper.maximumValue = kNumberOfDotsMaxValue;
  self.numberOfDotsStepper.value = kNumberOfDotsDefaultValue;
  self.numberOfDotsCurrentValueLabel.text = [NSString stringWithFormat:@"%.0f", self.numberOfDotsStepper.value];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self setupColorViewsToDisplay];
}

- (void)setCustomDotsSwitchDidChange:(id)sender {
  if (self.setCustomDotsSwitch.isOn) {
    self.pageControl.leftDotImageActive = [UIImage imageNamed:@"Carousel-Left-Active"];
    self.pageControl.leftDotImageInactive = [UIImage imageNamed:@"Carousel-Left-Inactive"];
    
    self.pageControl.middleDotImageActive = [UIImage imageNamed:@"Carousel-Middle-Active"];
    self.pageControl.middleDotImageInactive = [UIImage imageNamed:@"Carousel-Middle-Inactive"];
    
    self.pageControl.rightDotImageActive = [UIImage imageNamed:@"Carousel-Right-Active"];
    self.pageControl.rightDotImageInactive = [UIImage imageNamed:@"Carousel-Right-Inactive"];
  } else {
    self.pageControl.leftDotImageActive = nil;
    self.pageControl.leftDotImageInactive = nil;
    
    self.pageControl.middleDotImageActive = nil;
    self.pageControl.middleDotImageInactive = nil;
    
    self.pageControl.rightDotImageActive = nil;
    self.pageControl.rightDotImageInactive = nil;
  }
  self.setCustomColorsSwitch.enabled = !self.setCustomDotsSwitch.isOn;
}

- (void)setCustomColorsSwitchDidChange:(id)sender {
  if (self.setCustomColorsSwitch.isOn) {
    self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25f];
    self.pageControl.currentPageIndicatorTintColor = self.view.tintColor;
  } else {
    self.pageControl.pageIndicatorTintColor = nil;
    self.pageControl.currentPageIndicatorTintColor = nil;
  }
}

- (void)updateDotsImmediatelySwitchDidChange:(id)sender {
  if (self.updateDotsImmediatelySwitch.isOn) {
    self.pageControl.defersCurrentPageDisplay = NO;
    [self.pageControl updateCurrentPageDisplay];
  } else {
    self.pageControl.defersCurrentPageDisplay = YES;
  }
}

- (void)hideDotIfOnlyOneSwitchDidChange:(id)sender {
  self.pageControl.hidesForSinglePage = self.hideDotIfOnlyOneSwitch.isOn;
}

- (void)dotsSpaceSliderDidChange:(id)sender {
  self.pageControl.dotsSpace = self.dotsSpaceSlider.value;
  self.dotsSpaceCurrentValueLabel.text = [NSString stringWithFormat:@"%.2f", self.dotsSpaceSlider.value];
}

- (void)numberOfDotsStepperDidChange:(id)sender {
  self.pageControl.numberOfPages = self.numberOfDotsStepper.value;
  self.numberOfDotsCurrentValueLabel.text = [NSString stringWithFormat:@"%.0f", self.numberOfDotsStepper.value];
}

#pragma mark - Scrollview

- (void)setupColorViewsToDisplay {
  NSArray *colorsArray = [[NSArray alloc] initWithObjects:[UIColor orangeColor], [UIColor magentaColor], [UIColor purpleColor], [UIColor brownColor], [UIColor cyanColor], nil];
  
  self.pageControl.numberOfPages = colorsArray.count;
  
  for (NSInteger i = 0; i < [colorsArray count]; i++) {
    UIView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * i, 0.0f, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    contentView.backgroundColor = colorsArray[i];
    [self.scrollView addSubview:contentView];
  }
  
  self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * colorsArray.count, self.scrollView.frame.size.height);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  CGFloat pageWidth = self.scrollView.frame.size.width;
  NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2.0f) / pageWidth) + 1.0f;
  self.pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  CGFloat pageWidth = self.scrollView.frame.size.width;
  NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2.0f) / pageWidth) + 1.0f;
  self.pageControl.currentPage = page;
}

@end
