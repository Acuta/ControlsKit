//
//  SwitchViewController.m
//  ControlsKitExample
//
//  Created by Bastien Falcou on 1/7/15.
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

#import "SwitchViewController.h"

@import ControlsKit;

@interface SwitchViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet CTKSwitch *customSwitch;

@property (strong, nonatomic) IBOutlet UISwitch *applyBackgroundImageSwitchOn;
@property (strong, nonatomic) IBOutlet UISwitch *applyBackgroundImageSwitchOff;

@property (strong, nonatomic) IBOutlet UISwitch *applyBackgroundColorSwitchOn;
@property (strong, nonatomic) IBOutlet UISwitch *applyBackgroundColorSwitchOff;

@property (strong, nonatomic) IBOutlet UISwitch *applyForegroundColorSwitch;

@end

@implementation SwitchViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.applyBackgroundImageSwitchOn addTarget:self action:@selector(applyBackgroundImageSwitchOnDidChange:) forControlEvents:UIControlEventValueChanged];
  [self.applyBackgroundImageSwitchOff addTarget:self action:@selector(applyBackgroundImageSwitchOffDidChange:) forControlEvents:UIControlEventValueChanged];

  [self.applyBackgroundColorSwitchOn addTarget:self action:@selector(applyBackgroundColorSwitchOnDidChange:) forControlEvents:UIControlEventValueChanged];
  [self.applyBackgroundColorSwitchOff addTarget:self action:@selector(applyBackgroundColorSwitchOffDidChange:) forControlEvents:UIControlEventValueChanged];

  [self.applyForegroundColorSwitch addTarget:self action:@selector(applyForegroundColorSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)applyBackgroundImageSwitchOnDidChange:(id)sender {
  self.customSwitch.onImage = self.applyBackgroundImageSwitchOn.isOn ? [UIImage imageNamed:@"Switch-On-Background-Example"] : nil;
}

- (void)applyBackgroundImageSwitchOffDidChange:(id)sender {
  self.customSwitch.offImage = self.applyBackgroundImageSwitchOff.isOn ? [UIImage imageNamed:@"Switch-Off-Background-Example"] : nil;
}

- (void)applyBackgroundColorSwitchOnDidChange:(id)sender {
  self.customSwitch.onTintColor = self.applyBackgroundColorSwitchOn.isOn ? [UIColor yellowColor] : nil;
}

- (void)applyBackgroundColorSwitchOffDidChange:(id)sender {
  self.customSwitch.offTintColor = self.applyBackgroundColorSwitchOff.isOn ? [UIColor redColor] : nil;
}

- (void)applyForegroundColorSwitchDidChange:(id)sender {
  self.customSwitch.thumbTintColor = self.applyForegroundColorSwitch.isOn ? [UIColor blackColor] : nil;
}

@end
