//
//  xolawareWebViewXoom.m
//  xolawareUI
//
//  Created by kb on 2012.10.12.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareWebViewXoom.h"

#import "NSString+Utilities.h"

@interface xolawareWebViewXoom ()

@property (weak, nonatomic) UIWebView* webView;

@property (weak, nonatomic)	UIView* browserView;
@property (weak, nonatomic)	NSURL*	currentURL;
@property (nonatomic)		float	xoomScale;

@property (nonatomic)						float	contentScale;
@property (nonatomic)						float	contentVerticalOffsetPct;
@property (nonatomic, getter = isRotating)	BOOL	rotating;
@property (nonatomic)						CGSize	scrollViewInitialContentSize;

@end

#define JS_GET_BODY_MAX_WIDTH			@"document.body.style.maxWidth"
#define JS_SET_BODY_MAX_WIDTH_FORMAT	@"document.body.style.maxWidth=\"%@\""

@implementation xolawareWebViewXoom

- (id)initWithWebView:(UIWebView*)webView {
	self = [super init];
	if (self) {
		self.contentVerticalOffsetPct = 0;
		self.webView = webView;
		self.webView.scrollView.contentOffset = CGPointZero;
		self.webView.scrollView.showsHorizontalScrollIndicator = NO;
	}
	return self;
}

#pragma mark - private method implemetnations

- (float)browserVerticalOffsetMax {
	return self.webView.scrollView.contentSize.height-self.webView.scrollView.frame.size.height;
}

- (void)calculateContentVerticalOffsetPct {
	float offsetMax = self.browserVerticalOffsetMax;
	if (!offsetMax)
		self.contentVerticalOffsetPct = 0;
	else if (offsetMax < self.webView.scrollView.contentOffset.y)
		self.contentVerticalOffsetPct = 1;
	else
		self.contentVerticalOffsetPct = self.webView.scrollView.contentOffset.y / offsetMax;
}

- (float)defaultXoomScale {
	return (UIDevice.currentDevice.systemVersion.floatValue >= 6.0) ? 1.0 : 1.5;
}

- (BOOL)isBlankOrEmptyURL:(NSURL*)URL {
	return !URL || [URL.absoluteString isEqualToString:@"about:blank"];
}

- (float)maximumXoomScale {
	return self.defaultXoomScale * 2.4;
}

- (float)minimumXoomScale {
	return 1.0;
}

- (void)resetStandardXoomOffsetInScrollView:(UIScrollView*)scrollView {
	scrollView.contentOffset
	  = CGPointMake(0, self.contentVerticalOffsetPct*self.browserVerticalOffsetMax);
}

- (void)scrollView:(UIScrollView*)scrollView bodyContentMaxWidth:(int)cssMaxWidth
{
	NSString* maxWidth
	  = cssMaxWidth > 100 ? @"none" : [NSString stringWithFormat:@"%d%%", cssMaxWidth];
	NSString* javaScript = [NSString stringWithFormat:JS_SET_BODY_MAX_WIDTH_FORMAT, maxWidth];

	[self.webView stringByEvaluatingJavaScriptFromString:javaScript];
	CGFloat yOffset = self.browserVerticalOffsetMax * self.contentVerticalOffsetPct;
	scrollView.contentOffset = CGPointMake(0, yOffset);
}

- (void)setAlphaAfterZoom {
	[UIView animateWithDuration:0.2 animations:^{ self.webView.alpha = 1; }];
	self.webView.scalesPageToFit = YES;
}

- (void)xoomAfterRotate:(NSNumber*)preRotateZoom {
	[self.webView.scrollView setZoomScale:preRotateZoom.floatValue/self.xoomScale animated:YES];
	[self performSelector:@selector(setAlphaAfterZoom) withObject:nil afterDelay:0.25];
}

#pragma mark - public method implementations

- (void)willRotate {
	if ([self isBlankOrEmptyURL:self.currentURL])
		return;

	self.rotating = YES;
	self.webView.alpha = 0.1;
	self.webView.scalesPageToFit = NO;
}

- (void)didRotate {
	if ([self isBlankOrEmptyURL:self.currentURL])
		return;

	__weak UIScrollView* scrollView = self.webView.scrollView;
	[self.webView reload];
	self.scrollViewInitialContentSize = scrollView.contentSize;
	NSNumber* preRotateXoom = [NSNumber numberWithFloat:self.xoomScale];
	self.xoomScale = self.scrollViewInitialContentSize.width / scrollView.frame.size.width;

	[self performSelector:@selector(xoomAfterRotate:) withObject:preRotateXoom afterDelay:0.25];
}

#pragma mark - UIScrollViewDelegate implementation
#pragma mark @optional

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	assert(scrollView == self.webView.scrollView);
	if (!decelerate)
		[self calculateContentVerticalOffsetPct];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	assert(scrollView == self.webView.scrollView);

	if (scrollView.isDecelerating)
	{
		scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);	// align on left
		[self calculateContentVerticalOffsetPct];
	}
	else if (scrollView.isDragging || scrollView.isZooming)
	{
		scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);	// align on left
	}
	else if (self.hasAnchor)
	{
		[self calculateContentVerticalOffsetPct];
		if (scrollView.contentOffset.y > self.browserVerticalOffsetMax)
			scrollView.contentOffset = CGPointMake(0, self.browserVerticalOffsetMax);
	}
	else if (!scrollView.isZoomBouncing)
	{
		scrollView.contentOffset
		  = CGPointMake(0, self.contentVerticalOffsetPct * self.browserVerticalOffsetMax);
	}
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	assert(scrollView == self.webView.scrollView);

	// save for later use
	self.browserView = view;

	scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
	scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;

	self.webView.scalesPageToFit = NO;	// this cause auto-scale to turn off while zooming
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
					   withView:(UIView *)view
						atScale:(float)scale
{
	assert(scrollView == self.webView.scrollView && view == self.browserView);

	self.xoomScale *= scale;
	[self resetStandardXoomOffsetInScrollView:scrollView];
	self.webView.scalesPageToFit = YES;	// now that done with zooming, turn auto-scale back on
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	if (!self.webView.scalesPageToFit)
	{
		if (scrollView.zoomScale > scrollView.maximumZoomScale * 1.1)		// allow 10% bounce
			scrollView.zoomScale = scrollView.maximumZoomScale * 1.1;

		else if (scrollView.zoomScale < scrollView.minimumZoomScale * 0.9)	// allow 10% bounce
			scrollView.zoomScale = scrollView.minimumZoomScale * 0.9;

		else	// 'zoomScale = ' cause recursive calls back into this function, so the scales
		{		// changed above will end up here in the recursive call

			// last bit is a small fudge factor because some text @ lower %ages was going off right
			float currentXoom = self.xoomScale * scrollView.zoomScale;
			
			float cssMaxWidth = self.contentScale / currentXoom - currentXoom;
			[self scrollView:scrollView bodyContentMaxWidth:cssMaxWidth];

			scrollView.contentSize
			  = CGSizeMake(self.scrollViewInitialContentSize.width * currentXoom,
						   self.scrollViewInitialContentSize.height * currentXoom);
		}
	}
}

#pragma mark - UIWebViewDelegate implementation
#pragma mark @optional

- (BOOL)			   webView:(UIWebView *)webView
	shouldStartLoadWithRequest:(NSURLRequest *)request
				navigationType:(UIWebViewNavigationType)navigationType
{
	self.rotating = NO;
	if (self.hasAnchor && self.currentURL && request.URL)
	{
		NSString* currentURL = self.currentURL.relativeString;
		NSString* requestURL = request.URL.relativeString;
		if ([currentURL isEqualToString:requestURL])
			return NO;
	}
	self.currentURL = request.URL;

	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	assert(webView == self.webView);
	if (!self.isRotating)
		[UIView animateWithDuration:0.05 animations:^{ webView.alpha = 0; }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	assert(webView == self.webView);
	if (self.isRotating)
		self.rotating = NO;
	else
	{
		// the beginning of the bracket can't occur in webViewDidStartLoad: ,
		// because when the following line is placed there, scrolling fails completely!!!
		webView.scalesPageToFit	= NO;	// bracket: turns off auto-scaling while zooming

		NSString* jsResult = [webView stringByEvaluatingJavaScriptFromString:JS_GET_BODY_MAX_WIDTH];
		if (![jsResult isNonEmpty])
			self.contentScale = 100;
		else
			self.contentScale = jsResult.floatValue;

		__weak UIScrollView* scrollView = webView.scrollView;
		self.scrollViewInitialContentSize = scrollView.contentSize;
		self.xoomScale = self.scrollViewInitialContentSize.width / scrollView.frame.size.width;
		[scrollView setZoomScale:self.defaultXoomScale/self.xoomScale animated:YES];
		scrollView.contentOffset = CGPointZero;
		self.contentVerticalOffsetPct = 0;

		[UIView animateWithDuration:0.15 delay:0.1
							options:UIViewAnimationOptionOverrideInheritedDuration
						 animations:^{ webView.alpha = 1; }
						 completion:nil];

		// needs to be turned back on, or scrolling will fail in the next load to this webView
		webView.scalesPageToFit = YES;	// bracket: turn back on auto-scaling after zooming
	}
}

@end
