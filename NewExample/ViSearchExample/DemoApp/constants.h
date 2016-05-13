//
//  constants.h
//  DemoApp
//
//  Created by ViSenze on 4/12/15.
//  Copyright © 2015 ViSenze. All rights reserved.
//
#import "UIColor+Custom.h"

#ifndef constants_h
#define constants_h

#pragma mark - Images
#define IMAGE_DELETE                            @"delete_icon"
static CGFloat const IMAGE_DELETE_WIDTH         = 33.0;
static CGFloat const IMAGE_DELETE_HEIGHT        = 40.0;
#define IMAGE_DYNAMIC_VIEW                      @"collectiondynamic"
#define IMAGE_SQUARE_VIEW                       @"collectionquare"
#define IMAGE_LOADING                           @"loading_%d"

#pragma mark - Animation
static CGFloat const ANIMATION_DURATION         = 0.5;

#pragma mark - segue
#define SEGUE_CAMERA                            @"homeToCamera"
#define SEGUE_HOME                              @"cameraToHome"
#define SEGUE_PREVIEW                           @"cameraToPreview"
#define SEGUE_RESULT                            @"previewToResult"
#define SEGUE_DETAIL                            @"resultToDetail"
#define SEGUE_CROP                              @"resultToCrop"
#define SEGUE_ZOOM                              @"detailToZoom"

#pragma mark - Database
#define ENTITY_NAME                             @"Applications"
static int const IMG_QUERY_LIMIT                = 30;
static int const IMG_LOAD_LIMIT                 = 16;
static int const IMG_LOAD_INCREASE              = 9;

#pragma mark - Loading
#define LOADING_MSG_1                           @"Analysing"
#define LOADING_MSG_2                           @"Analysing."
#define LOADING_MSG_3                           @"Analysing.."
#define LOADING_MSG_4                           @"Analysing..."

#pragma mark - QR code sucess and error
#define SUCCESS                                 0
#define ERROR_DUPLICATE                         1
#define ERROR_INCORRECT_CODE                    2
#define ERROR_MSG_DUPLICATE                     @"Below application database has already in your list, please scan another one"
#define ERROR_MSG_INCORRECT                     @"Below QR code is invalid, please scan another one"

#pragma mark - Preview Controller
#define KEY_IMAGE                               @"image"
#define KEY_IMAGE_NAME                          @"im_name"
#define KEY_SCORE                               @"score"
#define KEY_PRODUCT_TYPE                        @"product_types"
#define KEY_PRODUCT_TYPES_LIST                  @"product_types_list"
#define KEY_TYPE                                @"type"
#define KEY_BOX                                 @"box"

#pragma Detail Controller
#define MSG_UP_SEARCH_RESULT                    @"Search Results"
#define MSG_ID_SEARCH_RESULT                    @"Similar Items"
#define MSG_SEARCHING                           @"Searching..."
#define MSG_LOADING                             @"Loading..."

#define MSG_RATE_BUTTON                         @"Rate this\nResult"

#define CELL_DETAIL_IDENTIFIER                  @"SearchResultCollectionViewCell"
#define CELL_DETAIL_SIMILARITY_MSG              @"Similarity %.0f%%"
#define DEFAULT_TYPE                            @"default"

static int const IMAGE_NAME_LENGTH_LIMIT        = 18;
//Scaler View
static CGFloat const SCALE_VIEW_BORDER_WIDTH    = 3;
static CGFloat const SCALER_VIEW_LENGTH         = 20.0;
static CGFloat const EXTRA_DISTANCE             = 15.0;
static CGFloat const MINIMUM_WIDTH              = 60 + 2 * EXTRA_DISTANCE;
static CGFloat const GESTURE_DETECTION_LENGTH   = EXTRA_DISTANCE * 3;// + SCALER_VIEW_LENGTH;

static CGFloat const COMPRESSED_IMAGE_SIZE      = 1024.0;
static inline double radians (double degrees) {return degrees * M_PI/180;}

#endif /* constants_h */
