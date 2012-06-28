//
//  SecondaryQueuePhotoReciever.h
//  voyeur
//
//  Created by me on 2012.06.24.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <Foundation/Foundation.h>

@protocol SecondaryQueuePhotoReceiver <NSObject>

- (void)showPhotos:(NSArray*)photos;

@end
