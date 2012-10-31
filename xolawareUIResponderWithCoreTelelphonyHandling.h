//
//  UIResponderWithCoreTelelphonyHandling.h
//  voyeur
//
//  Created by me on 2012.06.27.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString* const xolawareCoreTelephonyCallDidChangeNotification;
UIKIT_EXTERN NSString* const xolawareCoreTelephonyCall;

@interface xolawareUIResponderWithCoreTelelphonyHandling : UIResponder

@property (readonly, nonatomic, getter = isInCall) BOOL inCall;

@end
