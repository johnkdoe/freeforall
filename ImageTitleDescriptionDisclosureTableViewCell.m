//
//  ImageTitleDescriptionDisclosureTableViewCell.m
//  xolawareUI
//
//  Created by me on 2012.04.08.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "ImageTitleDescriptionDisclosureTableViewCell.h"

@implementation ImageTitleDescriptionDisclosureTableViewCell

#pragma mark @synthesize
@synthesize itddImageView = _itddImageView;
@synthesize itddTitle = _itddTitle;
@synthesize itddDescription = _itddDescription;

@synthesize photoId = _photoId;

static CGFloat _storyboardFontSize;

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[ImageTitleDescriptionDisclosureTableViewCell class]]
		&& [[object photoId] isEqualToString:self.photoId];
		 
}

- (void)normalizeFontSizeUsingCellAccessoryType:(UITableViewCellAccessoryType)reusedType
{
	UIFont* titleFont = self.itddTitle.font;
	if (!_storyboardFontSize)
		_storyboardFontSize = titleFont.pointSize;	// set once and re-use

	CGFloat widthAdjustment = 0;;
	if (reusedType != self.accessoryType)
		switch (self.accessoryType)
		{
		  case UITableViewCellAccessoryDetailDisclosureButton:	widthAdjustment = 13; break;
		  case UITableViewCellAccessoryDisclosureIndicator:		widthAdjustment = -13; break;
		  default:;
		}

	CGFloat actualFontSize;
	[self.itddTitle.text sizeWithFont:[titleFont fontWithSize:_storyboardFontSize]
						  minFontSize:self.itddTitle.minimumFontSize
					   actualFontSize:&actualFontSize
							 forWidth:self.itddTitle.frame.size.width+widthAdjustment-2
						lineBreakMode:UILineBreakModeWordWrap];
	self.itddTitle.font = [titleFont fontWithSize:(CGFloat)((int)actualFontSize)];
}

@end
