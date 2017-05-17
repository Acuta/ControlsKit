//
//  CTKNibView.h
//  ControlsKit
//
//  Created by Stéphane Copin on 12/7/12.
//  Copyright © 2012 Stéphane Copin. All rights reserved.
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
 *  Subclass this class to use
 *  @note
 *  Instructions:
 *  - Subclass this class
 *  - Associate it with a nib via File's Owner (Whose name is defined by [-nibName])
 *  - Bind contentView to the root view of the nib
 *  - Then you can insert it either in code or in a xib/storyboard, your choice
 */
@interface CTKNibView : UIView

@property (strong, nonatomic, readonly) IBOutlet UIView *contentView;

/**
 *  Is called when the nib name associated with the class is going to be loaded.
 *
 *  @return The nib name (Default implementation returns class name: `NSStringFromClass([self class])`, without the module name if using Swift modules)
 *  You will want to override this method in swift as the class name is prefixed with the module in that case
 */
@property (nonatomic, copy, readonly) NSString * nibName;

/**
 *  Called when first loading the nib.
 *  Defaults to `[NSBundle bundleForClass:[self class]]`
 *
 *  @return The bundle in which to find the nib.
 */
@property (nonatomic, copy, readonly, nullable) NSBundle * nibBundle;

/**
 *  Use the 2 methods above to instanciate the correct instance of UINib for the view.
 *  You can override this if you need more customization.
 *
 *  @return An instance of UINib
 */
@property (nonatomic, copy, readonly) UINib * nib;

@end

NS_ASSUME_NONNULL_END
