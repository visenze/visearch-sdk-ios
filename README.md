# ViSearch iOS SDK

[![Build Status](https://travis-ci.org/visenze/visearch-sdk-ios.svg)](https://travis-ci.org/visenze/visearch-sdk-ios)

---

##Table of Contents
 1. [Overview](#1-overview)
 2. [Setup](#2-setup)
 	  - 2.1 [Install the SDK](#21-install-the-sdk)
 	  - 2.2 [Add User Permissions](#22-add-user-permissions)
 3. [Initialization](#3-initialization)
 4. [Searching Images](#4-searching-images)
	  - 4.1 [Pre-indexed Search](#41-pre-indexed-search)
	  - 4.2 [Color Search](#42-color-search)
	  - 4.3 [Upload Search](#43-upload-search)
	    - 4.3.1 [Selection Box](#431-selection-box)
	    - 4.3.2 [Resizing Settings](#432-resizing-settings)
 5. [Search Results](#5-search-results)
 6. [Advanced Search Parameters](#6-advanced-search-parameters)
	  - 6.1 [Retrieving Metadata](#61-retrieving-metadata)
	  - 6.2 [Filtering Results](#62-filtering-results)
	  - 6.3 [Result Score](#63-result-score)
 7. [Code Samples](#7-code-samples)

---


##1. Overview
ViSearch is an API that provides accurate, reliable and scalable image search. ViSearch API provides two services (Data API and Search API) to let the developers prepare image database and perform image searches efficiently. ViSearch API can be easily integrated into your web and mobile applications. For more details, see [ViSearch API Documentation](http://www.visenze.com/docs/overview/introduction).

The ViSearch iOS SDK is an open source software to provide easy integration of ViSearch Search API with your iOS applications. It provides three search methods based on the ViSearch Search API - pre-indexed search, color search and upload search. For source code and references, please visit the [Github Repository](https://github.com/visenze/visearch-sdk-ios).

>Current stable version: 1.0.7

>Supported iOS version: iOS 6.x and higher 


##2. Setup

###2.1 Set up Xcode project

In Xcode, go to File > New > Project Select the Single View Application.

![screenshot](https://www.visenze.com/docs/sites/default/files/Screen%20Shot%202015-01-09%20at%206.20.03%20PM.png)

Type a name for your project and press Next, here we use Demo as the project name.

-![screenshot](https://www.visenze.com/docs/sites/default/files/Screen%20Shot%202015-01-09%20at%206.20.17%20PM.png)

###2.2 Import ViSearch SDK

####2.2.1 Using CocoaPods

First you need to install the Cocoapods Ruby gem:

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
pod 'ViSearch', '~>1.0.7'
...
```

Install the ViSearch SDK:

```
pod install
```
The Demo.xcworkspace project should be created.

#### 2.2.2 Using Manual Approach

You can also download the iOS [ViSearch SDK](https://github.com/visenze/visearch-sdk-ios/archive/master.zip) directly. To use it, unzip it and drag ViSearch SDK folder into Demo project's file folder.

-![screenshot](https://www.visenze.com/docs/sites/default/files/Screen%20Shot%202015-01-09%20at%207.02.44%20PM.png)

Then add it to your project

-![screenshot](https://www.visenze.com/docs/sites/default/files/Screen%20Shot%202015-01-09%20at%207.03.28%20PM.png)


##3. Initialization
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

##4. Searching Images

###4.1 Pre-indexed Search
Search similar images based on the your indexed image by its unique identifier (im_name):

```objectivec
#import <ViSearch/VisearchAPI.h>
...
SearchParams *searchParams = [[SearchParams alloc] init];
searchParams.imName = @"imName-example";
    
[[ViSearchAPI defaultClient] 
	searchWithProductId:searchParams 
	success:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request succeeds
	} failure:^(NSInteger statusCode, ViSearchResult *data, NSError *error) {
	// Do something when request fails
	}];
...
```

###4.2 Color Search
Color search is to search images with similar color by providing a color code. The color code should be in **Hexadecimal** and passed to `ColorSearchParams` as a `String`.

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

###4.3 Upload Search
Upload search is used to search similar images by uploading an image or providing an image url. `Image` class is used to perform the image encoding and resizing. You should construct the `Image` object and pass it to `UploadSearchParams` to start a search.


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

####4.3.1 Selection Box
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

####4.3.2 Resizing Settings
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


##5. Search Results

After a successful search request, a list of results are passed to the callback function in the form of **ViSearchResult**.  You can use following properties from the result to fulfill your own purpose.

| Name | Type | Description |
| ---- | ---- | ----------- |
|success|BOOL|Is the request handled by the server successfully. <br>**Note**: invalid parameters sent to the server can also make this property **false**.|
|error|ViSearchError|Besides the error caused by network condition, it also shows the error caused by invalid parameters sent to the server.|
|content|NSDictionary|The complete json data returned from the server.(This property may be deprecated in the feature)|
|imageResultsArray|NSArray|A list of image results returned from the server.|

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

##6. Advanced Search Parameters

###6.1 Retrieving Metadata
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

###6.2 Filtering Results
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


###6.3 Result Score
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


##7. Code Samples
Source code of a demo application can be found [here](https://github.com/visenze/visearch-sdk-ios/tree/master/NewExample/ViSearchExample)
