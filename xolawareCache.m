//
//  xolawareCache.m
//  theGRID
//
//  Created by xolaware on 2012.08.02.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareCache.h"

@implementation xolawareCache

static NSURL* _htmlCacheDirURL;
+ (NSURL*)htmlCacheDirURL
{
	if (!_htmlCacheDirURL)
		_htmlCacheDirURL
		  = [[NSFileManager.defaultManager URLsForDirectory:NSCachesDirectory
												  inDomains:NSUserDomainMask] lastObject];
	return _htmlCacheDirURL;
}

- (id)initWithCacheDir:(NSString*)cacheDir {
	NSString* cacheDirPath
	  = [xolawareCache.htmlCacheDirURL.path stringByAppendingPathComponent:cacheDir];
	self = [super initFileURLWithPath:cacheDirPath isDirectory:YES];
	if (self)
	{
		NSFileManager* fileMgr = NSFileManager.defaultManager;
		NSError* error;
		[fileMgr createDirectoryAtURL:self withIntermediateDirectories:YES attributes:nil
								error:&error];
#if DEBUG
		if (error) NSLog(@"%@", error);
#endif
	}
	return self;
}

- (BOOL)createFile:(NSString*)file contents:(NSData*)contents {
	return [contents writeToURL:[self urlForCacheFile:file] atomically:YES];
}

- (BOOL)isFileInCache:(NSString*)file {
	NSFileManager* fileMgr = NSFileManager.defaultManager;
	NSString* filePath = [self.path stringByAppendingPathComponent:file];
	return [fileMgr fileExistsAtPath:filePath isDirectory:NO];
}

- (NSURL*)urlForCacheFile:(NSString*)file {
	return [NSURL URLWithString:file relativeToURL:self];
}

@end
