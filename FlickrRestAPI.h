//
//  FlickrRestAPI.h
//
//  Copyright 2012 xolaware


#import <Foundation/Foundation.h>

#define FLICKR_API_PHOTO_TITLE @"title"
#define FLICKR_API_PHOTO_DESCRIPTION @"description._content"
#define FLICKR_API_PLACE_ID @"place_id"
#define FLICKR_API_PLACE_NAME @"_content"
#define FLICKR_API_PLACE_URL @"place_url"
#define FLICKR_API_PHOTO_ID @"id"
#define FLICKR_API_PHOTO_OWNER @"ownername"
#define FLICKR_API_LATITUDE @"latitude"
#define FLICKR_API_LONGITUDE @"longitude"

@interface FlickrRestAPI

+ (NSArray*)recentGeoreferencedPhotos;
+ (NSArray*)topPlaces;
+ (NSArray*)photosInPlace:(NSDictionary*)place maxResults:(int)maxResults;
+ (NSDictionary*)readablePlaceParts:(NSDictionary*)photo;
+ (NSURL*)urlForPhoto:(NSDictionary*)photo withFormat:(NSString*)format;

@end
