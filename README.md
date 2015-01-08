ViSearch iOS SDK
================
[![Build Status](https://api.travis-ci.org/Lincolnnus/visearch-sdk-ios.svg?branch=master)](https://travis-ci.org/Lincolnnus/visearch-sdk-ios)
This is the ViSearch Software Development Kit (SDK) for iOS. Version: 1.0.0
##Overview
The SDK provides the following Search APIs for your ViSearch Apps:
* ID Search API
* Color Search API
* Upload Search API

##Setup

1.  In the finder, drag ViSearchSDK into project's file folder.
2.  Add it to your project:
*File -> Add Files to "your project"
*Choose 'Recursively create groups for any added folders'

###Initialize
In your Application Delegate or View Controller:
````
Import ViSearchAPI.h
````
Add: ````[ViSearchAPI initWithAccessKey: @"" andSecretKey:@""];````
###Search API
Build a SearchParams object and call search.
````
SearchParams *searchParams = [[SearchParams alloc] init];
 searchParams.imName = @"im_name";
 ViSearchResult *visenzeResult = [[ViSearchAPI search] search:searchParams];
````
Build a ColorSearchParams object and call search.
````
ColorSearchParams *colorSearchParams = [[ColorSearchParams alloc] init];
colorSearchParams.color = colorSearchTextField.text;
ViSearchResult *visenzeResult = [[ViSearchAPI search] colorSearch:colorSearchParams];
````
Build a UploadSearchParams object and call uploadSearch.

* Upload search by URL
````
 UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
 uploadSearchParams.imageUrl = uploadSearchUrlTextField.text;
 ViSearchResult *visenzeResult = [[ViSearchAPI search] uploadSearch:uploadSearchParams];
````
* Upload search by image
````
UploadSearchParams *uploadSearchParams = [[UploadSearchParams alloc] init];
uploadSearchParams.imageFile = UIImageJPEGRepresentation(image, 0.5);
ViSearchResult *visenzeResult = [[ViSearchAPI search] uploadSearch:uploadSearchParams];
````

Configure advanced parameters
````
SearchParams *searchParams = [[SearchParams alloc] init];
searchParams.imName = idSearchTextField.text;
searchParams.fl = @[@"price",@"brand",@"im_url"];
ViSearchResult *visenzeResult = [[ViSearchAPI search] search:searchParams];
````

