//
//  ImageTitleDescriptionDisclosureTableViewCell.h
//  xolawareUI
//
//  Created by me on 2012.04.08.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import <UIKit/UIKit.h>

@interface ImageTitleDescriptionDisclosureTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView* innerView;

// the following are subviews of the content view.
// haven't been able to figure out how to hook these up via interface builder
@property (weak, nonatomic) UIImageView* itddImageView;
@property (weak, nonatomic) UILabel* itddTitle;
@property (weak, nonatomic) UILabel* itddDescription;

@property (strong, nonatomic) NSString* photoId;

- (BOOL)isEqual:(id)object;

@end
