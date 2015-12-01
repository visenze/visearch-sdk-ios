//
//  ImageSettings.h
//  ViSearch
//
//  Created by Yaoxuan on 3/16/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ImageSettings;
@interface ImageSettings : NSObject

@property CGFloat maxWidth;
@property CGFloat quality;

+ (ImageSettings *)defaultSettings;
+ (ImageSettings *)highqualitySettings;

- (ImageSettings *)initWithSize:(CGSize)size Quality:(CGFloat) quality;

@end
