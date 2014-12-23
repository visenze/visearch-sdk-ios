//
//  ViewController.h
//  Demo
//
//  Created by Shaohuan on 12/19/14.
//  Copyright (c) 2014 ViSenze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViSearchAPI.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    IBOutlet UITextField *idSearchTextField;
    IBOutlet UITextField *colorSearchTextField;
    IBOutlet UITextField *uploadSearchUrlTextField;
    IBOutlet UITextView *returnedText;
    UIImagePickerController *imagePicker;
}

@end