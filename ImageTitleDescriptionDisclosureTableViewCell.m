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

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[ImageTitleDescriptionDisclosureTableViewCell class]]
		&& [[object photoId] isEqualToString:self.photoId];
		 
}

@end
