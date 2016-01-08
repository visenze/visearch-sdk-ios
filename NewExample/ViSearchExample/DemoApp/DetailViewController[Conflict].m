//
//  DetailViewController.m
//  DemoApp
//
//  Created by ViSenze on 14/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "DetailViewController.h"

typedef enum {
    PanAtTopLeftCorner,
    PanAtTopRightCorner,
    PanAtBottomLeftCorner,
    PanAtBottomRightCorner,
    PanAtTopBorder,
    PanAtBottomBorder,
    PanAtLeftBorder,
    PanAtRightBorder,
    PanAtCenter,
    PanAtNone
} PanPostition;

static CGFloat const MINIMUM_WIDTH = 100 + EXTRA_DETECT_DISTANCE * 2;

@interface DetailViewController()

@property NSString *detectionType;
@property Box *currentBox;

#pragma mark - top views
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *imagePreview;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarityLabel;
@property (weak, nonatomic) IBOutlet UIView *rotateButton;
@property UIImageView *displayView;
@property ScaleUIView *scalerView;
#pragma mark - bottom views
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *scrolViewContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomCloseButton;
@property (weak, nonatomic) IBOutlet UILabel *searchResultLabel;
@property (weak, nonatomic) IBOutlet UIView *searchResultView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingView;
#pragma mark - zoom views
@property (weak, nonatomic) IBOutlet UIView *zoomView;
@property (weak, nonatomic) IBOutlet UIImageView *zoomImage;


@end

@implementation DetailViewController {
    BOOL isDynamicView;
    BOOL isLoading;
    CGRect imgFrame;
    CalculateOverlay *calculateView;
    NSArray *DETECTION_TYPES;
    NSArray *LOADING_MSG;
    NSTimer *loadingTimer;
    dispatch_queue_t imgLoadQ;
    int imageCount;
    int uploadSearchCount;
    int rotationAngle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initValues];
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self initDisplayView];
    if (self.isCropImage) {
        [self initScalerView];
    } else {
        [self changeCollectionView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - init views
- (void) initValues {
    DETECTION_TYPES = [[NSArray alloc] initWithObjects: @"all", @"top", @"dress", @"shoe", @"bag", @"bottom", @"saree", nil];
    LOADING_MSG = [NSArray arrayWithObjects:@"", LOADING_MSG_1, LOADING_MSG_2, LOADING_MSG_3, LOADING_MSG_4, nil];
    
    isDynamicView = NO;
    imgLoadQ = dispatch_queue_create("img_load", DISPATCH_QUEUE_CONCURRENT);
    rotationAngle = 0;
    imageCount = 0;
    uploadSearchCount = 0;
    
    NSArray *coordinates = [self.productType objectForKey:@"box"];
    self.currentBox = [[Box alloc] initWithX1:[[coordinates objectAtIndex:0] intValue]
                                           y1:[[coordinates objectAtIndex:1] intValue]
                                           x2:[[coordinates objectAtIndex:2] intValue]
                                           y2:[[coordinates objectAtIndex:3] intValue]];
}

- (void) initViews {
    [self hideZoomView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panShowSearchResult:)];
    [self.searchResultView addGestureRecognizer:pan];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.scrollView.delegate = self;
    
    //hide some layout
    self.bottomCloseButton.hidden = YES;
    self.loadingView.hidden = YES;
    [self.bottomCloseButton setAlpha:0.0f];
    if (self.isCropImage) {
        self.rotateButton.hidden = NO;
        [self initScrollView];
    } else {
        self.scrolViewContainerView.hidden = YES;
        self.rotateButton.hidden = YES;
    }
}

- (void) initDisplayView {
    // Add captured image
    if (!self.displayView) {
        self.displayView = [[UIImageView alloc] initWithImage:self.image];
        [self.imagePreview addSubview:self.displayView];
    } else {
        [self.displayView setImage:self.image];
    }
    
    self.displayView.frame = self.imagePreview.bounds;
    CGPoint center = self.displayView.center;
    CGFloat width = self.displayView.frame.size.width,
    height = self.displayView.frame.size.height,
    widthToHeight = self.image.size.width / self.image.size.height;
    
    if (rotationAngle % 180 == 0) {
        if (widthToHeight < (width/height)) {
            width = height * widthToHeight;
        } else {
            height = width / widthToHeight;
        }
    } else {
        width = self.displayView.frame.size.height;
        height = self.displayView.frame.size.width;
        
        if (widthToHeight < (width/height)) {
            width = height / widthToHeight;
        } else {
            height = width * widthToHeight;
        }
    }
    
    CGRect frame = CGRectMake(0, 0, width, height);
    self.displayView.frame = frame;
    self.displayView.center = center;
    
    if (self.isCropImage) {
        [calculateView removeFromSuperview];
        CGRect cFrame = CGRectMake(0, 0, width, height);
        
        calculateView = [[CalculateOverlay alloc] initWithFrame:cFrame];
        calculateView.center = center;
        calculateView.backgroundColor = [UIColor clearColor];
        [calculateView setUserInteractionEnabled:YES];
        [self.imagePreview addSubview:calculateView];
    } else {
        [calculateView removeFromSuperview];
    }
}

- (void) initScalerView {
    [self.scalerView removeFromSuperview];
    CGFloat ratio;
    if (rotationAngle % 180 == 0) {
        ratio = 512.0 / self.displayView.frame.size.width;
    } else {
        ratio = 512.0 / self.displayView.frame.size.height;
    }
    CGFloat x = self.currentBox.x1 / ratio,
    y = self.currentBox.y1 / ratio,
    width = self.currentBox.x2 / ratio,
    height = self.currentBox.y2 / ratio;
    CGRect scalerFrame = CGRectMake(x, y, width, height);
    
    self.scalerView = [[ScaleUIView alloc] initWithFrame:scalerFrame];
    [self.scalerView setUserInteractionEnabled:YES];
    self.scalerView.backgroundColor = [UIColor clearColor];
    
    // Add gesture to scaler
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.scalerView addGestureRecognizer:pan];
    
    [calculateView addSubview:self.scalerView];
    calculateView.scaleView = self.scalerView;
    calculateView.drawArea = self.displayView.bounds;
}

- (void) changeCollectionView {
    CGRect frame = self.collectionView.frame;
    [self.collectionView setFrame:CGRectMake(frame.origin.x,
                                             frame.origin.y - 53,
                                             frame.size.width,
                                             frame.size.height + 53)];
    frame = self.loadingView.frame;
    [self.loadingView setFrame:CGRectMake(frame.origin.x,
                                          frame.origin.y - 53,
                                          frame.size.width,
                                          frame.size.height)];
}

#pragma mark - UICollectionView Datasource
- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCollectionViewCell *cell = (SearchResultCollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"SearchResultCollectionViewCell" forIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [self.imageArray objectAtIndex:indexPath.item];
        [cell.imageView setImage:[self cropImage:[dict objectForKey:KEY_IMAGE] withSize:cell.frame.size]];
        cell.similarityLabel.text = [NSString stringWithFormat:@"Similarity %.0f%%", [[self.productType objectForKey:@"score"] floatValue]*100];
    });
    
    return cell;
}

- (UIImage *)cropImage:(UIImage *)image withSize:(CGSize)size{
    if (isDynamicView) {
        UIImage *tempImage = nil;
        CGSize targetSize = size;
        UIGraphicsBeginImageContext(targetSize);
        
        CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
        thumbnailRect.origin = CGPointMake(0.0,0.0);
        thumbnailRect.size.width  = targetSize.width;
        thumbnailRect.size.height = targetSize.height;
        
        [image drawInRect:thumbnailRect];
        
        tempImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return tempImage;
    }
    
    CGRect rect;
    if (image.size.width >= image.size.height) {
        rect = CGRectMake((image.size.width - image.size.height) / 2, 0 , image.size.height, image.size.height);
    } else {
        rect = CGRectMake(0, (image.size.height - image.size.width) / 2, image.size.width, image.size.width);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    // Create new cropped UIImage
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.imageArray objectAtIndex:indexPath.item];
    if (self.isCropImage) {
        self.scrolViewContainerView.hidden = YES;
        [self changeCollectionView];
        self.isCropImage = NO;
    }
    self.image = [dict objectForKey:KEY_IMAGE];
    [self initDisplayView];
    [self idSearch:[dict objectForKey:KEY_IMAGE_NAME]];
}

#pragma mark layout delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)
collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size;
    size = self.collectionView.frame.size;
    
    if (isDynamicView) {
        NSDictionary *dict = [self.imageArray objectAtIndex:indexPath.item];
        size.width =floor((size.width - 20) / 2);
        
        UIImage *img = [dict objectForKey:KEY_IMAGE];
        size.height = img.size.height * (size.width / img.size.width);
    } else {
        size.width = floor((size.width - 21) / 3);
        size.height = size.width;
    }
    
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
- (void) initScrollView {
    int width = 10;
    BOOL hasMatchedType = NO;
    
    for (int index = 0; index < [DETECTION_TYPES count]; index++) {
        NSString *str = [DETECTION_TYPES objectAtIndex:index];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [button addTarget:self action:@selector(scrollViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setFrame:CGRectMake(width, 9, 60, 35)];
        [button setTag:index];
        
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setCornerRadius:3.0f];
        
        [button setTitle:str forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:101.0/256.0
                                              green:98.0/256.0
                                               blue:132.0/256.0
                                              alpha:1.0]
                     forState:UIControlStateNormal];
        [[button layer] setBorderColor:[[UIColor colorWithRed:101.0/256.0
                                                        green:98.0/256.0
                                                         blue:132.0/256.0
                                                        alpha:1.0] CGColor]];
        
        if ([str isEqualToString:[self.productType objectForKey:@"type"]]) {
            self.detectionType = str;
            hasMatchedType = YES;
            [button setTitleColor:[UIColor colorWithRed:200.0/256.0
                                                  green:75.0/256.0
                                                   blue:98.0/256.0
                                                  alpha:1.0]
                         forState:UIControlStateNormal];
            [[button layer] setBorderColor:[[UIColor colorWithRed:200.0/256.0
                                                            green:75.0/256.0
                                                             blue:98.0/256.0
                                                            alpha:1.0] CGColor]];
        }
        
        width += 65;
        
        [self.scrollView addSubview:button];
    }
    
    if (!hasMatchedType) {
        self.detectionType = @"all";
        for (UIButton *button in [self.scrollView subviews]){
            if (button.tag == 0) {
                [button setTitleColor:[UIColor colorWithRed:200.0/256.0
                                                      green:75.0/256.0
                                                       blue:98.0/256.0
                                                      alpha:1.0]
                             forState:UIControlStateNormal];
                [[button layer] setBorderColor:[[UIColor colorWithRed:200.0/256.0
                                                                green:75.0/256.0
                                                                 blue:98.0/256.0
                                                                alpha:1.0] CGColor]];
                break;
            }
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(width,53);
    self.scrollView.contentOffset = CGPointMake(0, 0);
}


- (void) scrollViewButtonTapped:(id)sender {
    for (UIButton *button in self.scrollView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setTitleColor:[UIColor colorWithRed:101.0/256.0
                                                  green:98.0/256.0
                                                   blue:132.0/256.0
                                                  alpha:1.0]
                         forState:UIControlStateNormal];
            [[button layer] setBorderColor:[[UIColor colorWithRed:101.0/256.0
                                                            green:98.0/256.0
                                                             blue:132.0/256.0
                                                            alpha:1.0] CGColor]];
        }
    }
    
    UIButton *button = (UIButton *) sender;
    [button setTitleColor:[UIColor colorWithRed:200.0/256.0
                                          green:75.0/256.0
                                           blue:98.0/256.0
                                          alpha:1.0]
                 forState:UIControlStateNormal];
    [[button layer] setBorderColor:[[UIColor colorWithRed:200.0/256.0
                                                    green:75.0/256.0
                                                     blue:98.0/256.0
                                                    alpha:1.0] CGColor]];
    
    self.detectionType = [DETECTION_TYPES objectAtIndex:button.tag];
    [self uploadSearch];
}

#pragma mark - Search
- (void) idSearch:(NSString*)imageName {
    [self beforeSearch];
    
    SearchParams *searchParams = [[SearchParams alloc] init];
    searchParams.imName = imageName;
    searchParams.fl = @[@"price",@"brand",@"im_url"];
    searchParams.limit = 18;
    
    [[ViSearchAPI defaultClient] searchWithImageId:searchParams success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        [self loadImages:data];
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        [self showAlertView];
    }];
}

- (void) uploadSearch{
    [self beforeSearch];
    uploadSearchCount++;

    UploadSearchParams *params = [[UploadSearchParams alloc] init];
    params.fl = @[@"im_url", @"brand", @"im_title", @"price", @"product_url"];
    params.limit = 18;
    params.imageFile = self.image;
    params.detection = self.detectionType;
    
    params.box = self.currentBox;
    
    [[ViSearchClient sharedInstance] searchWithImageData:params success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        uploadSearchCount--;
        if (uploadSearchCount == 0) {
            self.productType = [[data.content objectForKey:@"product_types"] objectAtIndex:0];
            [self loadImages:data];
        }
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
        uploadSearchCount--;
        [self showAlertView];
    }];
}

- (void) beforeSearch{
    if (self.loadingView.hidden) {
        [self showLoadingView];
    }
    self.imageArray = [[NSArray alloc] init];
    [self.collectionView reloadData];
}

- (void) showAlertView {
    [self hideLoadingView];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"A problem occurs"
                                  message:@"Please try later"
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) loadImages:(ViSearchResult*)searchResult {
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (int i=0; i<searchResult.imageResultsArray.count; i++) {
        dispatch_async(imgLoadQ, ^{
            ImageResult *result = [searchResult.imageResultsArray objectAtIndex:i];
            
            NSURL *url = [NSURL URLWithString:result.url];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img = [[UIImage alloc] initWithData:data];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
                [dict setValue:img forKey:KEY_IMAGE];
                [dict setValue:result.im_name forKey:KEY_IMAGE_NAME];
                [newArray addObject:dict];
                
                if (newArray.count == searchResult.imageResultsArray.count) {
                    self.imageArray = newArray;
                    [self.collectionView reloadData];
                    [self hideLoadingView];
                }
            });
        });
    }
}

#pragma mark - loading view
- (void) showLoadingView {
    self.loadingView.hidden = NO;
    loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                    target:self
                                                  selector:@selector(changeLoadingImage)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void) hideLoadingView {
    self.loadingView.hidden = YES;
    [loadingTimer invalidate];
}

- (void) changeLoadingImage {
    int number = imageCount++;
    number = number % 4 + 1;
    [self.loadingView setImage:[UIImage imageNamed:[NSString stringWithFormat:IMAGE_LOADING, number]]];
}

#pragma mark - Gesture
- (void)pan:(UIPanGestureRecognizer *)recognizer {
    static PanPostition panPostion = PanAtNone;
    //[self adjustAnchorPointForGestureRecognizer:recognizer];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        panPostion = getPosition([recognizer locationInView:recognizer.view],
                                 recognizer.view.frame.size.width, recognizer.view.frame.size.height);
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateBegan) {
        CGRect tmpFrame;
        CGPoint translation = [recognizer translationInView:recognizer.view];
        tmpFrame = recognizer.view.frame;
        CGFloat x, y, width, height;
        switch (panPostion) {
            case PanAtCenter: {
                CGFloat _x = tmpFrame.origin.x + translation.x;
                CGFloat _y = tmpFrame.origin.y + translation.y;
                x = MIN(MAX(0, _x), calculateView.frame.size.width - recognizer.view.frame.size.width);
                y = MIN(MAX(0, _y), calculateView.frame.size.height - recognizer.view.frame.size.height);
                
                tmpFrame.origin = CGPointMake(x, y);
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtBottomRightCorner: {
                tmpFrame.size = CGSizeMake(MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.width + translation.x), calculateView.frame.size.width - tmpFrame.origin.x),
                                           MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.height + translation.y), calculateView.frame.size.height - tmpFrame.origin.y));
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtBottomLeftCorner: {
                if (translation.x > 0 && tmpFrame.size.width == MINIMUM_WIDTH) {
                    return;
                }
                
                x = MIN(MAX(0, tmpFrame.origin.x + translation.x), tmpFrame.origin.x + tmpFrame.size.width - MINIMUM_WIDTH);
                y = tmpFrame.origin.y;
                width = tmpFrame.origin.x + tmpFrame.size.width - x;
                height = MIN(MAX(tmpFrame.size.height + translation.y, MINIMUM_WIDTH), calculateView.frame.size.height - tmpFrame.origin.y);
                
                tmpFrame = CGRectMake(x, y, width, height);
                recognizer.view.frame = tmpFrame;
                
                break;
            }
            case PanAtTopLeftCorner: {
                x = MAX(0, MIN(tmpFrame.origin.x + translation.x, tmpFrame.origin.x + tmpFrame.size.width - MINIMUM_WIDTH));
                y = MAX(0, MIN(tmpFrame.origin.y + translation.y, tmpFrame.origin.y + tmpFrame.size.height - MINIMUM_WIDTH));
                width = tmpFrame.origin.x + tmpFrame.size.width - x;
                height = tmpFrame.origin.y + tmpFrame.size.height - y;
                
                tmpFrame = CGRectMake(x, y, width, height);
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtTopRightCorner: {
                height = MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.height - translation.y), tmpFrame.size.height + tmpFrame.origin.y);
                width =  MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.width + translation.x), calculateView.frame.size.width - tmpFrame.origin.x);
                tmpFrame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y + tmpFrame.size.height - height, width, height);
                
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtLeftBorder: {
                width = MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.width - translation.x), tmpFrame.size.width + tmpFrame.origin.x);
                x = tmpFrame.origin.x + tmpFrame.size.width - width;
                tmpFrame = CGRectMake(x, tmpFrame.origin.y, width, tmpFrame.size.height);
                
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtRightBorder: {
                width = MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.width + translation.x), calculateView.frame.size.width - tmpFrame.origin.x);
                tmpFrame.size.width = width;
                
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtTopBorder: {
                height = MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.height - translation.y), tmpFrame.origin.y + tmpFrame.size.height);
                y = tmpFrame.size.height + tmpFrame.origin.y - height;
                
                tmpFrame.origin.y = y;
                tmpFrame.size.height = height;
                
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtBottomBorder: {
                height = MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.height + translation.y), calculateView.frame.size.height - tmpFrame.origin.y);
                tmpFrame.size.height = height;
                
                recognizer.view.frame = tmpFrame;
                break;
            }
            default:
                break;
        }
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
        [calculateView setNeedsDisplay];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.currentBox = [[Box alloc] initWithX1:calculateView.scaleView.frame.origin.x
                                               y1:calculateView.scaleView.frame.origin.y
                                               x2:calculateView.scaleView.frame.size.width
                                               y2:calculateView.scaleView.frame.size.height];
        [self uploadSearch];
    }
}

PanPostition getPosition(CGPoint position, CGFloat width, CGFloat height){
    CGFloat x = position.x;
    CGFloat y = position.y;
    
    PanPostition panPostion = PanAtNone;
    if (y >= height - 40 - EXTRA_DETECT_DISTANCE && x >= width - 40 - EXTRA_DETECT_DISTANCE) {
        panPostion = PanAtBottomRightCorner;
    }
    else if (y >= height - 40 - EXTRA_DETECT_DISTANCE && x <= 40 + EXTRA_DETECT_DISTANCE) {
        panPostion = PanAtBottomLeftCorner;
    }
    else if (y <= 40 + EXTRA_DETECT_DISTANCE && x <= 40 + EXTRA_DETECT_DISTANCE) {
        panPostion = PanAtTopLeftCorner;
    }
    else if (y <= 40 + EXTRA_DETECT_DISTANCE && x >= width - 40 - EXTRA_DETECT_DISTANCE) {
        panPostion = PanAtTopRightCorner;
    }
    else if (x >= 40 && x <= width -40 && y >= 40 && y <= height - 40) {
        panPostion = PanAtCenter;
    }
    else if (x <= 40) {
        panPostion = PanAtLeftBorder;
    }
    else if (y <= 40) {
        panPostion = PanAtTopBorder;
    }
    else if (x >= width - 40) {
        panPostion = PanAtRightBorder;
    }
    else if (y >= height - 40){
        panPostion = PanAtBottomBorder;
    }
    
    return panPostion;
}

- (void)panShowSearchResult:(UIPanGestureRecognizer *)recognizer {
    CGPoint velocity = [recognizer velocityInView:self.bottomView];
//    CGPoint currentlocation = [recognizer locationInView:self.bottomView];
//    NSLog(@"point is %@", NSStringFromCGPoint(currentlocation));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.y < -10 && self.bottomCloseButton.hidden) {
            [self.view sendSubviewToBack:self.topView];
            self.bottomCloseButton.hidden = NO;

            [UIView animateWithDuration:1.0
                                  delay:0.0
                                options: (UIViewAnimationOptionBeginFromCurrentState |
                                          UIViewAnimationOptionCurveEaseIn |
                                          UIViewAnimationOptionCurveEaseOut)
                             animations:^{
                                 for (UIView *subview in [self.bottomView subviews]) {
                                     CGRect frame = subview.frame;
                                     [subview setFrame:CGRectMake(frame.origin.x,
                                                                  frame.origin.y - self.topView.frame.size.height,
                                                                  frame.size.width,
                                                                  frame.size.height)];
                                 }
                                 CGRect frame = self.collectionView.frame;
                                 [self.collectionView setFrame:CGRectMake(frame.origin.x,
                                                                          frame.origin.y,
                                                                          frame.size.width,
                                                                          frame.size.height + self.topView.frame.size.height)];
                                 [self.bottomCloseButton setAlpha:1.0f];
                                 [self.topView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished){
                             }];
        } else if (velocity.y > 10 && !self.bottomCloseButton.hidden) {
            [self bottomCloseButtonClicked:nil];
        }
    }
}

#pragma mark - Navigation
- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)zoomButtonPressed:(id)sender {
    [self showZoomView];
}

- (IBAction)zoomCloseButtonClicked:(id)sender {
    [self hideZoomView];
}

- (void) showZoomView {
    [UIView beginAnimations:@"" context:nil];
    self.zoomView.alpha = 1;
    self.zoomView.hidden = NO;
    [self.zoomImage setImage: self.image];
    [UIView commitAnimations];
}

- (void) hideZoomView {
    [UIView beginAnimations:@"" context:nil];
    self.zoomView.alpha = 0;
    self.zoomView.hidden = YES;
    [UIView commitAnimations];
}

- (IBAction)rotateButtonPressed:(id)sender {
    rotationAngle += 90;
    self.displayView.transform = CGAffineTransformMakeRotation(radians(rotationAngle));
//    self.currentBox = [[Box alloc] initWithX1:self.currentBox.y1 y1:self.currentBox.x1 x2:self.currentBox.y2 y2:self.currentBox.x2];
    [self initDisplayView];
    [self initScalerView];
}


- (IBAction)bottomCloseButtonClicked:(id)sender {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options: (UIViewAnimationOptionBeginFromCurrentState |
                                  UIViewAnimationOptionCurveEaseIn |
                                  UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         for (UIView *subview in [self.bottomView subviews]) {
                             CGRect frame = subview.frame;
                             [subview setFrame:CGRectMake(frame.origin.x,
                                                          frame.origin.y + self.topView.frame.size.height,
                                                          frame.size.width,
                                                          frame.size.height)];
                         }
                         [self.bottomCloseButton setAlpha:0.0f];
                         [self.topView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){
                         CGRect frame = self.collectionView.frame;
                         [self.collectionView setFrame:CGRectMake(frame.origin.x,
                                                                  frame.origin.y,
                                                                  frame.size.width,
                                                                  frame.size.height - self.topView.frame.size.height)];
                         self.bottomCloseButton.hidden = YES;
                         [self.view bringSubviewToFront:self.topView];
                         [self.view bringSubviewToFront:self.zoomView];
                     }];
}

- (IBAction)changeViewButtonClicked:(id)sender {
    UIButton *button = (UIButton*) sender;
    isDynamicView = !isDynamicView;
    
    if (isDynamicView) {
        [button setImage:[UIImage imageNamed:IMAGE_DYNAMIC_VIEW] forState:UIControlStateNormal];
        [self.collectionView reloadData];
    } else {
        [button setImage:[UIImage imageNamed:IMAGE_SQUARE_VIEW] forState:UIControlStateNormal];
        [self.collectionView reloadData];
    }
}

@end
