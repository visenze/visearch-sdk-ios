//
//  DemoAppTests.m
//  DemoAppTests
//
//  Created by ViSenze on 4/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViSearchAPI.h"

@interface DemoAppTests : XCTestCase

@end

@implementation DemoAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testPerformanceImageUploadExample {
    // This is an example of a performance test case.
    
    [self measureBlock:^{
        XCTestExpectation *expectation = [self expectationWithDescription:@"async"];
        __block int count = 0;
        // Put the code you want to measure the time of here.
        for (int i = 1 ; i < 2; i++) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"%d",i] ofType:@"jpg"];
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            
            UploadSearchParams *params = [UploadSearchParams new];
            params.imageFile = image;
            params.settings = [ImageSettings highqualitySettings];
            params.fl = @[@"im_url"];
            params.detection = @"all";
            [[ViSearchClient sharedInstance] searchWithImageData:params success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
                count++;
                NSLog(@"%@",data.imId);
                
                UploadSearchParams *params = [UploadSearchParams new];
                params.imId = data.imId;
                params.settings = [ImageSettings highqualitySettings];
                params.fl = @[@"im_url"];
                params.detection = @"all";
                
                [[ViSearchClient sharedInstance] searchWithImageData:params success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
                    NSLog(@"%@",data.imId);
                } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
                    
                }];
                
                CGFloat longerSide = MAX(params.compressedImage.size.height, params.compressedImage.size.width);
                assert(longerSide <= 1024);
                
                if (count == 1) {
                    [expectation fulfill];
                }
                NSLog(@"%@", data);
            } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
                count++;
                if (count == 10) {
                    [expectation fulfill];
                }
            }];
        }
        
        [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
            if (error) {
                NSLog(@"Time out error %@", error);
            }
        }];
    }];
}

@end
