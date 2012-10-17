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
@property (nonatomic)		float	xoomScale;

@property (nonatomic)						float	contentScale;
@property (nonatomic)						float	contentVerticalOffsetPct;
@property (strong, nonatomic)				NSURL*	currentURL;
@property (nonatomic)						BOOL	fixingScalesPageToFit;
@property (nonatomic, getter = isReloading)	BOOL	reloading;
@property (nonatomic, getter = isRotating)	BOOL	rotating;
@property (nonatomic)						CGSize	scrollViewInitialContentSize;

@end

#define JS_GET_BODY_MAX_WIDTH			@"document.body.style.maxWidth"
#define JS_SET_BODY_MAX_WIDTH_FORMAT	@"document.body.style.maxWidth=\"%@\""

@implementation xolawareWebViewXoom

- (id)initWithWebView:(UIWebView*)webView {
	self = [super init];
	if (self) {
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

- (void)turnOffAutoScale {
	self.fixingScalesPageToFit = YES;
	self.webView.scalesPageToFit = NO;
	self.fixingScalesPageToFit = NO;
}

- (void)turnOnAutoScale {
	self.fixingScalesPageToFit = YES;
	self.webView.scalesPageToFit = YES;
	self.fixingScalesPageToFit = NO;
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

- (void)xoomAfterRotate:(NSNumber*)preRotateZoom {
	[self turnOffAutoScale];
	[self.webView.scrollView setZoomScale:preRotateZoom.floatValue/self.xoomScale animated:YES];
	NSTimeInterval postXoomDelay = self.isReloading ? 0.15*self.xoomScale : 0.03;
	[self performSelector:@selector(xoomFinal) withObject:nil afterDelay:postXoomDelay];
}

- (void)xoomFinal {
	[self resetStandardXoomOffsetInScrollView:self.webView.scrollView];
	self.reloading = NO;
	[UIView animateWithDuration:0.2 animations:^{ self.webView.alpha = 1; }];
	[self turnOnAutoScale];
}

#pragma mark - public method implementations

- (void)willRotate {
	if ([self isBlankOrEmptyURL:self.currentURL])
		return;

	self.rotating = YES;
	self.webView.alpha = 0.4 / self.xoomScale;
}

- (void)didRotate:(UIInterfaceOrientation)fromOrientation {
	if ([self isBlankOrEmptyURL:self.currentURL])
		return;

	NSTimeInterval rotateWait;
	CGFloat newXoomScale = self.xoomScale;
	__weak UIScrollView* scrollView = self.webView.scrollView;
	if (UIDevice.currentDevice.systemVersion.floatValue < 6.0)
	{
		if (UIInterfaceOrientationIsPortrait(fromOrientation))
			newXoomScale /= self.defaultXoomScale;
		else
			newXoomScale *= self.defaultXoomScale;
		rotateWait = 0.22;
		self.reloading = YES;
		[self.webView reload];
		self.xoomScale = self.scrollViewInitialContentSize.width / scrollView.frame.size.width;
	}
	else
	{
		rotateWait = 0.03;
		scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
		scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;
	}

	// done as delayed perform because rotation is still part of caller animation
	NSNumber* newXoom = [NSNumber numberWithFloat:newXoomScale];
	[self performSelector:@selector(xoomAfterRotate:) withObject:newXoom afterDelay:rotateWait];
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
	else if (self.fixingScalesPageToFit)
	{
		[self resetStandardXoomOffsetInScrollView:scrollView];
	}
	else if (self.hasAnchor && !self.isRotating && !self.isReloading)
	{
		[self calculateContentVerticalOffsetPct];
		if (scrollView.contentOffset.y > self.browserVerticalOffsetMax)
			scrollView.contentOffset = CGPointMake(0, self.browserVerticalOffsetMax);
	}
	else if (!scrollView.isZoomBouncing)
	{
		[self resetStandardXoomOffsetInScrollView:scrollView];
	}
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	assert(scrollView == self.webView.scrollView);

	// save for later use
	self.browserView = view;

	scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
	scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;

	[self turnOffAutoScale];	// this cause auto-scale to turn off while zooming
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
					   withView:(UIView *)view
						atScale:(float)scale
{
	assert(scrollView == self.webView.scrollView && view == self.browserView);

	self.xoomScale *= scale;
	if (!self.isReloading)
		[self resetStandardXoomOffsetInScrollView:scrollView];

	[self turnOnAutoScale];	// now that done with zooming, turn auto-scale back on
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
	if (!self.isReloading && self.hasAnchor && self.currentURL && request.URL)
	{
		NSString* currentURL = self.currentURL.relativeString;
		NSString* requestURL = request.URL.relativeString;
		if ([currentURL isEqualToString:requestURL])
		{
			if (self.isRotating)
				[self resetStandardXoomOffsetInScrollView:webView.scrollView];
			self.rotating = NO;
			return NO;
		}
	}
	self.rotating = NO;
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
	// the beginning of the bracket can't occur in webViewDidStartLoad: ,
	// because when the following line is placed there, scrolling fails completely!!!
	[self turnOffAutoScale];	// bracket: turns off auto-scaling while zooming

	NSString* jsResult = [webView stringByEvaluatingJavaScriptFromString:JS_GET_BODY_MAX_WIDTH];
	if (![jsResult isNonEmpty])
		self.contentScale = 100;
	else
		self.contentScale = jsResult.floatValue;

	__weak UIScrollView* scrollView = webView.scrollView;
	self.scrollViewInitialContentSize = scrollView.contentSize;
	self.xoomScale = self.scrollViewInitialContentSize.width / scrollView.frame.size.width;
	[scrollView setZoomScale:self.defaultXoomScale/self.xoomScale animated:YES];

	NSTimeInterval duration = self.isReloading ? 1 : .2;
	if (!self.isReloading)
	{
		scrollView.contentOffset = CGPointZero;
		self.contentVerticalOffsetPct = 0;
	}

	[UIView animateWithDuration:duration delay:0.1 options:UIViewAnimationOptionCurveEaseIn
					 animations:^{ webView.alpha = 1; }
					 completion:nil];

	// needs to be turned back on, or scrolling will fail in the next load to this webView
	[self turnOnAutoScale];	// bracket: turn back on auto-scaling after zooming
}

@end
