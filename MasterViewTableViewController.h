//
//  MasterViewTableViewController.h
//  XolawareUI
//
//  Created by me on 2012.04.07.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollableImageDetailViewController;

@interface MasterViewTableViewController : UITableViewController
@property (strong, nonatomic) NSArray* objects;
@property (strong, atomic) UIPopoverController* mapPopover;
@end
