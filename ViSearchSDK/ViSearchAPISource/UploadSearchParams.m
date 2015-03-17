//
//  UploadSearchParams.m
//  ViSearch-iOS-SDK
//
//  Created by Shaohuan on 12/18/14.
//
//

#import "UploadSearchParams.h"


@implementation UploadSearchParams

@synthesize imageUrl, imageFile, box, compressedImage;

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

- (NSData *)httpPostBodyWithObject:(id)object {
    NSString *boundary = [object objectForKey:@"boundary"];
    
    float myQuality = self.settings.quality;
    float myMaxWidth = (self.settings.maxWidth > 1024) ? 1024 : self.settings.maxWidth; // maxWidth should not larger than 1024
    
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

- (NSData *)compressImage:(UIImage *)image maxWidth:(float)mWidth quality:(float)myQuality{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
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
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, myQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
}
@end