//
//  PreviewViewController.m
//  DemoApp
//
//  Created by ViSenze on 10/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

@property Applications *applicationInUse;
@property GeneralServices *generalService;
@property NSMutableArray *imageArray;
@property UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingView;
@property ViSearchResult *searchResult;

@end

@implementation PreviewViewController {
    NSArray *LOADING_MSG;
    NSTimer *loadingTimer;
    int imageCount;
    BOOL isCanceled;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initAll];
    [self uploadSearch];
    [self hideLoadingView];
    if (self.loadingView.hidden) {
        [self showLoadingView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - init
- (void) initAll {
    imageCount = 0;
    isCanceled = NO;
    self.generalService = [GeneralServices sharedInstance];
    LOADING_MSG = [NSArray arrayWithObjects:@"", LOADING_MSG_1, LOADING_MSG_2, LOADING_MSG_3, LOADING_MSG_4, nil];
    self.imageArray = [[NSMutableArray alloc] init];
    
    [self initApplication];
    [self initBackgroundView];
}

- (void) initApplication {
    self.applicationInUse = [[CoreDataModel sharedInstance] getApplicationInUse];
    [ViSearchAPI setupAccessKey:self.applicationInUse.access_key andSecretKey:self.applicationInUse.secret_key];
}

- (void)initBackgroundView {
    [self.imagePreview removeFromSuperview];
    
    CGRect cropRect;
    CGFloat width = self.view.frame.size.width,
    height = self.view.frame.size.height;
    CGFloat widthToHeight = self.uploadImage.size.width / self.uploadImage.size.height;
    
    if (self.isFromCamera) {
        width = height * widthToHeight;
    } else {
        height = width / widthToHeight;
    }
    
    cropRect = CGRectMake((self.view.frame.size.width-width)/2,
                          (self.view.frame.size.height - height)/2,
                          width,
                          height);
    
    UIImageView *background = [[UIImageView alloc] initWithImage:self.uploadImage];
    [background setFrame: cropRect];
    
    self.imagePreview = background;
    [self.view addSubview:self.imagePreview];
    [self.view sendSubviewToBack:self.imagePreview];
}

#pragma mark - loading view
- (void) showLoadingView {
    self.loadingView.hidden = NO;
    self.loadingLabel.hidden = NO;
    loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                    target:self
                                                  selector:@selector(changeLoadingImage)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void) hideLoadingView {
    self.loadingView.hidden = YES;
    self.loadingLabel.hidden = YES;
    [loadingTimer invalidate];
}

- (void) changeLoadingImage {
    int number = imageCount++;
    number = number % 4 + 1;
    [self.loadingView setImage:[UIImage imageNamed:[NSString stringWithFormat:IMAGE_LOADING, number]]];
    [self.loadingLabel setText:[LOADING_MSG objectAtIndex:number]];
}

#pragma mark - Search
- (void) uploadSearch{
    [self.generalService uploadSearchWithImage:self.uploadImage
                                  andDetection:@"all"
                                        andBox:nil
                               completionBlock:^(BOOL succeeded, ViSearchResult *result) {
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (!isCanceled) {
                                           if (succeeded) {
                                               self.searchResult = result;
                                               [self hideLoadingView];
                                               [self performSegueWithIdentifier:SEGUE_RESULT sender:self];
                                           } else {
                                               [self showAlertView];
                                           }
                                       } else {
                                           [self hideLoadingView];
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                       }
                                   });
                                   
                                  
                                   
                               }];
}

- (void) showAlertView {
    [self hideLoadingView];
    
    [self.generalService showAlertViewOnViewController:self
                                             withTitle:@"A problem occurs"
                                           withMessage:@"Please try later"
                                            withButton:@"Cancel"
                                           withDismiss:YES];
}

#pragma mark - Navigation
- (IBAction)cancelPressed:(id)sender {
    [self backToCamera];
}

- (void) backToCamera {
    isCanceled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:SEGUE_RESULT]) {
        ResultViewController *vc = [segue destinationViewController];
        vc.isCropImage = YES;
        vc.originalImage = self.uploadImage;
        vc.searchResults = self.searchResult;
        vc.delegate = self;
    }
}

@end
