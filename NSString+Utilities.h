//
//  NSString+Utilities.h
//  xolaware utilities
//
//  Created by me on 2012.04.09.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <Foundation/Foundation.h>

#define synthesizeLazyLocalizedString(prop, val) \
@synthesize prop = _##prop; \
- (NSString*)prop { if (!_##prop) _##prop = NSLocalizedString(val, nil); return _##prop; }

@interface NSString (Utilities)
- (BOOL)isNonEmpty;

- (NSString*)stringByLocalizingThenAppending:(NSString*)stringToAppend;

- (NSURL*)urlForMainBundleResourceHTML;

- (BOOL)hasEmailTraits;
- (BOOL)hasNewline;
- (BOOL)hasWhitespace;
- (BOOL)hasWhitespaceOrNewline;

+ (NSString*)generateCompactGUID;

@end
