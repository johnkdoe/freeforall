//
//  xolawareImage.m
//  xolawareUI
//
//  Created by kb on 2012.12.12.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareImage.h"

@implementation xolawareImage

+ (UIImage*)firstFrameFromVideoAtURL:(NSURL*)assetURL size:(CGSize)maxSize
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

@end
