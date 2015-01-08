//
//  UploadSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import "UploadSearchParams.h"

@implementation UploadSearchParams

@synthesize imageUrl, imageFile, box, maxWidth, quality, compressedImage;

- (NSDictionary *)toDict{
    NSDictionary * dict = [super toDict];
    if (imageFile != nil){
        if ((box != nil)&&(box.x1 && box.x2 && box.y1 && box.y2)) {
            if (compressedImage != nil)
                [dict setValue: [NSString stringWithFormat:@"%d,%d,%d,%d", (int)(box.x1*compressedImage.size.width/imageFile.size.width), (int)(box.y1*compressedImage.size.height/imageFile.size.height), (int)(box.x2*compressedImage.size.width/imageFile.size.width), (int)(box.y2*compressedImage.size.height/imageFile.size.height)]  forKey:@"box"];
            else
                [dict setValue: [NSString stringWithFormat:@"%d,%d,%d,%d", box.x1, box.y1, box.x2, box.y2]  forKey:@"box"];
        }
    }else if (imageUrl != nil) {
        [dict setValue:imageUrl forKey:@"im_url"];
    }
    return dict;
}

@end