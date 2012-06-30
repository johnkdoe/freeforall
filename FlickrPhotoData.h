//
//  FlickrPhotoData.h
//  voyeur
//
//  Created by me on 2012.06.28.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScrollableImageDetailViewController;

@interface FlickrPhotoData : NSObject

+ (FlickrPhotoData*)flickrPhotoDataWithObjects:(NSArray*)objects forKeys:(NSArray*)keys;
+ (FlickrPhotoData*)flickrPhotoDataWithDictionary:(NSDictionary*)plainPhotoDataDictionary;

+ (NSArray*)flickrPhotoArray:(NSArray*)plainPhotoArray;
+ (NSArray*)userDefaultsPhotoArray:(NSArray*)flickrPhotoArray;

- (id)objectForKey:(id)key;

@property (readonly) NSString* idFlickr;
@property (readonly) NSString* title;
@property (readonly) NSString* descriptionContent;
@property (readonly, getter = hasLatitudeLongitude) BOOL latitudeLongitude;
@property (readonly) NSDecimalNumber* latitude;
@property (readonly) NSDecimalNumber* longitude;
@property (readonly) NSURL* originatingURL;
@property (readonly) NSDictionary* imageRetrievalError;

- (NSUInteger)findMatchingIndexInPhotoArray:(NSArray*)photoSet;

//- (UIImage*)retrieveImageWithFormat:(NSString*)format;
//- (UIImage*)retrieveImage;

- (UIImage*)retrieveThumbnail;

- (void)displayImageInController:(ScrollableImageDetailViewController*)imageDetailVC;

@end
