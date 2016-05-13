//
//  DetailViewController.h
//  DemoApp
//
//  Created by ViSenze on 14/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculateOverlay.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "DetailViewController.h"
#import "GeneralServices.h"
#import "SearchResultCollectionViewCell.h"
#import "SearchViewProtocol.h"

@interface ResultViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate,  CHTCollectionViewDelegateWaterfallLayout>

@property BOOL isCropImage;
@property UIImage *originalImage;
@property ViSearchResult *searchResults;
@property id<SearchViewProtocol> delegate;

@end
