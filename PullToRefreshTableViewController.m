//
//  PullToRefreshTableViewController.m
//  xolawareUI
//
//  Derived from source originally created by Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "xolawareOpenSourceCopyright.h"

#import <QuartzCore/QuartzCore.h>
#import "PullToRefreshTableViewController.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@interface PullToRefreshTableViewController () <UIScrollViewDelegate>
{
	BOOL isDragging;
    BOOL isLoading;
}
@end

@implementation PullToRefreshTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[self setupStrings];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil) {
		[self setupStrings];
	}
	return self;
}

- (NSString*)arrowImageName {
	if ([_pullToRefreshDataSource respondsToSelector:@selector(pullToRefreshArrowImageName)])
		return _pullToRefreshDataSource.pullToRefreshArrowImageName;
	else
		return @"arrow.png";
}

- (CGFloat)refreshHeaderHeight {
	if ([_pullToRefreshDataSource respondsToSelector:@selector(pullToRefreshHeaderHeight)])
		return _pullToRefreshDataSource.pullToRefreshHeaderHeight;
	else
		return REFRESH_HEADER_HEIGHT;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self addPullToRefreshHeader];
}

- (void)setupStrings{
	_textPull = NSLocalizedString(@"Pull down to refresh...", nil);
	_textRelease = NSLocalizedString(@"Release to refresh...", nil);
	_textLoading = NSLocalizedString(@"Loading...", nil);
}

- (void)addPullToRefreshHeader {
	CGFloat refreshHeaderHeight = self.refreshHeaderHeight;
	CGRect headerFrame = CGRectMake(0, 0 - refreshHeaderHeight,
									self.tableView.frame.size.width, refreshHeaderHeight);
	_refreshHeaderView = [[UIView alloc] initWithFrame:headerFrame];
	_refreshHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_refreshHeaderView.backgroundColor = [UIColor clearColor];

	CGRect labelFrame = CGRectMake(4, 0, headerFrame.size.width-4, refreshHeaderHeight);
	_refreshLabel = [[UILabel alloc] initWithFrame:labelFrame];
	_refreshLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_refreshLabel.backgroundColor = [UIColor clearColor];
	_refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
	_refreshLabel.textAlignment = UITextAlignmentCenter;

	NSString* arrowImageName = self.arrowImageName;
	_refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:arrowImageName]];
	CGFloat imageViewW = MIN(27, _refreshArrow.image.size.width);
	CGFloat imageViewH = MIN(refreshHeaderHeight - 4, _refreshArrow.image.size.height);
	_refreshArrow.contentMode = UIViewContentModeScaleAspectFill;
	_refreshArrow.frame = CGRectMake(4, (floorf(imageViewH) / 2), imageViewW, imageViewH);

	_refreshSpinner = [[UIActivityIndicatorView alloc]
					   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_refreshSpinner.frame = CGRectMake(8, floorf((refreshHeaderHeight - 24) / 2), 24, 24);
	_refreshSpinner.hidesWhenStopped = YES;

	[_refreshHeaderView addSubview:_refreshLabel];
	[_refreshHeaderView addSubview:_refreshArrow];
	[_refreshHeaderView addSubview:_refreshSpinner];
	[self.tableView addSubview:_refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (isLoading) return;
	isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (isLoading)
	{
		// Update the content inset, good for section headers
		if (scrollView.contentOffset.y > 0)
			_tableView.contentInset = UIEdgeInsetsZero;
		else if (scrollView.contentOffset.y >= -self.refreshHeaderHeight)
			_tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
	}
	else if (isDragging && scrollView.contentOffset.y < 0)
	{
		// Update the arrow direction and label
		[UIView animateWithDuration:0.25 animations:^{
			if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
				// User is scrolling above the header
				_refreshLabel.text = self.textRelease;
				[_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
			}
			else
			{
				// User is scrolling somewhere within the header
				_refreshLabel.text = self.textPull;
				[_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
			}
		}];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (isLoading) return;
	isDragging = NO;
	if (scrollView.contentOffset.y <= -self.refreshHeaderHeight)
	{
		// Released above the header
		[self startLoading];
	}
}

- (void)startLoading {
	isLoading = YES;

	// Show the header
	[UIView animateWithDuration:0.3 animations:^{
		_tableView.contentInset = UIEdgeInsetsMake(self.refreshHeaderHeight, 0, 0, 0);
		_refreshLabel.text = self.textLoading;
		_refreshArrow.hidden = YES;
		[_refreshSpinner startAnimating];
	}];

	// Refresh action!
	[_pullToRefreshDelegate refresh];
}

- (void)stopLoading {
	isLoading = NO;

	// Hide the header
	[UIView animateWithDuration:0.3
					 animations:^{
						self.tableView.contentInset = UIEdgeInsetsZero;
						 [_refreshArrow layer].transform
						   = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
					 }
					 completion:^(BOOL finished) {
						 [self performSelector:@selector(stopLoadingComplete)];
					 }];
}

- (void)stopLoadingComplete {
	// Reset the header
	_refreshLabel.text = self.textPull;
	_refreshArrow.hidden = NO;
	[_refreshSpinner stopAnimating];
}

@end
