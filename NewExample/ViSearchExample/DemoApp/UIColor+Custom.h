//
//  UIColor+Custom.h
//  VisenzeDemo
//
//  Created by ViSenze on 24/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Custom)

+ (NSArray *)animationColors;

+ (UIColor *)detectionNormalColor;
+ (UIColor *)detectionSelectedColor;
+ (UIColor *)cropButtonBorderColor;
+ (UIColor *)scalerBorderColor;
+ (UIColor *)scalerShadowColor;

+ (UIColor *)qrListBackgroundColor;
+ (UIColor *)qrListDeleteColor;
+ (UIColor *)qrScannerBorderColor;
+ (UIColor *)qrcodeTextColor;
+ (UIColor *)accountApplicationTextColor;

@end
