//
//  UIImage+Orientation.m
//  athlete
//
//  Created by kb on 2013.01.02.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2013 xolaware.

#import "UIImage+Orientation.h"

@implementation UIImage (Orientation)

- (UIImage*)reorientedImage
{
//	int kMaxResolution = 320; // Or whatever

	CGImageRef imgRef = self.CGImage;

	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);

	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
//	if (width > kMaxResolution || height > kMaxResolution) {
//		CGFloat ratio = width/height;
//		if (ratio > 1) {
//			bounds.size.width = kMaxResolution;
//			bounds.size.height = bounds.size.width / ratio;
//		}
//		else {
//			bounds.size.height = kMaxResolution;
//			bounds.size.width = bounds.size.height * ratio;
//		}
//	}

	CGSize imageSize = CGSizeMake(width, height);
	CGFloat boundHeight;
	switch (self.imageOrientation)
	{
	  case UIImageOrientationUp: //EXIF = 1
		transform = CGAffineTransformIdentity;
		break;

	  case UIImageOrientationUpMirrored: //EXIF = 2
		transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		break;

	  case UIImageOrientationDown: //EXIF = 3
		transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
		transform = CGAffineTransformRotate(transform, M_PI);
		break;

	  case UIImageOrientationDownMirrored: //EXIF = 4
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
		transform = CGAffineTransformScale(transform, 1.0, -1.0);
		break;

	  case UIImageOrientationLeftMirrored: //EXIF = 5
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
		break;

	  case UIImageOrientationLeft: //EXIF = 6
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
		break;

	  case UIImageOrientationRightMirrored: //EXIF = 7
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeScale(-1.0, 1.0);
		transform = CGAffineTransformRotate(transform, M_PI_2);
		break;

	  case UIImageOrientationRight: //EXIF = 8
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
		transform = CGAffineTransformRotate(transform, M_PI_2);
		break;

	  default:
		[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

	}

	UIGraphicsBeginImageContext(bounds.size);

	CGContextRef context = UIGraphicsGetCurrentContext();

	if (self.imageOrientation == UIImageOrientationRight
		|| self.imageOrientation == UIImageOrientationLeft)
	{
		CGContextScaleCTM(context, -1, 1);
		CGContextTranslateCTM(context, -height, 0);
	}
	else
	{
		CGContextScaleCTM(context, 1, -1);
		CGContextTranslateCTM(context, 0, -height);
	}

	CGContextConcatCTM(context, transform);

	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return imageCopy;
}

@end
