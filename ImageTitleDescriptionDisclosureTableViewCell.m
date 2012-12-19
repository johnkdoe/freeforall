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

@synthesize imageId = _imageId;

static CGFloat _storyboardFontSize;

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[ImageTitleDescriptionDisclosureTableViewCell class]]
		&& [[object imageId] isEqualToString:self.imageId];
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

	CGFloat actualFontSize, minFontSize;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
	minFontSize = self.itddTitle.minimumScaleFactor * _storyboardFontSize;
#else
	minFontSize = self.itddTitle.minimumFontSize;
#endif
	[self.itddTitle.text sizeWithFont:[titleFont fontWithSize:_storyboardFontSize]
						  minFontSize:minFontSize
					   actualFontSize:&actualFontSize
							 forWidth:self.itddTitle.frame.size.width+widthAdjustment-2
						lineBreakMode:NSLineBreakByWordWrapping];
	self.itddTitle.font = [titleFont fontWithSize:(CGFloat)((int)actualFontSize)];
}

@end
