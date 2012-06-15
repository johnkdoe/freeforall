//
//  ScrollableImageAndMapMasterTableViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "FlipsideViewController.h"

@class MapViewController;

@interface ScrollableImageAndMapMasterTableViewController
	: UITableViewController <FlipsideViewControllerDelegate>
@property (strong, nonatomic) NSArray* objects;

- (void)annotateMap:(MapViewController*)mapVC forRowAtIndexPath:(NSIndexPath*)indexPath;

@end
