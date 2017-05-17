//
//  CTKSwitch.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This UISwitch subclass defines or redifines useful UI properties for your switches:
 *
 *   - onTintColor: color of the background when the switch is On. If set to nil, the default color (green) will be applied.
 *   - offTintColor: color of the background when the switch is Off. If set to nil, the default color (clearColor) will be applied.
 *
 *   - onImage: image in the background when the switch is On. If "onTintColor" is defined, the image will override the color (color won't be seen). If set to nil, the previous image will be deleted and the onTintColor will be seen instead.
 *   - offImage: image in the background when the switch is Off. if "offTintColor" is defined, the image will override the color (color won't be seen). If set to nil, the previous image will be deleted and the offTintColor will be seen instead.
 */

@interface CTKSwitch : UISwitch

/**
 *  Background color when the switch is turned off.
 */
@property (nonatomic, strong, nullable) IBInspectable UIColor* offTintColor;

@end

NS_ASSUME_NONNULL_END
