//
//  FlickrRestAPI.h
//
//  Copyright 2012 xolaware

#define FLICKR_API_PHOTO_TITLE @"title"
#define FLICKR_API_PHOTO_DESCRIPTION @"description._content"
#define FLICKR_API_PLACE_ID @"place_id"
#define FLICKR_API_PLACE_NAME @"_content"
#define FLICKR_API_PLACE_URL @"place_url"

#define FLICKR_API_PHOTO_ID @"id"
#define FLICKR_API_PHOTO_LICENSE @"license"
#define FLICKR_API_PHOTO_OWNER @"ownername"

#define FLICKR_API_LATITUDE @"latitude"
#define FLICKR_API_LONGITUDE @"longitude"

#define FLICKR_API_MAX_PHOTOS_PER_PAGE 30
#define FLICKR_API_MAX_PHOTOS 500

#define FLICKR_API_INTERESTING_FORMAT	@".interestingness.getList&per_page=%d&page=%d%@"
#define FLICKR_API_RECENT_FORMAT		@".photos.getRecent&per_page=%d&page=%d%@"

@class FlickrPhotoData;
@class NSArray;
@class NSDictionary;
@class NSURL;

@interface FlickrRestAPI : NSObject

+ (NSArray*)recentGeoreferencedPhotos;
+ (NSArray*)topPlaces;
+ (NSArray*)backupTopPlaces;
+ (NSArray*)photosInPlace:(NSDictionary*)place maxResults:(int)maxResults;
+ (NSArray*)recentUsingFormat:(NSString*)apiFormat count:(int)maxResults page:(int)page;
+ (NSDictionary*)readableParts:(NSDictionary*)place;
+ (NSURL*)farmUrlForPhoto:(FlickrPhotoData*)place withFormat:(NSString*)format;
+ (NSURL*)urlForThumbnailAttributionForPhoto:(FlickrPhotoData*)photo;

#define FLICKR_SAN_DIEGO_URL @"/United+States/California/San+Diego"

+ (NSDictionary*)pacificBeach;

@end
