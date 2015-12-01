//
//  ViewController.h
//  ViSearchExample
//
//  Created by ViSenze on 1/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViSearchAPI.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
    IBOutlet UITextField *idSearchTextField;
    IBOutlet UITextField *colorSearchTextField;
    IBOutlet UITextField *uploadSearchUrlTextField;
    IBOutlet UICollectionView *imageCollectionView;
    UIImagePickerController *imagePicker;
    NSArray *imageList;
}

@end
