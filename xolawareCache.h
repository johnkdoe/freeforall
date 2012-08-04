//
//  xolawareCache.h
//  theGRID
//
//  Created by xolaware on 2012.08.02.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <Foundation/Foundation.h>

@interface xolawareCache : NSURL

- (id)initWithCacheDir:(NSString*)cacheDir;

- (BOOL)createFile:(NSString*)file contents:(NSData*)contents;
- (BOOL)isFileInCache:(NSString*)file;
- (NSURL*)urlForCacheFile:(NSString*)file;

@end
