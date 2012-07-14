//
//  ScrollableImageAndMapMasterTableViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>
#import "FlipsideViewController.h"
#import "SecondaryQueuePhotoReceiver.h"

@class MapViewController;

@interface TableWithMapAccessoryViewController : UITableViewController
	<UIAlertViewDelegate, FlipsideViewControllerDelegate, SecondaryQueuePhotoReceiver>

@property (strong, nonatomic) NSArray* objects;
@property (strong, nonatomic) NSDate* retrievalDate;
@property (readonly, strong, nonatomic) NSDateFormatter* systemLocaleFormatter;
@property (nonatomic) BOOL scrollsToTop;

@property (strong, nonatomic) UIAlertView* alertView;

- (BOOL)annotateMap:(MapViewController*)mapVC forRowAtIndexPath:(NSIndexPath*)indexPath;

- (void)setDateBasedTitleForOrientation:(UIInterfaceOrientation)orientation;

// this is for when this class implementation is nested in a UITabBarController, etc
- (void)setNestedNavControllerHandlerInViewController:(UIViewController*)uiViewController;

@end
