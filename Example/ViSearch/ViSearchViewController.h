//
//  ViSearchViewController.h
//  ViSearch
//
//  Created by Shaohuan Li on 01/08/2015.
//  Copyright (c) 2014 Shaohuan Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViSearchAPI.h"

@interface ViSearchViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    IBOutlet UITextField *idSearchTextField;
    IBOutlet UITextField *colorSearchTextField;
    IBOutlet UITextField *uploadSearchUrlTextField;
    IBOutlet UITextView *returnedText;
    UIImagePickerController *imagePicker;
}

@end
