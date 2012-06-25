//
//  SecondaryQueuePhotoReciever.h
//  voyeur
//
//  Created by me on 2012.06.24.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SecondaryQueuePhotoReceiver <NSObject>

- (void)showPhotos:(NSArray*)photos;

@end
