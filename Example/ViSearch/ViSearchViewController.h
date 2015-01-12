//
//  ViSearchViewController.h
//  ViSearch
//
//  Created by Shaohuan Li on 01/08/2015.
//  Copyright (c) 2014 Shaohuan Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViSearchAPI.h"

@interface ViSearchViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
    IBOutlet UITextField *idSearchTextField;
    IBOutlet UITextField *colorSearchTextField;
    IBOutlet UITextField *uploadSearchUrlTextField;
    IBOutlet UITextView *returnedText;
    IBOutlet UICollectionView *imageCollectionView;
    UIImagePickerController *imagePicker;
    NSArray *imageList;
}

@end
