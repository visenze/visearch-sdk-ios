//
//  ImageSettings.m
//  ViSearch
//
//  Created by Yaoxuan on 3/16/15.
//  Copyright (c) 2015 Shaohuan Li. All rights reserved.
//

#import "ImageSettings.h"

@implementation ImageSettings

+ (ImageSettings *)defaultSettings {
    ImageSettings *settings = [ImageSettings new];
    settings.quality = 0.97;
    settings.maxWidth = 512;
    
    return settings;
}

+ (ImageSettings *)highqualitySettings {
    ImageSettings *settings = [ImageSettings new];
    settings.quality = 0.985;
    settings.maxWidth = 1024;
    
    return settings;
}

- (ImageSettings *)initWithSize:(CGSize)size Quality:(CGFloat)quality_ {
    if (self = [super init]) {
        self.quality = quality_;
        self.maxWidth = (size.height > size.width) ? size.height : size.width;
    }
    
    return self;
}

@end
