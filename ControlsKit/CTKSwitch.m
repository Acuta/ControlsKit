//
//  CTKSwitch.m
//  ControlsKit
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

#import "CTKSwitch.h"

#define SWITCH_WIDTH 51.0f
#define SWITCH_HEIGHT	31.0f
#define kSwitchCurveRadius 16.0f

#define RECT_FOR_ON	CGRectMake(0.0f, 0.0f, SWITCH_WIDTH, SWITCH_HEIGHT)

#define kSwitchAnimationDuration 0.2f

@interface CTKSwitch ()

@property (nonatomic, retain, readwrite) UIImageView* backgroundImage;

@property (nonatomic, strong) UIColor *onTintColorSaved;
@property (nonatomic, strong) UIColor *tintColorSaved;
@property (nonatomic, strong) UIColor *backgroundColorSaved;

@property (nonatomic, strong) UIImage* onImage;
@property (nonatomic, strong) UIImage* offImage;

@end

@implementation CTKSwitch
@synthesize onImage = _onImage;
@synthesize offImage = _offImage;
@synthesize onTintColor = _onTintColor;

- (instancetype)init {
  self = [super init];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];

  self.tintColorSaved = self.tintColor;
  self.onTintColorSaved = self.onTintColor;
  self.backgroundColorSaved = self.backgroundColor;
  
  // Trick: a Radius will be applied to the background in that case so it matches exactly the shape of the switch.
  // Allows to apply a background color when the switch is turned off (impossible otherwise).
  self.layer.cornerRadius = kSwitchCurveRadius;
  self.layer.masksToBounds = YES;
}

- (void)commonInit {
  [self setupUserInterface];
  [self addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
  [self removeTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setOn:(BOOL)on {
  [super setOn:on];
  
  [self updateDesign];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
  [super setOn:on animated:animated];
  
  [self updateDesign];
}

- (void)setupUserInterface {
  UIImageView *background = [[UIImageView alloc] initWithFrame:RECT_FOR_ON];
  background.contentMode = UIViewContentModeScaleAspectFit;
  self.backgroundImage = background;
  
  [self addSubview:self.backgroundImage];
  [self sendSubviewToBack:self.backgroundImage];
  
  [self updateDesign];
}

- (void)updateDesign {
  if (self.on) {
    if (self.onImage != nil) {
      self.onTintColor = [UIColor clearColor];
      [UIView transitionWithView:self.backgroundImage
                        duration:kSwitchAnimationDuration
                         options:UIViewAnimationOptionTransitionCrossDissolve
                      animations:^{
                        self.backgroundImage.image = self.onImage;
                      } completion:nil];
    } else {
      self.backgroundImage.image = nil;
      [self updateColorsOn];
    }
  } else {
    if (self.offImage != nil) {
      [UIView transitionWithView:self.backgroundImage
                        duration:kSwitchAnimationDuration
                         options:UIViewAnimationOptionTransitionCrossDissolve
                      animations:^{
                        self.backgroundImage.image = self.offImage;
                      } completion:nil];
    } else {
      self.backgroundImage.image = nil;
      [self updateColorsOff];
    }
  }
}

- (void)switchValueChanged:(id)sender {
  [self updateDesign];
}

#pragma mark - Update colors methods

- (void)updateColorsOn {
  self.backgroundColor = self.onTintColor;
}

- (void)updateColorsOff {
  self.backgroundColor = self.offTintColor;
  self.tintColor = self.offTintColor;
}

#pragma mark - Helpers

- (void)restoreOnTintColor {
  self.onTintColor = self.onTintColorSaved;
}

- (void)restoreTintColor {
  self.tintColor = self.tintColorSaved;
}

- (void)restoreBackgroundColor {
  self.backgroundColor = self.backgroundColorSaved;
}

- (void)saveAndClearOnTintColor {
  self.onTintColorSaved = self.onTintColor;
  self.onTintColor = [UIColor clearColor];
}

- (void)saveAndClearTintColor {
  self.tintColorSaved = self.tintColor;
  self.tintColor = [UIColor clearColor];
}

- (void)saveAndClearBackgroundColor {
  self.backgroundColorSaved = self.backgroundColor;
  self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Setters

- (void)setOnImage:(UIImage *)onImage {
  _onImage = onImage;
  
  if (self.isOn) {
    self.backgroundImage.image = onImage;
    
    if (onImage == nil) {
      [self restoreOnTintColor];
      
      // Restore the border color if there is no offImage (seen only in that case), make it clear otherwise.
      if (self.offImage == nil) {
        [self restoreTintColor];
      } else {
        self.tintColor = [UIColor clearColor];
      }
      
      [self updateColorsOn];
    } else {
      // Save and make border and onTintColor clear if we are setting a new onImage.
      [self saveAndClearOnTintColor];
      [self saveAndClearTintColor];
    }
  } else {
    // Restore the border color if we are deleting the onImage, save and make it clear if we are setting a onImage. Those colors will be seen when the switch will be switched off.
    if (onImage == nil) {
      [self restoreOnTintColor];
    } else {
      [self saveAndClearOnTintColor];
    }
  }
}

- (void)setOffImage:(UIImage *)offImage {
  _offImage = offImage;
  
  if (!self.isOn) {
    self.backgroundImage.image = offImage;
    
    // If deleting the offImage, make tintColor and backgroundColor appear. Save and clear them otherwise.
    if (offImage == nil) {
      [self restoreTintColor];
      [self restoreBackgroundColor];
      
      [self updateColorsOff];
    } else {
      [self saveAndClearTintColor];
      [self saveAndClearBackgroundColor];
    }
  } else {
    [self saveAndClearTintColor];
  }
}

- (void)setOnTintColor:(UIColor *)onTintColor {
  // Save this onTintColor right away. Might be use if user requests getOnTintColor or backgroundColor.
  _onTintColor = onTintColor;
  
  // Don't udate onTintColor but save it instead if onImage is already displayed (would be overlapped by onTintColor otherwise). However, it is not necessary to prevent this update if onTintColor is clear (won't impact the way the onImage is displayed, it is even mandatory to accept updates with a clear color for a few cases).
  if (self.onImage != nil && self.isOn && onTintColor != [UIColor clearColor]) {
    self.onTintColorSaved = onTintColor;
    return;
  }
  
  // Call super constructor passing new or default onTintColor depending on its value (nil removes previous color and will set default color instead).
  if (onTintColor != nil) {
    [super setOnTintColor:onTintColor];
  } else {
    [super setOnTintColor:nil];
  }
  
  if (self.isOn) {
    // Restore border color if onImage is being deleted.
    if (self.onImage == nil && self.tintColorSaved != nil) {
      self.tintColor = self.tintColorSaved;
    }
    
    [self updateColorsOn];
  }
}

- (void)setOffTintColor:(UIColor *)offTintColor {
  _offTintColor = offTintColor;
  
  // Direct display, if offImage is being set we won't need any border color anymore.
  if (!self.isOn && self.offImage == nil) {
    [self updateColorsOff];
  } else {
    self.tintColor = [UIColor clearColor];
  }
}

#pragma mark - Overriden getters

- (UIColor *)backgroundColor {
  if (self.on) {
    return self.onTintColor;
  } else {
    return [super backgroundColor];
  }
}

@end
