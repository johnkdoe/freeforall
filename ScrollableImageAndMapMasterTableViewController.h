//
//  ScrollableImageAndMapMasterTableViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@class MapViewController;

@interface ScrollableImageAndMapMasterTableViewController : UITableViewController
@property (strong, nonatomic) NSArray* objects;
@property (strong, atomic) UIPopoverController* mapPopover;

- (void)annotateMap:(MapViewController*)mapVC forRowAtIndexPath:(NSIndexPath*)indexPath;

@end
