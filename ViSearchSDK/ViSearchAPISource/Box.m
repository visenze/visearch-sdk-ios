//
//  Box.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import "Box.h"

@implementation Box

@synthesize x1, x2, y1, y2;
-(Box *) initWithX1:(int)_x1 y1:(int)_y1 x2:(int)_x2 y2:(int)_y2 {
    if (self = [super init]) {
        self.x1 = _x1;
        self.x2 = _x2;
        self.y1 = _y1;
        self.y2 = _y2;
    }
    return self;
}

@end