//
//  EmptyClass.h
//  voyeur
//
//  Created by me on 2012.06.28.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^xolawareBackgroundTaskBlock)(void);

@interface xolawareNetworkRetrieval : NSObject

- (xolawareNetworkRetrieval*)initWithTask:(xolawareBackgroundTaskBlock)backgroundTaskBlock;

- (void)execute;

@end
