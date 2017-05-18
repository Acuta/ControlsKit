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

#define kSwitchAnimationDuration 0.2f

@interface CTKSwitch ()

@property (nonatomic, retain, readwrite) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImage *onImage;
@property (nonatomic, strong) UIImage *offImage;

@end

@implementation CTKSwitch
@synthesize onImage = _onImage;
@synthesize offImage = _offImage;
@synthesize onTintColor = _onTintColor;

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self ctk_commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self ctk_commonInit];
	}
	return self;
}

- (void)ctk_commonInit {
	_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	_backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;

	[self insertSubview:_backgroundImageView atIndex:0];

	// Trick: a Radius will be applied to the background in that case so it matches exactly the shape of the switch.
	// Allows to apply a background color when the switch is turned off (impossible otherwise).
	self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f;
	self.layer.masksToBounds = YES;

	[self addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

	[self updateState];
}

- (void)dealloc {
	[self removeTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setOn:(BOOL)on {
	[super setOn:on];

	[self updateState];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
	[super setOn:on animated:animated];

	[self updateStateAnimated:animated];
}

- (void)switchValueChanged:(id)sender {
	[self updateState];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	self.backgroundImageView.frame = self.bounds;
}

#pragma mark - Setters

- (void)setOnImage:(UIImage *)onImage {
	_onImage = onImage;

	[self updateState];
}

- (void)setOffImage:(UIImage *)offImage {
	_offImage = offImage;

	[self updateState];
}

- (void)setOnTintColor:(UIColor *)onTintColor {
	_onTintColor = onTintColor;

	[self updateState];
}

- (void)setOffTintColor:(UIColor *)offTintColor {
	_offTintColor = offTintColor;

	[self updateState];
}

#pragma mark - Overriden getters

- (UIColor *)backgroundColor {
	if (self.isOn) {
		return self.onTintColor;
	}
	return [super backgroundColor];
}

#pragma mark - Helper methods

- (void)updateState {
	[self updateStateAnimated:NO];
}

- (void)updateStateAnimated:(BOOL)animated {
	if (self.isOn) {
		[super setOnTintColor:self.onImage != nil ? [UIColor clearColor] : self.onTintColor];
	} else {
		self.backgroundColor = self.offImage != nil ? [UIColor clearColor] : self.offTintColor;
		self.tintColor = self.backgroundColor;
	}

	[UIView transitionWithView:self.backgroundImageView
										duration:animated ? kSwitchAnimationDuration : 0.0f
										 options:UIViewAnimationOptionTransitionCrossDissolve
									animations:^{
										self.backgroundImageView.image = self.isOn ? self.onImage : self.offImage;
									}
									completion:nil];
}

@end
