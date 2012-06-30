//
//  FlickrPhotoData.m
//  voyeur
//
//  Created by me on 2012.06.28.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "FlickrPhotoData.h"

#import "FlickrRestAPI.h"
#import "Voyeur.h"
#import "VoyeurCache.h"
#import "VoyeurRecentlyViewed.h"

#import "ScrollableImageDetailViewController.h"

#import "NSString+Utilities.h"
#import "xolawareBackground.h"
#import "xolawareReachability.h"

#define FLIKR_PHOTO_TAGS    @"tags"

@interface FlickrPhotoData ()
@property (nonatomic, strong) NSDictionary* plainPhotoDataDictionary;
@end

@implementation FlickrPhotoData
@synthesize plainPhotoDataDictionary = _plainPhotoDataDictionary;
@synthesize imageRetrievalError = _imageRetrievalError;

- (id)initWithImageRetrievalError:(NSDictionary*)imageRetrievalError {
	self = [self init];
	if (self)
	{
		_imageRetrievalError = imageRetrievalError;
	}
	return self;
}

+ (FlickrPhotoData*)flickrPhotoDataWithDictionary:(NSDictionary*)plainPhotoDataDictionary
							  imageRetrievalError:(NSDictionary*)imageRetrievalError
{
	FlickrPhotoData* newFlickrPhotoData
	  = [[FlickrPhotoData alloc] initWithImageRetrievalError:imageRetrievalError];
	newFlickrPhotoData.plainPhotoDataDictionary = plainPhotoDataDictionary;
	return newFlickrPhotoData;	
}

+ (FlickrPhotoData*)flickrPhotoDataWithDictionary:(NSDictionary*)plainPhotoDataDictionary {
	return [FlickrPhotoData flickrPhotoDataWithDictionary:plainPhotoDataDictionary
									  imageRetrievalError:nil];
}

+ (FlickrPhotoData*)flickrPhotoDataWithObjects:(NSArray*)objects forKeys:(NSArray*)keys {
	NSDictionary* newDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	return [self flickrPhotoDataWithDictionary:newDictionary];
}

+ (NSArray*)flickrPhotoArray:(NSArray*)plainPhotoArray {
	NSMutableArray* wrapperArray = [NSMutableArray arrayWithCapacity:plainPhotoArray.count];
	for (NSDictionary* plainPhoto in plainPhotoArray)
	{
		NSDictionary* nestedPlainPhoto = [plainPhoto objectForKey:@"plainPhotoDataDictionary"];
		if (nestedPlainPhoto)
		{
			NSDictionary* imageRetrievalDict = [plainPhoto objectForKey:@"imageRetrievalError"];
			[wrapperArray addObject:[self flickrPhotoDataWithDictionary:nestedPlainPhoto
													imageRetrievalError:imageRetrievalDict]];
		}
		else
			[wrapperArray addObject:[self flickrPhotoDataWithDictionary:plainPhoto]];
	}
	return wrapperArray.copy;
}

+ (NSArray*)userDefaultsPhotoArray:(NSArray *)flickrPhotoArray {
	NSMutableArray* defaultsDicts = [NSMutableArray arrayWithCapacity:flickrPhotoArray.count];
	for (FlickrPhotoData* flickrPhoto in flickrPhotoArray)
	{
		NSDictionary* userDefaultsWritable
		  = [NSDictionary dictionaryWithObjectsAndKeys:flickrPhoto.plainPhotoDataDictionary,
																	@"plainPhotoDataDictionary",
													   flickrPhoto.imageRetrievalError, 
																	@"imageRetrievalError", 
													   nil];
		[defaultsDicts addObject:userDefaultsWritable];
	}
	return defaultsDicts.copy;
}

#pragma mark FlickrPhotoData public implementation

- (id)objectForKey:(id)key {
	return [_plainPhotoDataDictionary objectForKey:key];
}

- (NSString*)idFlickr {
	return [_plainPhotoDataDictionary objectForKey:FLICKR_API_PHOTO_ID];
}

- (NSString*)title
{
	NSString* title = [_plainPhotoDataDictionary objectForKey:FLICKR_API_PHOTO_TITLE];
	NSString* descriptionContent
	  = [_plainPhotoDataDictionary valueForKeyPath:FLICKR_API_PHOTO_DESCRIPTION];
	
	// if photo has no title, use its description as title
	// if it has no description, use the cell default "…unknown title…" as title
	if (![title isNonEmpty])
		title = descriptionContent;
	if (![title isNonEmpty])
		title = NSLocalizedString(@"…unknown title…", nil);
	
	return title;
}

- (NSString*)descriptionContent
{
	NSString* title = [_plainPhotoDataDictionary objectForKey:FLICKR_API_PHOTO_TITLE];
	NSString* descriptionContent
	= [_plainPhotoDataDictionary valueForKeyPath:FLICKR_API_PHOTO_DESCRIPTION];
	
	// if photo has no title, use its description as title
	// if it has no description, use the cell default "…unknown title…" as title
	if (![title isNonEmpty])
	{
		title = descriptionContent;
		descriptionContent = @"";
	}
	if ([title isNonEmpty])
	{
		if (!descriptionContent || [@"" isEqualToString:descriptionContent])
		{
			// going a bit further with the data we have
			// if no description (or used in title) then try the owner
			// if no owner, then try tags
			// if that fails, we'll leave the description blank
			NSString* owner = [_plainPhotoDataDictionary objectForKey:FLICKR_API_PHOTO_OWNER];
			if ([owner isNonEmpty])
				descriptionContent = [NSString stringWithFormat:@"owner = %@", owner];
			else {
				NSString* tags = [_plainPhotoDataDictionary objectForKey:FLIKR_PHOTO_TAGS];
				if ([tags isNonEmpty])
					descriptionContent = [NSString stringWithFormat:@"tags = {%@}", tags];
				else
					descriptionContent = @"";
			}
		}
	}
	else
		descriptionContent = NSLocalizedString(@"…unknown description…", nil);
	
	return descriptionContent;
}

- (NSString*)location
{
	NSString* latitude = [_plainPhotoDataDictionary objectForKey:FLICKR_API_LATITUDE];
	NSString* longitude = [_plainPhotoDataDictionary objectForKey:FLICKR_API_LONGITUDE];
	return [NSString stringWithFormat:@"%@,%@", latitude, longitude];
}

- (BOOL)hasLatitudeLongitude
{
	NSDecimalNumber* latitude = self.latitude;
	NSDecimalNumber* longitude = self.longitude;
	if (!(latitude && longitude))	// don't care if we have one but not both; bounce back NO
		return NO;
	
	// if one is non-zero even if the other is not, we'll believe prime-meridian or equator
	if (![latitude isEqualToNumber:[NSDecimalNumber zero]])
		return YES;
	if (![longitude isEqualToNumber:[NSDecimalNumber zero]])
		return YES;
	
	// not going to bother with photos that say they're geotagged t {0, 0}
	return NO;
}

- (NSDecimalNumber*)latitude {
	return [_plainPhotoDataDictionary objectForKey:FLICKR_API_LATITUDE];
}

- (NSDecimalNumber*)longitude {
	return [_plainPhotoDataDictionary objectForKey:FLICKR_API_LONGITUDE];
}

- (NSURL*)originatingURL {
	return [FlickrRestAPI urlForThumbnailAttributionForPhoto:self];
}

- (BOOL)hasImageRetrievalError {
	return nil != _imageRetrievalError;
}

- (UIImage*)retrieveNetworkImageWithFormat:(NSString*)format
{
	NSURL* photoURL = [FlickrRestAPI farmUrlForPhoto:self withFormat:format];

	xolawareBackgroundTaskBlock photoRetriever = ^id
	{
		NSError* error;
		NSData* data = [NSData dataWithContentsOfURL:photoURL options:0 error:&error];
		if (!error)
			_imageRetrievalError = nil;
		else
		{
#if DEBUG
			NSLog(@"image retrieval: %@", error);
#endif
			NSNumber* errorCode = [NSNumber numberWithInt:error.code];
			_imageRetrievalError
			= [NSDictionary dictionaryWithObjectsAndKeys:error.domain, @"domain",
			   errorCode, @"code",
			   error.userInfo, @"userInfo",
			   nil];
		}
		return data;
	};

	// xolawareBackground just means this task will continue running if the app goes background
	NSData* data = [xolawareBackground retriever:photoRetriever].getData;
	if (self.imageRetrievalError)
		return [UIImage imageNamed:@"AccessDeniedError"];

	return [UIImage imageWithData:data];
}

- (UIImage*)retrieveThumbnail
{
	UIImage* image = [[VoyeurCache thumbCache] imageForPhoto:self];
	if (!image)
	{
		if ([xolawareReachability connectedToNetwork])
		{
			image = [self retrieveNetworkImageWithFormat:@"Square"];
			if (image && !self.hasImageRetrievalError)
				[[VoyeurCache thumbCache] cacheImage:image forPhoto:self];
		}
	}
	return image;
}

- (void)displayImage:(UIImage*)image
		inController:(ScrollableImageDetailViewController*)imageDetailVC
{
	NSString* title = self.title;
	if (![title isNonEmpty])
		title = NSLocalizedString(@"…unknown title…", nil);
	imageDetailVC.imageTitle = title;
	imageDetailVC.originatingURL = self.originatingURL;
	
	imageDetailVC.image = image;
	[VoyeurRecentlyViewed setVisited:self];	
}

- (void)displayImageInController:(ScrollableImageDetailViewController*)imageDetailVC
{
	assert([imageDetailVC isKindOfClass:[ScrollableImageDetailViewController class]]);
	
	UIImage* image = [[VoyeurCache photoCache] imageForPhoto:self];
	if (image)
	{
		[self displayImage:image inController:imageDetailVC];
	}
	else if ([xolawareReachability connectedToNetwork])
	{
		dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_async(q, ^{
			UIImage* retrievedImage = [self retrieveNetworkImageWithFormat:@"Large"];
			if (retrievedImage)
			{
				if (!self.hasImageRetrievalError)
					[[VoyeurCache photoCache] cacheImage:retrievedImage forPhoto:self];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self displayImage:retrievedImage inController:imageDetailVC];
				});
			}
		});
	}
	
}

@end
