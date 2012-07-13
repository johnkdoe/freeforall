//
//  FlickrRestAPI.m
//
//  Copyright 2012 xolaware

#import "FlickrRestAPI.h"
#import "FlickrPhotoData.h"
#import "xolawareBackground.h"

/* 
 
 from http://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html
 
 <license id="4" name="Attribution License"
				 url="http://creativecommons.org/licenses/by/2.0/" />
 <license id="6" name="Attribution-NoDerivs License"
				 url="http://creativecommons.org/licenses/by-nd/2.0/" />
 <license id="3" name="Attribution-NonCommercial-NoDerivs License"
				 url="http://creativecommons.org/licenses/by-nc-nd/2.0/" />
 <license id="2" name="Attribution-NonCommercial License"
				 url="http://creativecommons.org/licenses/by-nc/2.0/" />
 <license id="1" name="Attribution-NonCommercial-ShareAlike License"
				 url="http://creativecommons.org/licenses/by-nc-sa/2.0/" />
 <license id="5" name="Attribution-ShareAlike License"
				 url="http://creativecommons.org/licenses/by-sa/2.0/" />
 <license id="7" name="No known copyright restrictions"
				 url="http://flickr.com/commons/usage/" />
 */

/*
 available locales for flickr feeds

 de-de		German
 en-us		English
 es-us		Spanish
 fr-fr		French
 it-it		Italian
 ko-kr		Korean
 pt-br		Portuguese (Brazilian)
 zh-hk		Traditional Chinese (Hong Kong)

 */

#define API_REST_QUERY	@"http://api.flickr.com/services/rest/?method=flickr"

#define API_KEY @"ef789e4178df7b18913a932a32549945"
#define API_LANG_FORMAT	@"&lang=%@&format=json&nojsoncallback=1&api_key=ef789e4178df7b18913a932a32549945"

#define API_EXTRAS_ARGS	@"&extras=original_format,tags,description,geo,owner_name,place_url,license,url_s"

#define API_GEOREF_ARGS_FORMAT		@".photos.search&per_page=500&license=1,2,3,4,7&has_geo=1%@"
#define API_PLACE_ARGS_FORMAT		@".places.getInfo&place_id=%@"
#define API_PLACE_PHOTOS_FORMAT		@".photos.search&has_geo=1&place_id=%@&per_page=%d%@"
#define API_PHOTO_SIZES_FORMAT		@".photos.getSizes&photo_id=%@"
#define API_RECENT_UPLOADS_FORMAT	@".photos.recentlyUpdated&auth_token=72157630139169760-38bd6548de38d165&min_date=%@"
#define API_TOP_PLACES_ARGS			@".places.getTopPlacesList&place_type_id=7"

#define API_PACIFIC_BEACH			@".places.find&query=Pacific+Beach%2C+California%2C+92109"

#define API_PHOTOS	@"photos.photo"
#define API_PLACES	@"places.place"

@implementation FlickrRestAPI

+ (NSDictionary*)availableLanguages {
	static NSDictionary* _availableLanguages;
	if (!_availableLanguages)
		_availableLanguages = [NSDictionary dictionaryWithObjectsAndKeys:@"de-de", @"de",
																		 @"en-us", @"en",
																		 @"es-us", @"es",
																		 @"fr-fr", @"fr",
																		 @"it-it", @"it",
																		 @"pt-br", @"pt",
																		 @"zh-hk", @"zh",
																		 nil];
	return _availableLanguages;
}

+ (NSURL*)fullQueryURL:(NSString*)query {
	NSString* preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
//	NSLog(@"system language chosen by user = %@", preferredLang);
	if (!(preferredLang = [[self availableLanguages] objectForKey:preferredLang]))
		preferredLang = @"en-us";
//	NSLog(@"flickr available language chosen = %@", preferredLang);

	query = [query stringByAppendingFormat:API_LANG_FORMAT, preferredLang];
	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];	

//	NSLog(@"query = %@", query);

	return [NSURL URLWithString:query];
}

+ (NSDictionary*)query:(NSString *)query
{
	// prep as much as possible before doing the backgroundTaskWithExpirationHandler thing
	NSURLRequest* urlRequest
	  = [[NSURLRequest alloc] initWithURL:[self fullQueryURL:query]
							  cachePolicy:NSURLCacheStorageAllowedInMemoryOnly
						  timeoutInterval:15];	// sort of a long timeout; may adjust later
	xolawareBackgroundTaskBlock simpleDataRetrieval = ^id
	{
		NSError* error;
		NSURLResponse* urlResponse;
#if DEBUG
//		NSLog(@"starting request");
#endif
		id data = [NSURLConnection sendSynchronousRequest:urlRequest
										returningResponse:&urlResponse
													error:&error];
		if (error)
			if (NSURLErrorTimedOut == error.code)
				// eventually put this in a mini-alert of some sort
				NSLog(@"%@ URL = %@", error.localizedDescription,
					  [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey]);
			else if (NSURLErrorNotConnectedToInternet == error.code)
				// eventually put this in a mini-alert of some sort
				NSLog(@"%@ URL = %@", error.localizedDescription,
					  [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey]);
			else if (NSURLErrorNetworkConnectionLost == error.code)
				// eventually put this in a mini-alert of some sort
				NSLog(@"%@ URL = %@", error.localizedDescription,
					  [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey]);
#if DEBUG
			else
				NSLog(@"REST/json: %@", error);
//		NSLog(@"request complete");
		if (!data)
			NSLog(@"network data retrieval: no data");
#endif
		return data;
	};

	// xolawareBackground retriever allows the request results to be accepted in the background,
	// and then will pause; the return and processing of data will occur in the foreground.
	id rawData = [[xolawareBackground retriever:simpleDataRetrieval] getData];
	return rawData ? [NSJSONSerialization JSONObjectWithData:rawData options:0 error:nil] : nil;
}

+ (NSArray*)flickrPhotosQuery:(NSString*)request {
	return [FlickrPhotoData flickrPhotoArray:[[self query:request] valueForKeyPath:API_PHOTOS]];
}

+ (NSDictionary*)readableParts:(NSDictionary*)place
{
	NSString* request
	  = [API_REST_QUERY stringByAppendingFormat:API_PLACE_ARGS_FORMAT,
												[place valueForKey:FLICKR_API_PLACE_ID]];
	return [FlickrRestAPI query:request];
}

+ (NSArray*)recentGeoreferencedPhotos {
    NSString* request = [API_REST_QUERY stringByAppendingFormat:API_GEOREF_ARGS_FORMAT,
																API_EXTRAS_ARGS];
    return [FlickrRestAPI flickrPhotosQuery:request];
}

+ (NSArray*)topPlaces {
    NSString* request = [API_REST_QUERY stringByAppendingString:API_TOP_PLACES_ARGS];
    return [[FlickrRestAPI query:request] valueForKeyPath:API_PLACES];
}

+ (NSDictionary*)pacificBeach {
	NSString* request = [API_REST_QUERY stringByAppendingString:API_PACIFIC_BEACH];
	NSArray* resultArray = [[FlickrRestAPI query:request] valueForKeyPath:API_PLACES];
	return [resultArray objectAtIndex:0];
}

+ (NSArray*)photosInPlace:(NSDictionary *)place maxResults:(int)maxResults {
    NSString* placeId = [place objectForKey:FLICKR_API_PLACE_ID];
    if (!placeId)
		return nil;

	NSString* request
	  = [API_REST_QUERY stringByAppendingFormat:API_PLACE_PHOTOS_FORMAT, placeId, maxResults, 
												API_EXTRAS_ARGS];
	return [FlickrRestAPI flickrPhotosQuery:request];
}

+ (NSArray*)recentUsingFormat:(NSString*)apiFormat count:(int)maxResults page:(int)page
{
	NSString* request = [API_REST_QUERY stringByAppendingFormat:apiFormat, maxResults, page,
																API_EXTRAS_ARGS];
	return [FlickrRestAPI flickrPhotosQuery:request];
}

#ifdef DEBUG
#define API_XOLAWARE_SET_FORMAT		@".photosets.getPhotos&photoset_id=72157630005748939%@"
+ (NSArray*)xolawareSet:(int)maxResults
{
//	NSDate* twelveWeeksAgo = [NSDate dateWithTimeIntervalSinceNow:-(60*60*24*7*12)];
//	NSString* minDate = [[twelveWeeksAgo description] substringToIndex:10];
	NSString* request
	  = [API_REST_QUERY stringByAppendingFormat:API_XOLAWARE_SET_FORMAT, API_EXTRAS_ARGS];
	return [[FlickrRestAPI query:request] valueForKeyPath:@"photoset.photo"];
}
#endif

+ (NSString*)farmURLforPhoto:(FlickrPhotoData*)photo withFormat:(NSString*)format {
	/*
		from http://www.flickr.com/services/api/flickr.photos.getSizes.html
	 
	 <sizes canblog="1" canprint="1" candownload="1">
	 <size	label="Square" width="75" height="75"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_s.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/sq/"
			media="photo" />
	 <size label="Large Square" width="150" height="150"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_q.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/q/"
			media="photo" />
	 <size label="Thumbnail" width="100" height="75"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_t.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/t/"
			media="photo" />
	 <size label="Small" width="240" height="180"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_m.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/s/"
			media="photo" />
	 <size label="Small 320" width="320" height="240"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_n.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/n/"
			media="photo" />
	 <size label="Medium" width="500" height="375"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/m/"
			media="photo" />
	 <size label="Medium 640" width="640" height="480"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_z.jpg?zz=1"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/z/"
			media="photo" />
	 <size label="Medium 800" width="800" height="600"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_c.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/c/"
			media="photo" />
	 <size label="Large" width="1024" height="768"
			source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_b.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/l/"
			media="photo" />
	 <size label="Original" width="2400" height="1800"
			source="http://farm2.staticflickr.com/1103/567229075_6dc09dc6da_o.jpg"
			url="http://www.flickr.com/photos/stewart/567229075/sizes/o/"
			media="photo" />
	 </sizes>

	 */
	
	char formatChar;

	if ([@"Large" isEqualToString:format])
		formatChar = 'b';
	else if ([@"Original" isEqualToString:format])
		formatChar = 'o';
	else // if (!format || @"Square" isEqualToString:format)
		formatChar = 's';
	
	id farm = [photo objectForKey:@"farm"];
	id server = [photo objectForKey:@"server"];
	id photo_id = [photo objectForKey:@"id"];

	id secret;
	NSString* fileType;
	if ('o' == formatChar)
	{
		secret = [photo objectForKey:@"originalsecret"];    
		fileType = [photo objectForKey:@"originalformat"];
	}
	else
	{
		secret = [photo objectForKey:@"secret"];
		fileType = @"jpg";
	}

	if (!farm || !server || !photo_id || !secret) 
		return nil;

	return [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%c.%@",
									  farm, server, photo_id, secret, formatChar, fileType];
}

+ (NSURL *)farmUrlForPhoto:(FlickrPhotoData*)photo withFormat:(NSString*)format {
    return [NSURL URLWithString:[self farmURLforPhoto:photo withFormat:format]];
}

+ (NSDictionary*)sizesForPhoto:(FlickrPhotoData*)photo
{
	NSString* request
	  = [API_REST_QUERY stringByAppendingFormat:API_PHOTO_SIZES_FORMAT, [photo idFlickr]];
	return [FlickrRestAPI query:request];
}

+ (NSURL*)urlForThumbnailAttributionForPhoto:(FlickrPhotoData*)photo
{
	NSDictionary* sizes = [FlickrRestAPI sizesForPhoto:photo];
	NSString* fallback;
	BOOL smallFallBack = NO;
	for (NSDictionary* size in [sizes valueForKeyPath:@"sizes.size"])
	{
		NSString* label = [size valueForKey:@"label"];
		if ([@"Thumbnail" isEqualToString:label])
			return [NSURL URLWithString:[size valueForKey:@"url"]];
		if (!smallFallBack)
		{
			if ([@"Small" isEqualToString:label])
				smallFallBack = YES;
			if (!fallback || smallFallBack)
				fallback = [size valueForKey:@"url"];
		}
	}

	if (fallback)
		return [NSURL URLWithString:fallback];

	return nil;
}

@end
