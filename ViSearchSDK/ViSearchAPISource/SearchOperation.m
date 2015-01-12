//
//  SearchOperation.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/19/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//

#import "SearchOperation.h"
#import "ViSearchClient.h"
static float Max_Width = 800;
static float Quality = 1.0;

@implementation SearchOperation

-(ViSearchResult*) search: (SearchParams*) params{
    return [ViSearchClient requestWithMethod:@"search" params:params.toDict];
}
-(ViSearchResult*) colorSearch: (ColorSearchParams*) params{
    return [ViSearchClient requestWithMethod:@"colorsearch" params:params.toDict];
}
-(ViSearchResult*) uploadSearch: (UploadSearchParams*) params{
    if (params.imageFile!=nil){
        float quality  = Quality;
        if(params.quality) quality = params.quality;
        float maxWidth = Max_Width;
        if(params.maxWidth) maxWidth = params.maxWidth;
        NSData * compressedImage = [self compressImage:params.imageFile maxWidth: maxWidth quality:quality];
        params.compressedImage = [UIImage imageWithData: compressedImage];
        return [ViSearchClient requestWithMethod:@"uploadsearch" image:compressedImage params:params.toDict];
    }
    else
        return [ViSearchClient requestWithMethod:@"uploadsearch" params:params.toDict];
}

- (NSData *)compressImage:(UIImage *)image maxWidth: (float)maxWidth quality: (float)quality{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = maxWidth;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth) {
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, quality);
    UIGraphicsEndImageContext();
    
    return imageData;
}


@end