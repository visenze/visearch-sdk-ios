//
//  UploadSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import "UploadSearchParams.h"


@implementation UploadSearchParams

@synthesize imageUrl, imageFile, box, compressedImage, imId, detectionLimit, detectionSensitivity, resultLimit;

#pragma mark Protected

- (id)init {
    if (self = [super init]) {
        self.settings = [ImageSettings defaultSettings];
    }
    
    return self;
}

- (NSDictionary *)toDict{
    NSDictionary * dict = [super toDict];
    if (imageFile != nil){
        if (box) {
            if (compressedImage) {
                CGFloat scale = (compressedImage.size.height > compressedImage.size.width) ? compressedImage.size.height * compressedImage.scale / (self.imageFile.size.height * self.imageFile.scale) : compressedImage.size.width * compressedImage.scale / (self.imageFile.size.width * self.imageFile.scale);
                [dict setValue: [NSString stringWithFormat:@"%d,%d,%d,%d", (int)(scale * box.x1), (int)(scale * box.y1), (int)(scale * box.x2), (int)(scale * box.y2)]  forKey:@"box"];
            } else {
                [dict setValue: [NSString stringWithFormat:@"%d,%d,%d,%d", box.x1, box.y1, box.x2, box.y2]  forKey:@"box"];
            }
        }
    }else if (imageUrl != nil) {
        [dict setValue:imageUrl forKey:@"im_url"];
    }else if (imId) {
        [dict setValue:imId forKey:@"im_id"];
    }
    
    if (detectionLimit > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", detectionLimit] forKey:@"detection_limit"];
    }
    
    if (resultLimit > 0) {
        [dict setValue:[NSString stringWithFormat:@"%d", resultLimit] forKey:@"result_limit"];
    }
    
    if (detectionSensitivity!=nil) {
        [dict setValue:detectionSensitivity forKey:@"detection_sensitivity"] ;
    }
    
    return dict;
}

- (NSData *)httpPostBodyWithObject:(id)object {
    NSString *boundary = [object objectForKey:@"boundary"];
    
    float myQuality = self.settings.quality;
    float myMaxWidth = (self.settings.maxWidth > 1024) ? 1024: self.settings.maxWidth; // maxWidth should not larger than 1024pixel
    
    //compress uiimage into nsdata
    NSData *imageData = [self compressImage:self.imageFile maxWidth:myMaxWidth quality:myQuality];
    self.compressedImage = [UIImage imageWithData: imageData];
    
    // post body
    NSMutableData *body = [[NSMutableData alloc] init];
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}

#pragma mark Private

// all calculated in pixel not in point
- (NSData *)compressImage:(UIImage *)image maxWidth:(float)mWidth quality:(float)myQuality{
    float actualHeight = image.size.height * image.scale;
    float actualWidth = image.size.width * image.scale;
    float maxHeight = mWidth;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = mWidth/maxHeight;
    
    if (actualHeight > maxHeight || actualWidth > mWidth) {
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = self.settings.maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = mWidth;
        }else{
            actualHeight = maxHeight;
            actualWidth = mWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, myQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
}
@end
