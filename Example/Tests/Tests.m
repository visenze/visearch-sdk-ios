//
//  ViSearchTests.m
//  ViSearchTests
//
//  Created by Shaohuan Li on 01/08/2015.
//  Copyright (c) 2014 Shaohuan Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViSearchAPI.h"

@interface ViSearchTests : XCTestCase

@end

@implementation ViSearchTests

- (void)setUp {
    [super setUp];
    [ViSearchAPI setupAccessKey:@"" andSecretKey:@""];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
}

- (void)testColorSearch {
    ColorSearchParams *colorSearchParams = [[ColorSearchParams alloc] init];
    colorSearchParams.color = @"012ACF";
    colorSearchParams.fl = @[@"price",@"brand",@"im_url"];
    
    __block int flag = 1;
    
    [[ViSearchAPI defaultClient] searchWithColor:colorSearchParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"color search test success");
        NSLog(@"%@",data.content);
        flag = 0;
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"color search test fail");
        NSLog(@"%@",data);
        flag = 0;
    }];
    
    
    
    while (flag);
}

- (void)testProductIdTest {
    SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.imName = @"nordstrom-86782956";
    searchParams.fl = @[@"price",@"brand",@"im_url"];
    
    __block int flag = 1;
    [[ViSearchAPI defaultClient] searchWithProductId:searchParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"product search test success");
        NSLog(@"%@",data.imageResultsArray);
        flag = 0;
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"product search test fail");
        NSLog(@"%@",data);
        flag = 0;
    }];
    
    while (flag);
}

- (void)testImageUrlSearchTest {
    UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
    uploadSearchParams.imageUrl = @"http://img.romwe.com/images/romwe.com/201501/1421045058343536994.jpg";
    uploadSearchParams.settings = [[ImageSettings alloc] initWithSize:CGSizeMake(800, 800) Quality:1.0];
    
    __block int flag = 1;
    [[ViSearchAPI defaultClient] searchWithImageUrl:uploadSearchParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"image url search test success");
        NSLog(@"%@",data.imageResultsArray);
        flag = 0;
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"image url search test fail");
        NSLog(@"%@",data);
        flag = 0;
    }];
    
    while (flag);
}

- (void)testImageDataSearchTest {
    UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
    uploadSearchParams.fl = @[@"price",@"brand",@"im_url"];
    uploadSearchParams.score = YES;
    uploadSearchParams.imageFile = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img.romwe.com/images/romwe.com/201501/1421045058343536994.jpg"]]];

    
    uploadSearchParams.box = [[Box alloc] initWithX1:0 y1:0 x2:0 y2:0];
    [uploadSearchParams.fq setObject:@"price" forKey:@"0.0, 199.0"];

    __block int flag = 1;
    [[ViSearchAPI defaultClient] searchWithImageData:uploadSearchParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"image data search test success");
        NSLog(@"%@",data.content);
        flag = 0;
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        NSLog(@"image data search test fail");
        NSLog(@"%@",data);
        flag = 0;
    }];
    
    while (flag);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

