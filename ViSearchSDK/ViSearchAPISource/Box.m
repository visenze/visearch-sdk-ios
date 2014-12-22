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
-(id)initWithX1: (int)x1l x2: (int)x2l y1: (int)y1l y2: (int)y2l{
    if(self = [super init]){
         self.x1 = x1l;
         self.x2 = x2l;
         self.y1 = y1l;
         self.y2 = y2l;
    }
    return self;
}

@end

