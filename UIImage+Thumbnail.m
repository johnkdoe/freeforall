//
//  UIImage+Thumbnail.m
//  xolawareUI
//
//  Created by kb on 2012.12.13.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)

+ (UIImage*)firstFrameThumbnailFromVideoAtURL:(NSURL*)assetURL size:(CGSize const)maxSize
{
	AVURLAsset* asset = [AVURLAsset assetWithURL:assetURL];
	AVAssetImageGenerator* gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
	gen.appliesPreferredTrackTransform = YES;
	gen.maximumSize = maxSize;
	CMTime time = CMTimeMakeWithSeconds(0.0, 600);
	NSError* error;
	CMTime actualTime;
	CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
	UIImage* uiimage = [UIImage imageWithCGImage:image];
	CGImageRelease(image);
	return uiimage;
}

- (UIImage*)thumbnailImageOfSize:(CGSize)newSize {
	UIGraphicsBeginImageContext(newSize);
	[self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
}

@end
