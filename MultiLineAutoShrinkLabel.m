//
//  MultiLineAutoShrinkLabel.m
//  xolawareUI.h
//
//  Created by xolaware on 2012.08.02.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "MultiLineAutoShrinkLabel.h"

@interface MultiLineAutoShrinkLabel ()
@property (readonly, nonatomic) UIFont* originalFont;
@end

@implementation MultiLineAutoShrinkLabel

@synthesize originalFont = _originalFont;

- (UIFont*)originalFont { return _originalFont ? _originalFont : (_originalFont = self.font); }

- (void)quoteAutoshrinkUnquote
{
	UIFont* font = self.originalFont;
	CGSize frameSize = self.frame.size;

	CGFloat testFontSize = _originalFont.pointSize;
	for (; testFontSize >= self.minimumFontSize; testFontSize -= 0.5)
	{
		CGSize constraintSize = CGSizeMake(frameSize.width, MAXFLOAT);
		CGSize testFrameSize = [self.text sizeWithFont:(font = [font fontWithSize:testFontSize])
									 constrainedToSize:constraintSize
										 lineBreakMode:self.lineBreakMode];
		// the ratio of testFontSize to original font-size sort of accounts for number of lines
		if (testFrameSize.height <= frameSize.height * (testFontSize/_originalFont.pointSize))
			break;
	}

	self.font = font;
	[self setNeedsLayout];
}

@end
