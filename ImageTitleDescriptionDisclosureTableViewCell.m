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
@synthesize itddOverlayView = _itddOverlayView;
@synthesize itddDateLabel = _itddDateLabel;
@synthesize imageId = _imageId;
@synthesize spinner = _spinner;

static CGFloat _storyboardFontSize;

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[ImageTitleDescriptionDisclosureTableViewCell class]]
		&& [[object imageId] isEqualToString:self.imageId];
}

- (void)normalizeFont:(UILabel*)label accessoryType:(UITableViewCellAccessoryType)reusedType
{
	CGFloat widthAdjustment = 0;;
	if (reusedType != self.accessoryType)
		switch (self.accessoryType)
		{
		  case UITableViewCellAccessoryDetailDisclosureButton:	widthAdjustment = 13; break;
		  case UITableViewCellAccessoryDisclosureIndicator:		widthAdjustment = -13; break;
		  default:;
		}

	if (!_storyboardFontSize)
		_storyboardFontSize = label.font.pointSize;	// set once and re-use

	CGFloat actualFontSize, minFontSize;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
	minFontSize = self.itddTitle.minimumScaleFactor * _storyboardFontSize;
#else
	minFontSize = self.itddTitle.minimumFontSize;
#endif
	[label.text sizeWithFont:[label.font fontWithSize:_storyboardFontSize]
				 minFontSize:minFontSize
			  actualFontSize:&actualFontSize
					forWidth:label.frame.size.width+widthAdjustment-2
			   lineBreakMode:NSLineBreakByWordWrapping];
	label.font = [label.font fontWithSize:(CGFloat)((int)actualFontSize)];
}

- (void)normalizeTitleSizeUsingCellAccessoryType:(UITableViewCellAccessoryType)reusedType
{
	[self normalizeFont:self.itddTitle accessoryType:reusedType];
}

- (void)normalizeDescriptionSizeUsingCellAccessoryType:(UITableViewCellAccessoryType)reusedType
{
	[self normalizeFont:self.itddTitle accessoryType:reusedType];
}

#pragma mark Spinner

- (void)startSpinner
{
    if (!self.spinner) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    _spinner.hidden = NO; 
    [_spinner startAnimating];
}

- (void)stopSpinner
{
    [_spinner stopAnimating];
    _spinner.hidden = YES;
}

@end
