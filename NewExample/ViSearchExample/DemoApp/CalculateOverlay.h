//
//  CalculateOverlay.h
//  VisenzeDemo
//
//  Created by Sai on 6/6/15.
//  Copyright (c) 2015 Visenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScaleUIView.h"

@interface CalculateOverlay : UIView

@property (strong, nonatomic) ScaleUIView* scaleView;
@property (nonatomic) CGRect drawArea;

@end
