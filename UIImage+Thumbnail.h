//
//  UIImage+Thumbnail.h
//  xolawareUI
//
//  Created by kb on 2012.12.13.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>		// requires AVFoundation.framework in your project

@interface UIImage (Thumbnail)
+ (UIImage*)firstFrameThumbnailFromVideoAtURL:(NSURL*)assetURL size:(CGSize const)maxSize;
- (UIImage*)thumbnailImageOfSize:(CGSize)newSize;
@end
