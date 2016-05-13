//
//  UIColor+Custom.m
//  VisenzeDemo
//
//  Created by ViSenze on 24/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "UIColor+Custom.h"

@implementation UIColor (Custom)

#pragma mark - Home View
+ (NSArray *)animationColors {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    UIColor *color = [UIColor colorWithRed:119.0/256.0
                                     green:136.0/256.0
                                      blue:153.0/256.0
                                     alpha:0.5];
    [array addObject:color];
    
    color = [UIColor colorWithRed:173.0/256.0
                            green:153.0/256.0
                             blue:0/256.0
                            alpha:0.5];
    [array addObject:color];
    
    color = [UIColor colorWithRed:80.0/256.0
                            green:179.0/256.0
                             blue:205.0/256.0
                            alpha:0.5];
    [array addObject:color];
    
    color = [UIColor colorWithRed:200.0/256.0
                            green:75.0/256.0
                             blue:98.0/256.0
                            alpha:0.5];
    [array addObject:color];
    
    return array;
}

#pragma mark - Detail View
+ (UIColor *)detectionNormalColor {
    return [UIColor colorWithRed:31.0/256.0
                           green:31.0/256.0
                            blue:31.0/256.0
                           alpha:1.0];
}

+ (UIColor *)detectionSelectedColor {
    return [UIColor colorWithRed:200.0/256.0
                           green:75.0/256.0
                            blue:98.0/256.0
                           alpha:1.0];
}

+ (UIColor *)cropButtonBorderColor {
    return [UIColor colorWithRed:193.0/256.0
                           green:60.0/256.0
                            blue:48.0/256.0
                           alpha:1.0];
}

+ (UIColor *)scalerBorderColor {
    return [UIColor colorWithRed:80.0/256.0
                           green:179.0/256.0
                            blue:205.0/256.0
                           alpha:1.0];
}

+ (UIColor *)scalerShadowColor {
    return [UIColor colorWithRed:64.0 / 255.0
                           green:64.0 / 255.0
                            blue:64.0 / 255.0
                           alpha:0.8];
}


#pragma mark - QR code
+ (UIColor *)qrListBackgroundColor {
    return [UIColor colorWithRed:56.0/256.0
                           green:161.0/256.0
                            blue:161.0/256.0
                           alpha:1];
}

+ (UIColor *)qrListDeleteColor {
    return [UIColor colorWithRed:200.0/256.0
                           green:75.0/256.0
                            blue:98.0/256.0
                           alpha:1.0];
}

+ (UIColor *)qrScannerBorderColor {
    return [UIColor colorWithRed:173.0/256.0
                           green:153.0/256.0
                            blue:0/256.0
                           alpha:1.0];
}

+ (UIColor *)qrcodeTextColor {
    return [UIColor colorWithRed:130.0/256.0
                           green:101.0/256.0
                            blue:43/256.0
                           alpha:1.0];
}

+ (UIColor *)accountApplicationTextColor {
    return [UIColor colorWithRed:198.0/256.0
                           green:196.0/256.0
                            blue:214.0/256.0
                           alpha:1.0];
}

@end
