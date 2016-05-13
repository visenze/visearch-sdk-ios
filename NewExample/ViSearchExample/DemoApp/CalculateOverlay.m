//
//  CalculateOverlay.m
//  VisenzeDemo
//
//  Created by Sai on 6/6/15.
//  Copyright (c) 2015 Visenze. All rights reserved.
//

#import "CalculateOverlay.h"

@implementation CalculateOverlay

- (void)drawRect:(CGRect)rect {
    [[UIColor scalerShadowColor] setFill];
    CGRect area = CGRectMake((rect.size.width - self.drawArea.size.width)/2,
                             (rect.size.height - self.drawArea.size.height)/2,
                             self.drawArea.size.width,
                             self.drawArea.size.height);
    UIRectFill(area);
    
    [[UIColor clearColor] setFill];
    CGRect clearArea = CGRectMake(self.scaleView.frame.origin.x + EXTRA_DISTANCE,
                                  self.scaleView.frame.origin.y + EXTRA_DISTANCE,
                                  self.scaleView.frame.size.width - 2*EXTRA_DISTANCE,
                                  self.scaleView.frame.size.height - 2*EXTRA_DISTANCE);
    UIRectFill(clearArea);

    [self.scaleView setNeedsDisplay];
}

@end
