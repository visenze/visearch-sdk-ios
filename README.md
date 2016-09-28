# ViSearch iOS SDK and Demo Source Code

[![Build Status](https://travis-ci.org/visenze/visearch-sdk-ios.svg)](https://travis-ci.org/visenze/visearch-sdk-ios)

---

##Table of Contents
 1. [Overview](#1-overview)
 2. [Setup](#2-setup)
      - 2.1 [Run the Demo](#21-run-the-demo)
      - 2.2 [Set up Xcode Project](#22-set-up-xcode-project)
      - 2.3 [Import ViSearch SDK](#23-import-visearch-sdk)
      - 2.4 [Add Privacy Usage Description](#24-add-privacy-usage-description)
 3. [Initialization](#3-initialization)
 4. [Solutions](#4-solutions)
    - 4.1 [Find Similar](#41-find-similar)
    - 4.2 [You May Also Like](#42-you-may-also-like)
    - 4.3 [Search by Image](#43-search-by-image)
	    - 4.3.1 [Selection Box](#431-selection-box)
	    - 4.3.2 [Resizing Settings](#432-resizing-settings)
    - 4.4 [Search by Color](#44-search-by-color)
 5. [Search Results](#5-search-results)
 6. [Advanced Search Parameters](#6-advanced-search-parameters)
	  - 6.1 [Retrieving Metadata](#61-retrieving-metadata)
	  - 6.2 [Filtering Results](#62-filtering-results)
	  - 6.3 [Result Score](#63-result-score)
	  - 6.4 [Automatic Object Recognition Beta](#64-automatic-object-recognition-beta)
 7. [Event Tracking](#7-event-tracking)

---


## 1. Overview

ViSearch is an API that provides accurate, reliable and scalable image search. ViSearch API provides two services (Data API and Search API) to let the developers prepare image database and perform image searches efficiently. ViSearch API can be easily integrated into your web and mobile applications. For more details, see [ViSearch API Documentation](http://www.visenze.com/docs/overview/introduction).

The ViSearch iOS SDK is an open source software to provide easy integration of ViSearch Search API with your iOS applications. It provides four search methods based on the ViSearch Solution APIs - Find Similar, You May Also Like, Search By Image and Search By Color. For source code and references, please visit the [Github Repository](https://github.com/visenze/visearch-sdk-ios).

>Current stable version: 1.1.0

>Supported iOS version: iOS 7.x and higher


## 2. Setup

### 2.1 Run the Demo

The source code of a demo application is provided together with the SDK ([demo](https://github.com/visenze/visearch-sdk-ios/tree/master/NewExample/ViSearchExample)). You can simply open **ViSearchExample** project in XCode and run the demo.

![screenshot](./doc/xcode_1.png)

You should change the access key and secret key to your own key pair before running.

```objectivec
@implementation HomeViewController {
    NSMutableArray *rectangles;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    rectangles = [[NSMutableArray alloc] init];
    self.generalService = [GeneralServices sharedInstance];

    //TODO: insert your own application keys
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"YOUR_ACCESS_KEY" forKey:@"access_key"];
    [dict setValue:@"YOUR_SECRET_KEY" forKey:@"secret_key"];
    [[CoreDataModel sharedInstance] insertApplication:dict];
}
```

You can play around with our demo app to see how we build up the cool image search feature using ViSearch SDK.

![ios_demo](./doc/ios_demo.png)


### 2.2 Set up Xcode project

In Xcode, go to File > New > Project Select the Single View Application.

![screenshot](./doc/ios0.png)

Type a name for your project and press Next, here we use Demo as the project name.

![screenshot](./doc/ios1.png)

### 2.3 Import ViSearch SDK

#### 2.3.1 Using CocoaPods

First you need to install the CocoaPods Ruby gem:

```
[sudo] gem install cocoapods
pod setup
```

Then go to your project directory to create an empty Podfile
```
cd /path/to/Demo
pod init
```

Edit the Podfile as follow:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
...
pod 'ViSearch', '~>1.1.0'
...
```

Install the ViSearch SDK:

```
pod install
```
The Demo.xcworkspace project should be created.

#### 2.3.2 Using Manual Approach

You can also download the iOS [ViSearch SDK](https://github.com/visenze/visearch-sdk-ios/archive/master.zip) directly. To use it, unzip it and drag ViSearch SDK folder into Demo project's file folder.

![screenshot](./doc/ios2.png)

Then add it to your project

![screenshot](./doc/ios3.png)

### 2.4 Add Privacy Usage Description

iOS 10 now requires user permission to access camera and photo library. If your app requires these access, please add description for NSCameraUsageDescription, NSPhotoLibraryUsageDescription in the Info.plist. More details can be found [here](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW24).

## 3. Initialization
`ViSearch` **must** be initialized with an accessKey/secretKey pair **before** it can be used.

```objectivec
#import <ViSearch/VisearchAPI.h>
...
// using default ViSearch client. The client, by default,
// connects to Visenze's server
static NSString * const accessKey = @"your_access_key";
static NSString * const privateKey = @"your_secret_key";

[ViSearchAPI setupAccessKey:accessKey andSecretKey:secretKey];
ViSearchClient *client = [ViSearch defaultClient];
...
// or using customized client, which connects to your own server
static NSString * const privateKey = @"your_url";
ViSearchClient *client = [[ViSearchClient alloc] initWithBaseUrl:url
	accessKey:accessKey secretKey:secretKey];
...
```

## 4. Solutions

### 4.1 Find Similar
**Find similar** solution is used to search for visually similar images in the image database giving an indexed image’s unique identifier (im_name).

```objectivec
#import <ViSearch/VisearchAPI.h>
...
SearchParams *searchParams = [[SearchParams alloc] init];
searchParams.imName = @"imName-example";

[[ViSearchAPI defaultClient]
	searchWithImageId:searchParams
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request succeeds
	} failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request fails
	}];
...
```

### 4.2 You May Also Like
**You may also like** solution is used to provide a list of recommended items from the indexed image database based on customizable rules giving an indexed image’s unique identifier (im_name).

```objectivec
#import <ViSearch/VisearchAPI.h>
...
SearchParams *searchParams = [[SearchParams alloc] init];
searchParams.imName = @"imName-example";

[[ViSearchAPI defaultClient]
	recommendWithImageName:searchParams
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request succeeds
	} failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request fails
	}];
...
```

### 4.3 Search by Image
**Search by image** solution is used to search similar images by uploading an image or providing an image url. `Image` class is used to perform the image encoding and resizing. You should construct the `Image` object and pass it to `UploadSearchParams` to start a search.


* Using  UIImage

```objectivec
#import <ViSearch/VisearchAPI.h>
...
UIImage *image = [UIImage imageNamed:@"example.jpg"];

UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
uploadSearchParams.imageFile = image

[[ViSearchAPI defaultClient]
	searchWithImageData:uploadSearchParams
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request succeeds
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request fails
    }];
```

* Alternatively, you can pass an image url directly to `uploadSearchParams` to start the search :

```objectivec
#import <ViSearch/VisearchAPI.h>
...
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
uploadSearchParams.imageUrl = @"http://example.com/example.jpg";

[[ViSearchAPI defaultClient]
	searchWithImageUrl:uploadSearchParams
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request succeeds
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request fails
    }];
...
```

* Once uploading an image, you will receive a im\_id attribute from the [Search Results](#5-search-results). If you want to search the same image again, you can save your bandwidth by specifying the im\_id in the params:

```objectivec
#import <ViSearch/VisearchAPI.h>
...
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
uploadSearchParams.imId = visearchResult.imId;

[[ViSearchAPI defaultClient]
	searchWithImage:uploadSearchParams
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request succeeds
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request fails
    }];
...
```
#### 4.3.1 Selection Box
If the object you wish to search for takes up only a small portion of your image, or other irrelevant objects exists in the same image, chances are the search result could become inaccurate. Use the Box parameter to refine the search area of the image to improve accuracy. The box coordinated is set with respect to the original size of the uploading image. Note: the coordinate system uses pixel as unit instead of point.

```objectivec
// create the box to refine the area on the searching image
// Box(x1, y1, x2, y2) where (0,0) is the top-left corner
// of the image, (x1, y1) is the top-left corner of the box,
// and (x2, y2) is the bottom-right corner of the box.
...
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];

Box *box = [[Box alloc]initWithX1:0 y1:0 x2:100 y2:100];
uploadSearchParams.box = box;

// start searching
...
```

#### 4.3.2 Resizing Settings
When performing upload search, you may notice the increased search latency with increased image file size. This is due to the increased time spent in network transferring your images to the ViSearch server, and the increased time for processing larger image files in ViSearch.

To reduce upload search latency, by default the uploadSearch method makes a copy of your image file and resizes the copy to 512x512 pixels if one of the original dimensions exceed 512 pixels. This is the optimized size to lower search latency while not sacrificing search accuracy for general use cases:

```objectivec
// by default, the max width of the image is set to 512px, quality is 0.97
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
// or you can explicitly set a param's settings
uploadSearchParams.settings = [ImageSettings defaultSettings];
```

If your image contains fine details such as textile patterns and textures, you can use an image with larger size for search to get better search result:

```objectivec
// by default, the max width of the image is set to 512px, quality is 0.97
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
// set the image with high quality settings.
// Max width is 1024px, and the quality is 0.985. Note: Quality with 1.0 take hugespace
uploadSearchParams.settings = [ImageSettings highqualitySettings];
```

Or, provide the customized resize settings. To make efficient use the of the memory and network bandwidth of mobile device, the maximum size is set at 1024 x 1024. Any image exceeds the limit will be resized to the limit:

```objectivec
//resize the image to 800 by 800 area using jpeg 0.9 quality
uploadSearchParams.settings = [[ImageSettings alloc]
	initWithSize:CGSizeMake(800, 800) Quality:0.9];
```

### 4.4 Search by Color
**Search by color** solution is used to search images with similar color by providing a color code. The color code should be in **Hexadecimal** and passed to `ColorSearchParams` as a `String`.

```objectivec
#import <ViSearch/VisearchAPI.h>
...
ColorSearchParams *colorSearchParams = [[ColorSearchParams alloc] init];
colorSearchParams.color = @"012ACF";

[[ViSearchAPI defaultClient]
	searchWithColor:colorSearchParams
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
    // Do something when request succeeds   
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
    // Do something when request fails
    }];
...
```

## 5. Search Results

After a successful search request, a list of results are passed to the callback function in the form of **ViSearchResult**.  You can use following properties from the result to fulfill your own purpose.

| Name | Type | Description |
| ---- | ---- | ----------- |
|success|BOOL|Is the request handled by the server successfully. <br>**Note**: invalid parameters sent to the server can also make this property **false**.|
|error|ViSearchError|Besides the error caused by network condition, it also shows the error caused by invalid parameters sent to the server.|
|content|NSDictionary|The complete json data returned from the server.(This property may be deprecated in the feature)|
|imageResultsArray|NSArray|A list of image results returned from the server.|
|reqId|NSString|A request id which can be used for tracking. More details can be found in [Section 7](#7-event-tracking) |
|imId|NSString|An image id returned in the result which represents a image just uploaded. It can be re-used to do an upload search on the same image again. More details in [Upload Search](#43-upload-search)|

You are encouraged to use the imageResultsArray, since **content** property may be deprecated in the future. Every image result is in the form of **ImageResult**. You can use following properties of a **ImageResult** to fulfill your own purpose.

| Name | Type | Description |
| ---- | ---- | ----------- |
|im_name|NSString|the identify name of the image.|
|url|NSString|url of the image.|
|score|CGFloat|A float value ranging from 0.0 to 1.0. Refer to *Section 6.3 Result Score*.|
|metadataDictionary|NSDictionary|Other metadata returned from server. Refer to *Section 6.1 Retrieving Metadata*.|
```objectivec
// This is an example of image url search.
// The process of handling results by other kinds of search is similar.
[[ViSearchAPI defaultClient]
	searchWithImageUrl:uploadSearchParams
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
		// Iterate all returned results
		for (ImageResult *result in data.imageResultsArray) {
			NSLog("%@", result.url);//log result's image url.
			//Do something here
		}
    } failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
		NSLog("%@", data.error.message);//log network and server error message
    }];
```

 You can provide pagination parameters to control the paging of the image search results. by configuring the basic search parameters `BaseSearchParams`. As the result is returned in a format of a list of images page by page, use `setLimit` to set the number of results per page, `setPage` to indicate the page number:

| Name | Type | Description |
| ---- | ---- | ----------- |
| page | Integer | Optional parameter to specify the page of results. The first page of result is 1. Defaults to 1. |
| limit | Integer | Optional parameter to specify the result per page limit. Defaults to 10. |

```objectivec
// For example, when the server side has 60 items, the search operation will return
// the first 30 items with page = 1 and limit = 30. By changing the page to 2,
// the search will return the last 30 items.
...
SearchParams *searchParams = [[SearchParams alloc] init];
searchParams.page = 2;
searchParams.limit = 30;

// start searching
...
```

## 6. Advanced Search Parameters

### 6.1 Retrieving Metadata
To retrieve metadata of your search results, provide a list of metadata keys as the `fl` (field list) in the basic search property:

```objectivec
SearchParams *searchParams = [[SearchParams alloc] init];
searchParams.fl = @[@"price",@"brand",@"im_url"];
```

To retrieve all metadata of your image results, specify get_all_fl parameter and set it to true:
```objectivec
SearchParams *searchParams = [[SearchParams alloc] init];
searchParams.getAllFl = true;
```

In result callback you can read the metadata:
```objectivec
success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Iterate all returned results
	for (ImageResult *result in data.imageResultsArray) {
		NSLog("%@", result.metadataDictionary);//log result's metadata.
		NSLog("%@", [result.metadataDictionary
			objectForKey;@"price"]);//log price in metadata
		//Do something here
	}
}
```

>Only metadata of type string, int, and float can be retrieved from ViSearch. Metadata of type text is not available for retrieval.

### 6.2 Filtering Results
To filter search results based on metadata values, provide a map of metadata key to filter value as the `fq` (filter query) property:

```objectivec
...
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];

// the type of "count" on db schema is int,
// so we can specify the value range, or do a value match
[uploadSearchParams.fq setObject:@"0, 199" forKey:@"count"];
[uploadSearchParams.fq setObject:@"199" forKey:@"count"];

// the type of "price" on db schema is float,
// so we can specify the value range, or do a value match
[uploadSearchParams.fq setObject:@"0.0, 199.0" forKey:@"price"];
[uploadSearchParams.fq setObject:@"15.0" forKey:@"price"];

// the type of "description" on db schema is string, so we can do a string match.
[uploadSearchParams.fq setObject:@"description" forKey:@"wooden"];

// start searching
...
```

Querying syntax for each metadata type is listed in the following table:

Type | FQ
--- | ---
string | Metadata value must be exactly matched with the query value, e.g. "Vintage Wingtips" would not match "vintage wingtips" or "vintage"
text | Metadata value will be indexed using full-text-search engine and supports fuzzy text matching, e.g. "A pair of high quality leather wingtips" would match any word in the phrase
int | Metadata value can be either: <ul><li>exactly matched with the query value</li><li>matched with a ranged query ```minValue,maxValue```, e.g. int value ```1, 99```, and ```199``` would match ranged query ```0,199``` but would not match ranged query ```200,300```</li></ul>
float | Metadata value can be either <ul><li>exactly matched with the query value</li><li>matched with a ranged query ```minValue,maxValue```, e.g. float value 1.0, 99.99, and 199.99 would match ranged query ```0.0,199.99``` but would not match ranged query ```200.0,300.0```</li></ul>


### 6.3 Result Score
ViSearch image search results are ranked in descending order i.e. from the highest scores to the lowest, ranging from 1.0 to 0.0. By default, the score for each result is not returned. You can turn on the score parameter to retrieve the scores for each image result:

```java
...
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
uploadSearchParams.score = YES; // result will include score for every image

// start searching
...

```

If you need to restrict search results from a minimum score to a maximum score, specify the score_min and/or score_max parameters:
```objectivec
...
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
uploadSearchParams.score = YES; // result will include score for every image
uplaodSearchParams.scoreMin = 0.3; // the minimum score is 0.3  
uplaodSearchParams.scoreMax = 0.8; // the maximum score is 0.8

// start searching. Every image result will have a score within [0.3, 0.8].
...
```

### 6.4 Automatic Object Recognition Beta
With Automatic Object Recognition, ViSearch /uploadsearch API is smart to detect the objects present in the query image and suggest the best matched product type to run the search on.

You can turn on the feature in upload search by setting the API parameter "detection=all". We are now able to detect various types of fashion items, including `Top`, `Dress`, `Bottom`, `Shoe`, `Bag`, `Watch` and `Indian Ethnic Wear`. The list is ever-expanding as we explore this feature for other categories.

Notice: This feature is currently available for fashion application type only. You will need to make sure your app type is configurated as "fashion" on [ViSenze dashboard](https://developers.visenze.com/setup/#Choose-Your-Application-Type).

```java
params.detection = @"all";
```
You can use the Box parameter to restrict the image area [x1, y1, x2, y2] as the portion of your image to search for. When you input a box with 0 width and 0 height, eg. “box”:[574,224,574,224]. We will treat it as a point and detect the object over the current point.

![](https://developers.visenze.com/api/images/detection_point.png)

You could also recognize objects from a paticular type on the uploaded query image through configuring the detection parameter to a specific product type as "detection={type}". Our API will run the search within that product type.

Sample request to detect `bag` in an uploaded image:

```java
params.detection = @"bag";
```

The detected product types are listed in `product_types` together with the match score and box area of the detected object. Multiple objects can be detected from the query image and they are ranked from the highest score to lowest. The full list of supported product types by our API will also be returned in `product_types_list`.

## 7. Event Tracking

### Send Action For Tracking
User action can be sent in this way:

```objectivec
TrackParams *params = [TrackParams createWithCID:@"1234567" ReqId:reqId andAction:@"click"];
ViSearchClient *client = [ViSearchAPI defaultClient];
// ... client setup

// You can also append an im_name field
parmas.withImName(@"12345678");

[client track:params completion:^(BOOL success) {
	  // ... Your code here
 }];

```
The following fields could be used for tracking user events:

Field | Description | Required
--- | --- | ---
reqid| visearch request id of current search. This attribute can be accessed in ViSearchResult in [Section 5](#5-search-results) | Require
action | action type, eg: view, click, buy, add_cart. Currently, we only support click event. More events will be supported in the future. | Require
im_name | image id (im_name) for this behavior | Optional
