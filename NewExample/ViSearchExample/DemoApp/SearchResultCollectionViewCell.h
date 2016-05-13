//
//  SearchResultCollectionViewCell.h
//  DemoApp
//
//  Created by ViSenze on 7/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *similarityLabel;

@end
