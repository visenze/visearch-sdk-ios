//
//  HomeViewController.m
//  DemoApp
//
//  Created by ViSenze on 4/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "HomeViewController.h"
#import "CameraViewController.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property GeneralServices *generalService;

@end

@implementation HomeViewController {
    NSMutableArray *rectangles;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    rectangles = [[NSMutableArray alloc] init];
    self.generalService = [GeneralServices sharedInstance];
    
    //TODO: insert your own application keys
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setValue:@"YOUR_ACCESS_KEY" forKey:@"access_key"];
//    [dict setValue:@"YOUR_SECRET_KEY" forKey:@"secret_key"];
  
    [[CoreDataModel sharedInstance] insertApplication:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self initAnimation];
}

- (void) initAnimation {
    if (rectangles.count < 4) {
        NSArray *colors = [UIColor animationColors];

        for (int i=0; i<4; i++) {
            UIView *view = [[UIView alloc] init];
            view.layer.borderColor = [[colors objectAtIndex:i] CGColor];
            view.layer.borderWidth = 1.0f;
            CGFloat width = self.cameraButton.frame.size.width + 10;
            CGRect frame = CGRectMake(0, 0, width/sqrt(2.0), width/sqrt(2.0));
            [view setFrame:frame];
            [view setCenter:self.cameraButton.center];
            [rectangles addObject:view];
        }
    }
    
    [self startAnimation];
}

- (void) startAnimation {
    for (int i=0; i<rectangles.count; i++) {
        UIView *view = [rectangles objectAtIndex:i];
        [self.view addSubview:view];
        [self runSpinAnimationOnView:view WithDuration:10.0 * (i+1)];
    }
    [self.view bringSubviewToFront:self.cameraButton];
}

- (void) runSpinAnimationOnView:(UIView*)view WithDuration:(CGFloat) duration {
    CABasicAnimation* rotationAnimation;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * duration];
    rotationAnimation.duration = duration * duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)alertNoApplicationSelected {
    [self.generalService showAlertViewOnViewController:self
                                             withTitle:@"No application is selected"
                                           withMessage:@"Please select an application"
                                            withButton:@"OK"
                                             withSegue:nil];

}

-(void)alertNoNetwork {
    [self.generalService showAlertViewOnViewController:self
                                             withTitle:@"No Network Available"
                                           withMessage:@"Please select a network"
                                            withButton:@"OK"
                                             withSegue:nil];
}


#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![self.generalService hasInternetConnection]) {
        [self alertNoNetwork];
        return NO;
    }
    
    if ([identifier isEqualToString:SEGUE_CAMERA]) {
        if ([[CoreDataModel sharedInstance] getApplicationInUse]) {
            return YES;
        } else {
            [self alertNoApplicationSelected];
            return NO;
        }
    }
    
    return NO;
}

@end
