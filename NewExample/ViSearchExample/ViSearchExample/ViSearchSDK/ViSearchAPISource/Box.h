//
//  Box.h
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import <Foundation/Foundation.h>

@interface Box: NSObject

@property (atomic) int x1;
@property (atomic) int x2;
@property (atomic) int y1;
@property (atomic) int y2;

-(id)initWithX1:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;
@end