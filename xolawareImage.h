//
//  xolawareImage.h
//  xolawareUI
//
//  Created by kb on 2012.12.12.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>		// requires AVFoundation.framework in your project

@interface xolawareImage : UIImage

+ (UIImage*)firstFrameFromVideoAtURL:(NSURL*)assetURL size:(CGSize)maxSize;

@end
