//
//  ImageTitleDescriptionDisclosureTableViewCell.h
//  xolawareUI
//
//  Created by me on 2012.04.08.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface ImageTitleDescriptionDisclosureTableViewCell : UITableViewCell

// the following are subviews of the content view.
@property (weak, nonatomic) IBOutlet UIImageView* itddImageView;
@property (weak, nonatomic) IBOutlet UIImageView* itddOverlayView;
@property (weak, nonatomic) IBOutlet UILabel* itddTitle;
@property (weak, nonatomic) IBOutlet UILabel* itddDescription;
@property (weak, nonatomic) IBOutlet UILabel* itddDateLabel;

@property (strong, nonatomic) NSString* imageId;

- (BOOL)isEqual:(id)object;

- (void)normalizeTitleSizeUsingCellAccessoryType:(UITableViewCellAccessoryType)reusedType;
- (void)normalizeDescriptionSizeUsingCellAccessoryType:(UITableViewCellAccessoryType)reusedType;

@end
