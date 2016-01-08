//
//  PreviewViewController.h
//  DemoApp
//
//  Created by ViSenze on 10/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#import "SearchViewProtocol.h"
#import "CoreDataModel.h"
#import "ResultViewController.h"

@interface PreviewViewController : UIViewController<SearchViewProtocol>

@property (nonatomic) UIImage *uploadImage;
@property (nonatomic) BOOL isFromCamera;

@end
