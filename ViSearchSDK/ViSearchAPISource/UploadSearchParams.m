//
//  UploadSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import "UploadSearchParams.h"

@implementation UploadSearchParams

@synthesize imageUrl, imageFile, box;

- (NSDictionary *)toDict{
    NSDictionary * dict = [super toDict];
    if (box != nil) {
        if (box.x1 && box.x2 && box.y1 && box.y2) {
            [dict setValue: [NSString stringWithFormat:@"%d,%d,%d,%d", box.x1, box.y1, box.x2, box.y2]  forKey:@"box"];
        }
    }
    if (imageUrl != nil) {
        [dict setValue:imageUrl forKey:@"im_url"];
    }
    return dict;
}

@end