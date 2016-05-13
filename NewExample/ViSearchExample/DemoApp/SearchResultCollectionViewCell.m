//
//  SearchResultCollectionViewCell.m
//  DemoApp
//
//  Created by ViSenze on 7/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "SearchResultCollectionViewCell.h"

@implementation SearchResultCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor whiteColor];
}

@end
