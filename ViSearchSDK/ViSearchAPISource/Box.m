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
-(id)initWithX1: (int)x1 x2: (int)x2 y1: (int)y1 y2: (int)y2{
    if(self = [super init]){
         self.x1 = x1;
         self.x2 = x2;
         self.y1 = y1;
         self.y2 = y2;
    }
    return self;
}

@end

