//
//  DetailViewController.m
//  VisenzeDemo
//
//  Created by ViSenze on 30/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController()

@property GeneralServices *generalService;
@property ViSearchResult *searchResults;
@property NSMutableSet *loadedCell;

#pragma mark - top views
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;
@property (weak, nonatomic) IBOutlet UIView *imagePreview;
@property (weak, nonatomic) IBOutlet UIView *imageNameView;
@property (weak, nonatomic) IBOutlet UILabel *imageNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property UIImageView *displayView;
#pragma mark - bottom views
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomCloseButton;
@property (weak, nonatomic) IBOutlet UIView *bottomHomeButton;
@property (weak, nonatomic) IBOutlet UILabel *searchResultLabel;
@property (weak, nonatomic) IBOutlet UIView *searchResultView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *cropButton;
@property (weak, nonatomic) IBOutlet UIImageView *cropButtonImageView;

#pragma mark - zoom views
@property (weak, nonatomic) IBOutlet UIView *zoomView;
@property UIImageView *zoomImage;
@property UIScrollView *zoomScrollView;

@end

@implementation DetailViewController {
    BOOL isRating;
    BOOL isLoadingImage;
    BOOL isResultAtBottom;
    CGRect rateFrame;
    dispatch_queue_t imgLoadQ;
    
    NSArray *LOADING_MSG;
    NSTimer *loadingTimer;
    int imageCount;
    int idSearchCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    imgLoadQ = dispatch_queue_create("img_load", DISPATCH_QUEUE_CONCURRENT);
        if (!self.imageResult.image) {
            dispatch_async(imgLoadQ, ^{
                
                NSURL *url = [NSURL URLWithString:self.imageResult.url];
                NSData *data = [NSData dataWithContentsOfURL:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageResult.image = [UIImage imageWithData:data];
                    [self initValues];
                    [self initViews];
                    [self idSearch:self.imageResult.im_name];
                });
                
            });} else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self initValues];
                    [self initViews];
                    [self idSearch:self.imageResult.im_name];
                });
            }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

    CGFloat distance = self.searchResultView.frame.origin.y - self.topView.frame.size.height;
    for (UIView *subview in [self.bottomView subviews]) {
        CGRect frame = subview.frame;
        
        if ([subview isEqual:self.collectionView]) {
            [subview setFrame:CGRectMake(frame.origin.x,
                                         frame.origin.y - distance,
                                         frame.size.width,
                                         frame.size.height + distance)];
        } else if (!([subview isEqual:self.cropButton] ||
                     [subview isEqual:self.cropButtonImageView])) {
            [subview setFrame:CGRectMake(frame.origin.x,
                                         frame.origin.y - distance,
                                         frame.size.width,
                                         frame.size.height)];
        }
    }
    
    [self showImageNameView:self.imageResult.im_name];
    [self initDisplayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - init views
- (void) initValues {
    self.generalService = [GeneralServices sharedInstance];
    self.loadedCell = [[NSMutableSet alloc] init];
    
    LOADING_MSG = [NSArray arrayWithObjects:@"", LOADING_MSG_1, LOADING_MSG_2, LOADING_MSG_3, LOADING_MSG_4, nil];
    
    isRating = NO;
    isLoadingImage = NO;
    isResultAtBottom = YES;
    imageCount = 0;
    idSearchCount = 0;
}

- (void) initViews {
    [self hideZoomView];
    [self initGestures];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self initBottomViews];
}

- (void) initGestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panShowSearchResult:)];
    [self.searchResultView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(showZoomView)];
    [self.imagePreview addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(hideZoomView)];
    [self.zoomView addGestureRecognizer:tap];
}

- (void) initDisplayView {
    if (!self.displayView) {
        self.displayView = [[UIImageView alloc] initWithImage:self.imageResult.image];
        [self.imagePreview addSubview:self.displayView];
        [self.displayView setFrame:self.imagePreview.bounds];
    } else {
        [self.displayView setImage:self.imageResult.image];
    }
    
    CGPoint center = self.displayView.center;
    CGFloat width, height, widthToHeight;
    
    [self.displayView setFrame:self.imagePreview.bounds];
    
    width = self.displayView.frame.size.width,
    height = self.displayView.frame.size.height,
    widthToHeight = self.imageResult.image.size.width / self.imageResult.image.size.height;
    
    if (widthToHeight < (width/height)) {
        width = height * widthToHeight;
    } else {
        height = width / widthToHeight;
    }
    
    CGRect frame = CGRectMake(0, 0, width, height);
    [self.displayView setFrame:frame];
    [self.displayView setCenter:center];
}


- (void) initBottomViews {
    [self hideLoadingView];
    
    self.bottomCloseButton.hidden = YES;
    self.bottomHomeButton.hidden = YES;
    [self.bottomCloseButton setAlpha:0.0f];
    [self.bottomHomeButton setAlpha:0.0f];
    
    [self initCropImage];
}

- (void)initCropImage {
    self.cropButton.hidden = YES;
    self.cropButtonImageView.hidden = YES;
    
    [self.cropButtonImageView setImage:[self cropImage:self.imageResult.image
                                              withSize:self.cropButton.frame.size]];
    
    [self.cropButton.layer setBorderColor:[[UIColor cropButtonBorderColor] CGColor]];
    
    [self.cropButton setAlpha:0.0f];
    [self.cropButtonImageView setAlpha:0.0f];
}

- (void) initZoomView {
    if (self.zoomImage) {
        [self.zoomImage removeFromSuperview];
    }
    
    if (self.zoomScrollView) {
        [self.zoomScrollView removeFromSuperview];
    }
    
    CGPoint center = self.zoomView.center;
    CGFloat width, height, widthToHeight;
    
    width = self.zoomView.frame.size.width,
    height = self.zoomView.frame.size.height,
    widthToHeight = self.imageResult.image.size.width / self.imageResult.image.size.height;
    
    if (widthToHeight < (width/height)) {
        width = height * widthToHeight;
    } else {
        height = width / widthToHeight;
    }
    
    self.zoomScrollView = [[UIScrollView alloc] initWithFrame:self.zoomView.bounds];
    
    self.zoomScrollView.center = center;
    self.zoomScrollView.delegate = self;
    self.zoomScrollView.bouncesZoom = NO;
    self.zoomScrollView.minimumZoomScale = 1.0;
    self.zoomScrollView.maximumZoomScale = 2.0;
    
    CGRect frame = CGRectMake(0, 0, width, height);
    self.zoomImage = [[UIImageView alloc] initWithImage:self.imageResult.image];
    [self.zoomImage setFrame:frame];
    [self.zoomImage setCenter:center];
    
    [self.zoomView addSubview:self.zoomScrollView];
    [self.zoomScrollView addSubview:self.zoomImage];
}

#pragma mark - UICollectionView Datasource
- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCollectionViewCell *cell = (SearchResultCollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:CELL_DETAIL_IDENTIFIER forIndexPath:indexPath];
    
    ImageResult *result = [self.searchResults.imageResultsArray objectAtIndex:indexPath.row];
    [cell.similarityLabel setText: [NSString stringWithFormat:CELL_DETAIL_SIMILARITY_MSG,
                                    result.score*100]];

    if (!result.image) {
        [cell.imageView setImage:[self cropImage:[self.generalService defaultImage]
                                        withSize:cell.frame.size]];
        [cell.imageView setFrame:cell.bounds];
        
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        dispatch_async(imgLoadQ, ^{
            if (![self.loadedCell containsObject:indexPath]) {
                [self.loadedCell addObject:indexPath];
                NSURL *url = [NSURL URLWithString:result.url];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    result.image = [UIImage imageWithData:data];
                    UIImage *img = [self cropImage:result.image withSize:cell.frame.size];
                    [cell.imageView setImage:img];
                    [cell.imageView setFrame:cell.bounds];
                    
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                });
            }
        });
    } else {
        UIImage *img = [self cropImage:result.image withSize:cell.frame.size];
        [cell.imageView setImage:img];
        [cell.imageView setFrame:cell.bounds];
    }
    
    return cell;
}

- (UIImage *)cropImage:(UIImage *)image withSize:(CGSize)size{
    return image;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchResults ? self.searchResults.imageResultsArray.count : 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageResult *result = [self.searchResults.imageResultsArray objectAtIndex:indexPath.row];
    if (result.image) {
        self.imageResult = result;
        [self showImageNameView:self.imageResult.im_name];
        
        if (!self.bottomCloseButton.hidden) {
            [self bottomCloseButtonClicked:nil];
        }
        
        [self.cropButtonImageView setImage:[self cropImage:self.imageResult.image
                                                  withSize:self.cropButton.frame.size]];
        [self initDisplayView];
        [self idSearch:self.imageResult.im_name];
    }
}

#pragma mark layout delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size;
    size = self.collectionView.frame.size;
    
    size.width = floor((size.width - 21) / 3);
    size.height = size.width;
    
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

#pragma mark - Scroll View
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.bottomCloseButton.hidden && self.collectionView.contentOffset.y < -30) {
        [self.collectionView setBounces:NO];
        [self bottomCloseButtonClicked:nil];
    }
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.zoomScrollView]) {
        return self.zoomImage;
    }
    
    return nil;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = self.zoomImage.frame;
    
    frame = self.zoomImage.frame;
    if (frame.size.width > self.zoomScrollView.frame.size.width) {
        [self.zoomImage setFrame:CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height)];
    } else {
        [self.zoomImage setCenter: CGPointMake(self.zoomView.center.x, self.zoomImage.center.y)];
    }
    
    if (frame.size.height > self.zoomScrollView.frame.size.height) {
        [self.zoomImage setFrame:CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height)];
    } else {
        [self.zoomImage setCenter: CGPointMake(self.zoomImage.center.x, self.zoomView.center.y)];
    }
}

#pragma mark - Search
- (void) idSearch:(NSString*)imageName {
    idSearchCount++;
    [self beforeSearch];
    
    [self.generalService idSearchWithImageName:imageName
                               completionBlock:^(BOOL succeeded, ViSearchResult *result) {
                                   idSearchCount--;
                                   if (succeeded) {
                                       if (idSearchCount == 0){
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self hideLoadingView];
                                               [self.searchResultLabel setText:MSG_ID_SEARCH_RESULT];
                                               self.searchResults = result;
                                               [self.collectionView reloadData];

                                           });
                                       }
                                   } else {
                                       [self showErrAlertView:result];
                                   }
                               }];
}

- (void) beforeSearch{
    isLoadingImage = YES;
    [self showLoadingView];
    [self.searchResultLabel setText:MSG_SEARCHING];
    self.searchResults = nil;
    self.loadedCell = [[NSMutableSet alloc] init];
    [self.collectionView reloadData];
}

- (void) showErrAlertView: (ViSearchResult *)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoadingView];
        isLoadingImage = NO;
        
        if (self.searchResults == nil) {
            [self backButtonPressed:nil];
        }
        
        [self.generalService showErrAlertViewOnViewController:self withButton:@"Cancel" withDismiss:YES withSearchResult:result];
        
    });
}

#pragma mark - loading view
- (void) showLoadingView {
    if (self.loadingView.hidden) {
        [self.collectionView setUserInteractionEnabled:NO];
        self.loadingView.hidden = NO;
        loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                        target:self
                                                      selector:@selector(changeLoadingImage)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (void) hideLoadingView {
    [self.collectionView setUserInteractionEnabled:YES];
    self.loadingView.hidden = YES;
    [loadingTimer invalidate];
}

- (void) changeLoadingImage {
    int number = imageCount++;
    number = number % 4 + 1;
    [self.loadingView setImage:[UIImage imageNamed:[NSString stringWithFormat:IMAGE_LOADING, number]]];
}

- (void)panShowSearchResult:(UIPanGestureRecognizer *)recognizer {
    CGPoint velocity = [recognizer velocityInView:self.bottomView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.y < -10 && self.bottomCloseButton.hidden) {
            [self bottomUpButtonClicked:nil];
        } else if (velocity.y > 10 && !self.bottomCloseButton.hidden) {
            [self bottomCloseButtonClicked:nil];
        }
    }
}

#pragma mark - Navigation
- (IBAction)backButtonPressed:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)zoomButtonPressed:(id)sender {
    [self showZoomView];
}

- (void) showZoomView {
    [self initZoomView];
    self.zoomView.hidden = NO;
    
    [UIView beginAnimations:@"" context:nil];
    self.zoomView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void) hideZoomView {
    [UIView beginAnimations:@"" context:nil];
    self.zoomView.alpha = 0;
    self.zoomView.hidden = YES;
    [self.zoomScrollView setZoomScale:1.0];
    [UIView commitAnimations];
}

- (IBAction)bottomUpButtonClicked:(id)sender {
    if (isResultAtBottom) {
        isResultAtBottom = NO;
        [UIView animateWithDuration:ANIMATION_DURATION
                         animations:^{
                             [self.view sendSubviewToBack:self.topView];
                             self.bottomCloseButton.hidden = NO;
                             self.bottomHomeButton.hidden = NO;
                             self.cropButton.hidden = NO;
                             self.cropButtonImageView.hidden = NO;
                             
                             for (UIView *subview in [self.bottomView subviews]) {
                                 if (!([subview isEqual:self.cropButton] ||
                                       [subview isEqual:self.cropButtonImageView])) {
                                     
                                     CGRect frame = subview.frame;
                                     [subview setFrame:CGRectMake(frame.origin.x,
                                                                  frame.origin.y - self.topView.frame.size.height,
                                                                  frame.size.width,
                                                                  frame.size.height)];
                                 }
                             }
                             CGRect frame = self.collectionView.frame;
                             [self.collectionView setFrame:CGRectMake(frame.origin.x,
                                                                      frame.origin.y,
                                                                      frame.size.width,
                                                                      frame.size.height + self.topView.frame.size.height)];
                             [self.bottomCloseButton setAlpha:1.0f];
                             [self.bottomHomeButton setAlpha:1.0f];
                             [self.cropButton setAlpha:1.0f];
                             [self.cropButtonImageView setAlpha:1.0f];
                             
                             [self.topView setAlpha:0.0f];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}


- (IBAction)bottomCloseButtonClicked:(id)sender {
    if (!isResultAtBottom) {
        isResultAtBottom = YES;
        [UIView animateWithDuration:ANIMATION_DURATION
                         animations:^{
                             isRating = YES;
                             
                             for (UIView *subview in [self.bottomView subviews]) {
                                 if (!([subview isEqual:self.cropButton] ||
                                       [subview isEqual:self.cropButtonImageView])) {
                                     CGRect frame = subview.frame;
                                     [subview setFrame:CGRectMake(frame.origin.x,
                                                                  frame.origin.y + self.topView.frame.size.height,
                                                                  frame.size.width,
                                                                  frame.size.height)];
                                 }
                             }
                             [self.bottomCloseButton setAlpha:0.0f];
                             [self.bottomHomeButton setAlpha:0.0f];
                             [self.cropButton setAlpha:0.0f];
                             [self.cropButtonImageView setAlpha:0.0f];
                             
                             [self.topView setAlpha:1.0f];
                         }
                         completion:^(BOOL finished){
                             [self.collectionView setBounces:YES];
                             CGRect frame = self.collectionView.frame;
                             [self.collectionView setFrame:CGRectMake(frame.origin.x,
                                                                      frame.origin.y,
                                                                      frame.size.width,
                                                                      frame.size.height - self.topView.frame.size.height)];
                             self.bottomCloseButton.hidden = YES;
                             self.bottomHomeButton.hidden = YES;
                             self.cropButton.hidden = YES;
                             self.cropButtonImageView.hidden = YES;
                             
                             [self.view bringSubviewToFront:self.topView];
                             [self.view bringSubviewToFront:self.zoomView];
                         }];
    }
}

- (void) showImageNameView:(NSString*)imageName{
    if (imageName.length > IMAGE_NAME_LENGTH_LIMIT+3) {
        imageName = [NSString stringWithFormat:@"%@...", [imageName substringToIndex:IMAGE_NAME_LENGTH_LIMIT]];
    }
    
    [self.imageNameLabel setText: imageName];
    [self.imageNameLabel sizeToFit];
    [self.imageNameLabel setCenter:CGPointMake(self.imageNameLabel.center.x, self.buyButton.center.y)];
}

@end

