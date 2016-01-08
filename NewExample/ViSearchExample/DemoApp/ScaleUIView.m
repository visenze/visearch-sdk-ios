//
//  ScaleUIView.m
//  VisenzeDemo
//
//  Created by Yaoxuan on 29/4/15.
//  Copyright (c) 2015 Visenze. All rights reserved.
//

#import "ScaleUIView.h"

@implementation ScaleUIView

- (void)drawRect:(CGRect)rect {
    [[UIColor scalerBorderColor] setFill];
    UIRectFill(CGRectMake(EXTRA_DISTANCE,
                          EXTRA_DISTANCE,
                          rect.size.width - 2*EXTRA_DISTANCE,
                          rect.size.height - 2*EXTRA_DISTANCE));
    
    [[UIColor clearColor] setFill];
    UIRectFill(CGRectMake(SCALE_VIEW_BORDER_WIDTH + EXTRA_DISTANCE,
                          SCALE_VIEW_BORDER_WIDTH + EXTRA_DISTANCE,
                          rect.size.width - (SCALE_VIEW_BORDER_WIDTH + EXTRA_DISTANCE)*2,
                          rect.size.height - (SCALE_VIEW_BORDER_WIDTH + EXTRA_DISTANCE)*2));
    
    UIRectFill(CGRectMake(SCALER_VIEW_LENGTH + EXTRA_DISTANCE,
                          EXTRA_DISTANCE,
                          self.frame.size.width - (SCALER_VIEW_LENGTH + EXTRA_DISTANCE)*2,
                          SCALE_VIEW_BORDER_WIDTH + 2));
    
    UIRectFill(CGRectMake(SCALER_VIEW_LENGTH + EXTRA_DISTANCE,
                          self.frame.size.height - SCALE_VIEW_BORDER_WIDTH - EXTRA_DISTANCE - 2,
                          self.frame.size.width - (SCALER_VIEW_LENGTH + EXTRA_DISTANCE)*2,
                          SCALE_VIEW_BORDER_WIDTH + 2));
    
    UIRectFill(CGRectMake(EXTRA_DISTANCE,
                          SCALER_VIEW_LENGTH + EXTRA_DISTANCE,
                          SCALE_VIEW_BORDER_WIDTH + 2,
                          self.frame.size.height - (SCALER_VIEW_LENGTH + EXTRA_DISTANCE)*2));
    
    UIRectFill(CGRectMake(self.frame.size.width - SCALE_VIEW_BORDER_WIDTH - EXTRA_DISTANCE - 2,
                          SCALER_VIEW_LENGTH + EXTRA_DISTANCE,
                          SCALE_VIEW_BORDER_WIDTH + 2,
                          self.frame.size.height - (SCALER_VIEW_LENGTH + EXTRA_DISTANCE)*2));
}

@end
