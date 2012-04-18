//
//  ImageTitleDescriptionDisclosureTableViewCell.h
//  XolawareUI
//
//  Created by me on 2012.04.08.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

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
