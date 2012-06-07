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

#define FLICKR_API_MAX_PHOTOS_PER_PAGE 30

@interface FlickrRestAPI

+ (NSArray*)recentGeoreferencedPhotos;
+ (NSArray*)topPlaces;
+ (NSArray*)photosInPlace:(NSDictionary*)place maxResults:(int)maxResults;
+ (NSDictionary*)readablePlaceParts:(NSDictionary*)photo;
+ (NSURL*)farmUrlForPhoto:(NSDictionary*)photo withFormat:(NSString*)format;
+ (NSDictionary*)sizesForPhoto:(NSDictionary*)photo;
+ (NSURL*)urlForThumbnailAttributionForPhoto:(NSDictionary*)photo;

#define FLICKR_SAN_DIEGO_URL @"/United+States/California/San+Diego"

+ (NSDictionary*)pacificBeach;

@end
