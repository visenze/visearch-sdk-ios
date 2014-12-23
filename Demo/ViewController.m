//
//  ViewController.m
//  Demo
//
//  Created by Shaohuan on 12/19/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [ViSearchAPI initWithAccessKey: @"" andSecretKey:@""];
}
- (IBAction)idSearch:(id)sender {
    SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.imName = idSearchTextField.text;
    // searchParams.fl = @[@"price",@"brand",@"im_url"];
    ViSearchResult *visenzeResult = [[ViSearchAPI search] search:searchParams];
    if(([visenzeResult.content objectForKey:@"status"]!=nil)&&([[visenzeResult.content objectForKey:@"status"] isEqualToString:@"OK"])){
        NSArray *imageList = [visenzeResult.content objectForKey:@"result"];
        for (NSDictionary *obj in imageList){
            NSLog(@"im_name: %@", [obj objectForKey:@"im_name"]);
    //      NSLog(@"value_map: %@", [[obj objectForKey:@"value_map"] objectForKey:@"im_url"]);
        }
    }
}
- (IBAction)colorSearch:(id)sender {
    ColorSearchParams *colorSearchParams = [[ColorSearchParams alloc] init];
    colorSearchParams.color = colorSearchTextField.text;
    // searchParams.fl = @[@"price",@"brand",@"im_url"];
    ViSearchResult *visenzeResult = [[ViSearchAPI search] colorSearch:colorSearchParams];
    if(([visenzeResult.content objectForKey:@"status"]!=nil)&&([[visenzeResult.content objectForKey:@"status"] isEqualToString:@"OK"])){
        NSArray *imageList = [visenzeResult.content objectForKey:@"result"];
        for (NSDictionary *obj in imageList){
            NSLog(@"im_name: %@", [obj objectForKey:@"im_name"]);
            //      NSLog(@"value_map: %@", [[obj objectForKey:@"value_map"] objectForKey:@"im_url"]);
        }
    }
}
- (IBAction)uploadSearchURL:(id)sender {
    UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
    uploadSearchParams.imageUrl = uploadSearchUrlTextField.text;
    // searchParams.fl = @[@"price",@"brand",@"im_url"];
    ViSearchResult *visenzeResult = [[ViSearchAPI search] uploadSearch:uploadSearchParams];
    if(([visenzeResult.content objectForKey:@"status"]!=nil)&&([[visenzeResult.content objectForKey:@"status"] isEqualToString:@"OK"])){
        NSArray *imageList = [visenzeResult.content objectForKey:@"result"];
        for (NSDictionary *obj in imageList){
            NSLog(@"im_name: %@", [obj objectForKey:@"im_name"]);
            //      NSLog(@"value_map: %@", [[obj objectForKey:@"value_map"] objectForKey:@"im_url"]);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end