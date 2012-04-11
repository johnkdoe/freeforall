//
//  ImageTitleDescriptionDisclosureTableViewCell.m
//  XolawareUI
//
//  Created by me on 2012.04.08.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "ImageTitleDescriptionDisclosureTableViewCell.h"

@implementation ImageTitleDescriptionDisclosureTableViewCell

@synthesize innerView = _innerView;
@synthesize itddImageView = _itddImageView;
@synthesize itddTitle = _itddTitle;
@synthesize itddDescription = _itddDescription;

- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.itddImageView = [[self.innerView subviews] objectAtIndex:0];
		self.itddTitle = [[self.innerView subviews] objectAtIndex:1];
		self.itddDescription = [[self.innerView subviews] lastObject];
    }
    return self;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

@end
