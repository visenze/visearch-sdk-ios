//
//  DetailViewController.h
//  VisenzeDemo
//
//  Created by ViSenze on 30/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralServices.h"
#import "SearchResultCollectionViewCell.h"

@interface DetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property ImageResult *imageResult;

@end
