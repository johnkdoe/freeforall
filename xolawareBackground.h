//
//  xolawareBackground.h
//  xolawareUI
//
//  Created by me on 2012.06.28.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <Foundation/Foundation.h>

typedef id (^xolawareBackgroundTaskBlock)(void);

@interface xolawareBackground : NSObject

+ (xolawareBackground*)retriever:(xolawareBackgroundTaskBlock)backgroundTaskBlock;

- (xolawareBackground*)initWithTask:(xolawareBackgroundTaskBlock)backgroundTaskBlock;

- (id)getData;

@end
