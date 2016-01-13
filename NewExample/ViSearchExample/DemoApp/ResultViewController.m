//
//  DetailViewController.m
//  DemoApp
//
//  Created by ViSenze on 14/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//

#import "ResultViewController.h"

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

@interface ResultViewController()

@property Box *currentBox;
@property GeneralServices *generalService;
@property ViSearchProductType *productType;
@property NSString *detectionType;
@property UIImage *image;
@property NSMutableDictionary *imageCache;
@property NSUInteger selectedIndex;
@property NSMutableSet *loadedCell;

#pragma mark - top views
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;
@property (weak, nonatomic) IBOutlet UIView *imagePreview;
@property (weak, nonatomic) IBOutlet UIView *rotateButton;
@property UIImageView *displayView;
@property ScaleUIView *scalerView;
#pragma mark - bottom views
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *dynamicCollectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomCloseButton;
@property (weak, nonatomic) IBOutlet UIView *bottomHomeButton;
@property (weak, nonatomic) IBOutlet UILabel *searchResultLabel;
@property (weak, nonatomic) IBOutlet UIView *searchResultView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *cropButton;
@property (weak, nonatomic) IBOutlet UIImageView *cropButtonImageView;

@end

@implementation ResultViewController {
    BOOL isDynamicView;
    BOOL isRating;
    BOOL isResultAtBottom;
    
    CGFloat boxRatio;
    CGRect rateFrame;
    CalculateOverlay *calculateView;
    dispatch_queue_t imgLoadQ;
    NSArray *LOADING_MSG;
    NSTimer *loadingTimer;
    
    int imageCount;
    int uploadSearchCount;
    int rotationAngle;
}

- (void)viewDidLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super viewDidLoad];
        [self initValues];
        [self initViews];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

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
    self.imageCache = [[NSMutableDictionary alloc] init];
    self.productType = [self.searchResults.productTypes objectAtIndex:0];
    self.image = self.originalImage;
    self.loadedCell = [[NSMutableSet alloc] init];
    
    imgLoadQ = dispatch_queue_create("img_load", DISPATCH_QUEUE_CONCURRENT);

    LOADING_MSG = [NSArray arrayWithObjects:@"", LOADING_MSG_1, LOADING_MSG_2, LOADING_MSG_3, LOADING_MSG_4, nil];
    
    isDynamicView = NO;
    isRating = NO;
    isResultAtBottom = NO;

    rotationAngle = 0;
    imageCount = 0;
    uploadSearchCount = 0;
    
    if (self.productType.box) {
        [self initProductType];
    } else {
        self.productType = [[ViSearchProductType alloc] init];
        self.detectionType = DEFAULT_TYPE;
        [self.imageCache setValue:self.searchResults forKey:self.detectionType];
    }
}

- (void) initProductType {
    CGFloat ratio;
    if (self.image.size.height > self.image.size.width) {
        ratio = self.image.size.height / COMPRESSED_IMAGE_SIZE;
    } else {
        ratio = self.image.size.width / COMPRESSED_IMAGE_SIZE;
    }
    
    ratio = ratio < 1 ? 1: ratio;
    
    self.currentBox = [[Box alloc] initWithX1:self.productType.box.x1 * ratio
                                           y1:self.productType.box.y1 * ratio
                                           x2:self.productType.box.x2 * ratio
                                           y2:self.productType.box.y2 * ratio];
    
    self.detectionType = self.productType.type;
    
    [self.imageCache setValue:self.searchResults forKey:self.detectionType];
}

- (void) initViews {
    [self initGestures];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.dynamicCollectionView.delegate = self;
    self.dynamicCollectionView.dataSource = self;

    self.scrollView.delegate = self;
    [self initBottomViews];
    [self initScrollView];
    
    [self initCollectionViewLayoutWithColumnCount:3 toView:self.collectionView];
    [self initCollectionViewLayoutWithColumnCount:2 toView:self.dynamicCollectionView];
    [self hideDynamicCollectionView];
}

- (void) initGestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panShowSearchResult:)];
    [self.searchResultView addGestureRecognizer:pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(rotateButtonPressed:)];
    [self.rotateButton addGestureRecognizer:tap];
}

- (void) initBottomViews {
    [self hideLoadingView];
    [self initCropImage];
}

- (void)initCropImage {
    [self.cropButtonImageView setImage:[self cropImage:self.image
                                              withSize:self.cropButton.frame.size]];
    [self.cropButton.layer setBorderColor:[[UIColor cropButtonBorderColor] CGColor]];
}

- (void) initDisplayView {
    if (!self.displayView) {
        self.displayView = [[UIImageView alloc] initWithImage:self.image];
        [self.imagePreview addSubview:self.displayView];
        [self.displayView setFrame:self.imagePreview.bounds];
    } else {
        [self.displayView setImage:self.image];
    }
    
    CGPoint center = self.displayView.center;
    CGFloat width, height, widthToHeight;
    
    [self.displayView setFrame:self.imagePreview.bounds];
    
    width = self.displayView.frame.size.width,
    height = self.displayView.frame.size.height,
    widthToHeight = self.image.size.width / self.image.size.height;
    
    if (widthToHeight < (width/height)) {
        width = height * widthToHeight;
    } else {
        height = width / widthToHeight;
    }
    boxRatio = self.image.size.width / width;
    
    CGRect frame = CGRectMake(0, 0, width, height);
    [self.displayView setFrame:frame];
    [self.displayView setCenter:center];
    
    [calculateView removeFromSuperview];
    CGRect cFrame = CGRectMake(0, 0, width, height);
    
    calculateView = [[CalculateOverlay alloc] initWithFrame:cFrame];
    [calculateView setCenter:center];
    [calculateView setBackgroundColor:[UIColor clearColor] ];
    [calculateView setUserInteractionEnabled:YES];
    [calculateView setClipsToBounds:YES];
    [self.imagePreview addSubview:calculateView];
    [self initScalerView];
}

- (void) initScalerView {
    [self.scalerView removeFromSuperview];
    
    CGFloat x, y, width, height;
    
    if (self.currentBox) {
        x = self.currentBox.x1 / boxRatio - EXTRA_DISTANCE;
        y = self.currentBox.y1 / boxRatio - EXTRA_DISTANCE;
        width = (self.currentBox.x2 - self.currentBox.x1) / boxRatio + EXTRA_DISTANCE * 2;
        height = (self.currentBox.y2 - self.currentBox.y1) / boxRatio + EXTRA_DISTANCE * 2;
        
        x = MAX(0, x);
        y =  y < 0 ? 0 : y;
        width = width + x > calculateView.frame.size.width ? calculateView.frame.size.width - x : width;
        height = height + y > calculateView.frame.size.height ? calculateView.frame.size.height - y : height;
    } else {
        x = 0;
        y = 0;
        width = calculateView.frame.size.width;
        height = calculateView.frame.size.height;
    }
    
    CGRect scalerFrame = CGRectMake(x, y, width, height);
    if (!CGRectContainsRect(self.displayView.bounds, scalerFrame)) {
        scalerFrame = self.displayView.bounds;
    }
    
    self.scalerView = [[ScaleUIView alloc] initWithFrame:scalerFrame];
    [self.scalerView setUserInteractionEnabled:YES];
    self.scalerView.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(pan:)];
    [self.scalerView addGestureRecognizer:pan];
    
    [calculateView addSubview:self.scalerView];
    calculateView.scaleView = self.scalerView;
    calculateView.drawArea = self.displayView.frame;
}

- (void)initCollectionViewLayoutWithColumnCount:(NSInteger)column toView:(UICollectionView*)cView{
    dispatch_async(dispatch_get_main_queue(), ^{
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.columnCount = column;
        [cView setCollectionViewLayout: layout];
        [cView reloadData];
    });
}

#pragma mark - UICollectionView Datasource
- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchResultCollectionViewCell *cell = (SearchResultCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_DETAIL_IDENTIFIER forIndexPath:indexPath];
    
    ImageResult *result = [self.searchResults.imageResultsArray objectAtIndex:indexPath.row];
    [cell.similarityLabel setText: [NSString stringWithFormat:CELL_DETAIL_SIMILARITY_MSG,
                                    result.score*100]];

    if (!result.image) {
        if (![self.loadedCell containsObject:indexPath]) {
            [self.loadedCell addObject:indexPath];
            [cell.imageView setImage:[self cropImage:[self.generalService defaultImage]
                                            withSize:cell.frame.size]];
            
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
            dispatch_async(imgLoadQ, ^{
                NSURL *url = [NSURL URLWithString:result.url];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    result.image = [UIImage imageWithData:data];
                    
                    if (self.searchResults.imageResultsArray.count > 0) {
                        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }
                });
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *img = [self cropImage:result.image withSize:cell.frame.size];
            [cell.imageView setImage:img];
            [cell.imageView setFrame:cell.bounds];
        });
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
    self.selectedIndex = indexPath.item;
    ImageResult *result = [self.searchResults.imageResultsArray objectAtIndex:self.selectedIndex];
    if (result.image) {
        [self performSegueWithIdentifier:SEGUE_DETAIL sender:self];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    SearchResultCollectionViewCell *temp = (SearchResultCollectionViewCell*)cell;
    [temp.imageView setImage:[self.generalService defaultImage]];
    [temp.similarityLabel setText:@""];
}

#pragma mark layout delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size;
    size = collectionView.frame.size;
    
    if ([collectionView isEqual:self.dynamicCollectionView]) {
        ImageResult *result = [self.searchResults.imageResultsArray objectAtIndex:indexPath.item];
        size.width =floor((size.width - 20) / 2);
        UIImage *img = result.image;
        if (img) {
            size.height = img.size.height * (size.width / img.size.width);
        } else {
            size.height = size.width;
        }
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
    CGRect selectedFrame;
    
    for (int index = 0; index < [self.searchResults.productTypesList count]; index++) {
        ViSearchProductType *product = [self.searchResults.productTypesList objectAtIndex:index];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [button addTarget:self action:@selector(scrollViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTag:index];
        
        [[button layer] setBorderWidth:1.5f];
        [[button layer] setCornerRadius:3.0f];
        
        [button setTitle:[NSString stringWithFormat:@"   %@   ",[product.type uppercaseString]]
                forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [button setTitleColor:[UIColor detectionNormalColor]
                     forState:UIControlStateNormal];
        [[button layer] setBorderColor:[[UIColor detectionNormalColor] CGColor]];
        [button sizeToFit];
        [button setFrame:CGRectMake(width, 11, button.frame.size.width, 23)];

        if ([product.type isEqualToString:self.detectionType]) {
            [button setTitleColor:[UIColor detectionSelectedColor]
                         forState:UIControlStateNormal];
            [[button layer] setBorderColor:[[UIColor detectionSelectedColor] CGColor]];
            
            selectedFrame = button.frame;
        }
        
        width += button.frame.size.width + 10;
        
        [self.scrollView addSubview:button];
    }
    
    self.scrollView.contentSize = CGSizeMake(width, 45);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.scrollView scrollRectToVisible:selectedFrame animated:YES];
}

- (void) scrollViewButtonTapped:(id)sender {
    for (UIButton *button in self.scrollView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setTitleColor:[UIColor detectionNormalColor]
                         forState:UIControlStateNormal];
            [[button layer] setBorderColor:[[UIColor detectionNormalColor] CGColor]];
        }
    }
    
    UIButton *button = (UIButton *) sender;
    [button setTitleColor:[UIColor detectionSelectedColor]
                 forState:UIControlStateNormal];
    [[button layer] setBorderColor:[[UIColor detectionSelectedColor] CGColor]];
    
    ViSearchProductType *product = [self.searchResults.productTypesList objectAtIndex:button.tag];
    self.detectionType = product.type;
    
    if (![self loadCache]) {
        [self uploadSearch];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.bottomCloseButton.hidden && scrollView.contentOffset.y < -30) {
        [scrollView setBounces:NO];
        [self bottomCloseButtonClicked:nil];
    }
}

#pragma mark - Search
- (void) uploadSearch {
    uploadSearchCount++;
    [self beforeSearch];

    NSString *detection = [self.detectionType isEqualToString:@"other"] ? @"all" : self.detectionType;
    
    [self.generalService
     uploadSearchWithImage:self.image
     andDetection:detection
     andBox:self.currentBox
     completionBlock:^(BOOL succeeded, ViSearchResult *result) {
         uploadSearchCount--;
         if (succeeded) {
             if (uploadSearchCount == 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self hideLoadingView];
                     [self.searchResultLabel setText:MSG_UP_SEARCH_RESULT];
                     self.searchResults = result;
                     NSString *type = [[[result.content
                                         objectForKey:KEY_PRODUCT_TYPE] objectAtIndex:0]
                                       objectForKey:KEY_TYPE];
                     type = type ? type : DEFAULT_TYPE;
                     
                     [self.imageCache setValue:result forKey:type];
                     
                     if (isDynamicView) {
                         [self showDynamicCollectionView];
                     } else {
                         [self hideDynamicCollectionView];
                     }
                 });
             }
         } else {
             [self showAlertView];
         }
     }];
}

- (void) beforeSearch{
    [self showLoadingView];
    [self.searchResultLabel setText:MSG_SEARCHING];
    self.searchResults = nil;
    self.loadedCell = [[NSMutableSet alloc] init];
    [self.collectionView reloadData];
    [self.dynamicCollectionView reloadData];
}

- (void) showAlertView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoadingView];
        
        [self.generalService showAlertViewOnViewController:self
                                                 withTitle:@"A problem occurs"
                                               withMessage:@"Please try later"
                                                withButton:@"Cancel"
                                                 withSegue:nil];
    });
}

- (BOOL) loadCache {
    [self beforeSearch];
    
    ViSearchResult *result = [self.imageCache objectForKey:self.detectionType];

    if (result) {
        [self hideLoadingView];
        [self.searchResultLabel setText: MSG_UP_SEARCH_RESULT];
        self.searchResults = result;
        if (isDynamicView) {
            [self showDynamicCollectionView];
        } else {
            [self hideDynamicCollectionView];
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - loading view
- (void) showLoadingView {
    if (self.loadingView.hidden) {
        [self.collectionView setUserInteractionEnabled:NO];
        [self.dynamicCollectionView setUserInteractionEnabled:NO];
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
    [self.dynamicCollectionView setUserInteractionEnabled:YES];
    self.loadingView.hidden = YES;
    [loadingTimer invalidate];
}

- (void) changeLoadingImage {
    int number = imageCount++;
    number = number % 4 + 1;
    [self.loadingView setImage:[UIImage imageNamed:[NSString stringWithFormat:IMAGE_LOADING, number]]];
}

- (void) showDynamicCollectionView {
    self.dynamicCollectionView.hidden = NO;
    self.collectionView.hidden = YES;
    [self.dynamicCollectionView reloadData];
}

- (void) hideDynamicCollectionView {
    self.dynamicCollectionView.hidden = YES;
    self.collectionView.hidden = NO;
    [self.collectionView reloadData];
}

#pragma mark - Gesture
- (void)pan:(UIPanGestureRecognizer *)recognizer {
    static PanPostition panPostion = PanAtNone;

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        panPostion = getPosition([recognizer locationInView:recognizer.view],
                                 recognizer.view.frame.size.width,
                                 recognizer.view.frame.size.height);
    } else if (recognizer.state == UIGestureRecognizerStateChanged ||
               recognizer.state == UIGestureRecognizerStateBegan) {
        CGRect tmpFrame;
        CGPoint translation = [recognizer translationInView:recognizer.view];
        tmpFrame = recognizer.view.frame;
        CGFloat x, y, width, height;
        switch (panPostion) {
            case PanAtCenter: {
                CGFloat _x = tmpFrame.origin.x + translation.x;
                CGFloat _y = tmpFrame.origin.y + translation.y;
                x = MIN(MAX(-EXTRA_DISTANCE, _x), calculateView.frame.size.width - recognizer.view.frame.size.width + EXTRA_DISTANCE);
                y = MIN(MAX(-EXTRA_DISTANCE, _y), calculateView.frame.size.height - recognizer.view.frame.size.height + EXTRA_DISTANCE);
                
                tmpFrame.origin = CGPointMake(x, y);
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtBottomRightCorner: {
                tmpFrame.size = CGSizeMake(MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.width + translation.x), calculateView.frame.size.width - tmpFrame.origin.x + EXTRA_DISTANCE),
                                           MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.height + translation.y), calculateView.frame.size.height - tmpFrame.origin.y + EXTRA_DISTANCE));
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtBottomLeftCorner: {
                if (translation.x > -EXTRA_DISTANCE && tmpFrame.size.width == MINIMUM_WIDTH) {
                    return;
                }
                
                x = MIN(MAX(-EXTRA_DISTANCE, tmpFrame.origin.x + translation.x), tmpFrame.origin.x + tmpFrame.size.width - MINIMUM_WIDTH + EXTRA_DISTANCE);
                y = tmpFrame.origin.y;
                width = tmpFrame.origin.x + tmpFrame.size.width - x;
                height = MIN(MAX(tmpFrame.size.height + translation.y, MINIMUM_WIDTH), calculateView.frame.size.height - tmpFrame.origin.y + EXTRA_DISTANCE);
                
                tmpFrame = CGRectMake(x, y, width, height);
                recognizer.view.frame = tmpFrame;
                
                break;
            }
            case PanAtTopLeftCorner: {
                x = MAX(-EXTRA_DISTANCE, MIN(tmpFrame.origin.x + translation.x, tmpFrame.origin.x + tmpFrame.size.width - MINIMUM_WIDTH + EXTRA_DISTANCE));
                y = MAX(-EXTRA_DISTANCE, MIN(tmpFrame.origin.y + translation.y, tmpFrame.origin.y + tmpFrame.size.height - MINIMUM_WIDTH + EXTRA_DISTANCE));
                width = tmpFrame.origin.x + tmpFrame.size.width - x;
                height = tmpFrame.origin.y + tmpFrame.size.height - y;
                
                tmpFrame = CGRectMake(x, y, width, height);
                recognizer.view.frame = tmpFrame;
                break;
            }
            case PanAtTopRightCorner: {
                height = MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.height - translation.y), tmpFrame.size.height + tmpFrame.origin.y + EXTRA_DISTANCE);
                width =  MIN(MAX(MINIMUM_WIDTH, tmpFrame.size.width + translation.x), calculateView.frame.size.width - tmpFrame.origin.x + EXTRA_DISTANCE);
                tmpFrame = CGRectMake(tmpFrame.origin.x, tmpFrame.origin.y + tmpFrame.size.height - height, width, height);
                
                recognizer.view.frame = tmpFrame;
                break;
            }
                
            default:
                break;
        }
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
        [calculateView setNeedsDisplay];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frame = calculateView.scaleView.frame;
        
        self.currentBox = [[Box alloc] initWithX1:(frame.origin.x + EXTRA_DISTANCE) * boxRatio
                                               y1:(frame.origin.y + EXTRA_DISTANCE) * boxRatio
                                               x2:(frame.origin.x + frame.size.width - EXTRA_DISTANCE) * boxRatio
                                               y2:(frame.origin.y + frame.size.height - EXTRA_DISTANCE) * boxRatio];
        [self.imageCache removeAllObjects];
        [self uploadSearch];
    }
}

PanPostition getPosition(CGPoint position, CGFloat width, CGFloat height){
    CGFloat x = position.x;
    CGFloat y = position.y;
    
    PanPostition panPostion = PanAtNone;
    if (y >= height - GESTURE_DETECTION_LENGTH &&
        x >= width - GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtBottomRightCorner;
    }
    else if (y >= height - GESTURE_DETECTION_LENGTH &&
             x <= GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtBottomLeftCorner;
    }
    else if (y <= GESTURE_DETECTION_LENGTH &&
             x <= GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtTopLeftCorner;
    }
    else if (y <= GESTURE_DETECTION_LENGTH &&
             x >= width - GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtTopRightCorner;
    }
    else if (x >= GESTURE_DETECTION_LENGTH &&
             x <= width - GESTURE_DETECTION_LENGTH &&
             y >= GESTURE_DETECTION_LENGTH
             && y <= height - GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtCenter;
    }
    else if (x <= GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtCenter;
    }
    else if (y <= GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtCenter;
    }
    else if (x >= width - GESTURE_DETECTION_LENGTH) {
        panPostion = PanAtCenter;
    }
    else if (y >= height - GESTURE_DETECTION_LENGTH){
        panPostion = PanAtCenter;
    }
    
    return panPostion;
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
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate backToCamera];
        }];
    });
}

- (IBAction)rotateButtonPressed:(id)sender {
    if (self.searchResults.imageResultsArray.count > 0) {
        rotationAngle = (rotationAngle + 90) % 360;
        
        self.image = [self.generalService rotateImage:self.image withAngle:rotationAngle];
        
        self.originalImage = self.image;
        [self uploadSearch];
        [self initDisplayView];
    }
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
                             [self.dynamicCollectionView setFrame:self.collectionView.frame];
                             
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
                             [self.dynamicCollectionView setBounces:YES];
                             
                             CGRect frame = self.collectionView.frame;
                             [self.collectionView setFrame:CGRectMake(frame.origin.x,
                                                                      frame.origin.y,
                                                                      frame.size.width,
                                                                      frame.size.height - self.topView.frame.size.height)];
                             [self.dynamicCollectionView setFrame:self.collectionView.frame];
                             
                             self.bottomCloseButton.hidden = YES;
                             self.bottomHomeButton.hidden = YES;
                             self.cropButton.hidden = YES;
                             self.cropButtonImageView.hidden = YES;
                             
                             [self.view bringSubviewToFront:self.topView];
                         }];
    }
}

- (IBAction)changeViewButtonClicked:(id)sender {
    UIButton *button = (UIButton*) sender;
    isDynamicView = !isDynamicView;
    
    if (isDynamicView) {
        [self showDynamicCollectionView];
        [button setImage:[UIImage imageNamed:IMAGE_DYNAMIC_VIEW] forState:UIControlStateNormal];
    } else {
        [self hideDynamicCollectionView];
        [button setImage:[UIImage imageNamed:IMAGE_SQUARE_VIEW] forState:UIControlStateNormal];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:SEGUE_DETAIL]) {
        ImageResult *result = [self.searchResults.imageResultsArray objectAtIndex:self.selectedIndex];
        DetailViewController *vc = [segue destinationViewController];
        vc.imageResult = result;
    }
}

@end
