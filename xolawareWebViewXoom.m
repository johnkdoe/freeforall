//
//  xolawareWebViewXoom.m
//  xolawareUI
//
//  Created by kb on 2012.10.12.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "xolawareWebViewXoom.h"

#import "NSString+Utilities.h"

@interface xolawareWebViewXoom ()

@property (nonatomic)		float	xoomScale;

@property (weak, nonatomic) UIWebView* webView;
@property (weak, nonatomic)	UIView* browserView;

@property (strong, nonatomic)	NSURL*	currentURL;
@property (strong, nonatomic)	NSURL*	rotatingAnchor;

@property (nonatomic)		float	contentScale;
@property (nonatomic)		float	contentVerticalOffsetPct;
@property (nonatomic)		float	defaultXoomScale;
@property (nonatomic)		BOOL	fixingScalesPageToFit;
@property (nonatomic)		CGSize	scrollViewInitialContentSize;

@property (nonatomic, getter = isReloading)			BOOL	reloading;
@property (nonatomic, getter = isRemovingAnchor)	BOOL	removingAnchor;
@property (nonatomic, getter = isRotating)			BOOL	rotating;
@property (nonatomic, getter = isScrollingToTop)	BOOL	scrollingToTop;

@end

#define JS_GET_BODY_MAX_WIDTH			@"document.body.style.maxWidth"
#define JS_SET_BODY_MAX_WIDTH_FORMAT	@"document.body.style.maxWidth=\"%@\""

#define XOLAWARE_DEBUG_WEBVIEW			0

#if XOLAWARE_DEBUG_WEBVIEW
	#define XOLAWARE_DEBUG_WEBVIEW_DATA(mf) \
		NSLog(@"%s\t- anchor=%s rotating=%s, rotatingAnchor=%s xs=%g, zs=%g, dfs=%g, minz=%g, maxz=%g",\
			  mf, self.hasAnchor ? "Y" : "N", self.isRotating ? "Y" : "N", self.isRotatingAnchor ? "Y" : "N",\
			  self.xoomScale, self.webView.scrollView.zoomScale, self.defaultXoomScale,\
			  self.webView.scrollView.minimumZoomScale, self.webView.scrollView.maximumZoomScale);\
		NSLog(@"%s\t- sv.cs={%g,%g} sv.co.y=%g cVOP=%g", mf, self.webView.scrollView.contentSize.width,\
			  self.webView.scrollView.contentSize.height, self.webView.scrollView.contentOffset.y,\
			  self.contentVerticalOffsetPct);
#else
#define XOLAWARE_DEBUG_WEBVIEW_DATA(mf)
#endif

@implementation xolawareWebViewXoom

#pragma mark - @property overrides

- (float)defaultXoomScale {
	if (0 == _defaultXoomScale)
	{
		__weak UIDevice* device = UIDevice.currentDevice;
		if (device.systemVersion.floatValue < 6.0
			&& (device.userInterfaceIdiom == UIUserInterfaceIdiomPad
				|| UIInterfaceOrientationIsPortrait(device.orientation)))
		{
#if XOLAWARE_DEBUG_WEBVIEW
			NSLog(@"dXS\t- resetting defaultXoomScale=%g", _defaultXoomScale);
#endif
			_defaultXoomScale = 1.5;
		}
		else
			_defaultXoomScale = 1.0;
	}
#if XOLAWARE_DEBUG_WEBVIEW

	if (UIDevice.currentDevice.systemVersion.floatValue < 6.0
		&& (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
			|| UIInterfaceOrientationIsPortrait(UIDevice.currentDevice.orientation)))
		NSLog(@"dXS\t- retrieving defaultXoomScale=%g", _defaultXoomScale);
#endif
	return _defaultXoomScale;
}

- (BOOL)isRotatingAnchor {
	return nil != _rotatingAnchor;
}

#pragma mark - default initializer

- (id)initWithWebView:(UIWebView*)webView {
	self = [super init];
	if (self) {
		self.webView = webView;
		self.webView.scrollView.contentOffset = CGPointZero;
		self.webView.scrollView.showsHorizontalScrollIndicator = NO;
		self.xoomScale = 1.0;
	}
	return self;
}

#pragma mark - private method implemetnations

- (float)browserVerticalOffsetMax {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"bVOM\t- wv.sv.cs={%g,%g} sv.f.s={%g,%g} offsetMax=%g",
		  self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height,
		  self.webView.scrollView.frame.size.width, self.webView.scrollView.frame.size.height,
		  self.webView.scrollView.contentSize.height-self.webView.scrollView.frame.size.height);
#endif
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
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"cCVOP\t- self.cVOP=%g", self.contentVerticalOffsetPct);
#endif
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
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:OFF transaction pre-start ====");
#endif
	self.fixingScalesPageToFit = YES;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:OFF transaction starting: scalesPageToFit = %s ====",
		  self.webView.scalesPageToFit ? "YES" : "NO ");
#endif
	self.webView.scalesPageToFit = NO;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:OFF transaction ending  : scalesPageToFit = NO  ====");
#endif
	XOLAWARE_DEBUG_WEBVIEW_DATA("==== autoScale:OFF");
	self.webView.scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
	self.webView.scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;
	XOLAWARE_DEBUG_WEBVIEW_DATA("==== autoScale:OFF");
	self.fixingScalesPageToFit = NO;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:OFF transaction completed ====");
#endif
}

- (void)turnOnAutoScale {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:ON  transaction pre-start ====");
#endif
	self.fixingScalesPageToFit = YES;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:ON  transaction starting: scalesPageToFit = %s ====",
		  self.webView.scalesPageToFit ? "YES" : "NO ");
#endif
	XOLAWARE_DEBUG_WEBVIEW_DATA("==== autoScale:ON");
	self.webView.scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
	self.webView.scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;
	XOLAWARE_DEBUG_WEBVIEW_DATA("==== autoScale:ON");
	self.webView.scalesPageToFit = YES;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:ON  transaction ending  : scalesPageToFit = YES ====");
#endif
	self.fixingScalesPageToFit = NO;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"==== autoScale:ON  transaction completed ====");
#endif
}

- (void)resetStandardXoomOffsetInScrollView:(UIScrollView*)scrollView {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"rSXOISV:\t- sv.cs={%g,%g} sv.co.y=%g cVOP=%g", scrollView.contentSize.width,
		  scrollView.contentSize.height, scrollView.contentOffset.y, self.contentVerticalOffsetPct);
#endif
	scrollView.contentOffset
	  = CGPointMake(0, self.contentVerticalOffsetPct*self.browserVerticalOffsetMax);
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"rSXOISV:\t- sv.co.y=%g", scrollView.contentOffset.y);
#endif
}

- (void)scrollView:(UIScrollView*)scrollView bodyContentMaxWidth:(int)cssMaxWidth
{
	NSString* javaScript;
	NSString* maxWidth;

	maxWidth = cssMaxWidth > 100 ? @"none" : [NSString stringWithFormat:@"%d%%", cssMaxWidth];
	javaScript = [NSString stringWithFormat:JS_SET_BODY_MAX_WIDTH_FORMAT, maxWidth];
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"sV:bCMW:\t- cssMax=%d, maxW=%@, js=%@", cssMaxWidth, maxWidth, javaScript);
#endif
	[self.webView stringByEvaluatingJavaScriptFromString:javaScript];
	CGFloat yOffset = self.browserVerticalOffsetMax * self.contentVerticalOffsetPct;
	scrollView.contentOffset = CGPointMake(0, yOffset);
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"sV:bCMW:\t- sv.cs={%g,%g} sv.co.y=%g cVOP=%g", scrollView.contentSize.width,
		  scrollView.contentSize.height, scrollView.contentOffset.y, self.contentVerticalOffsetPct);
#endif
}

- (void)xoomAfterReload:(NSNumber*)preReloadZoom {
	[self turnOffAutoScale];
	[self.webView.scrollView setZoomScale:preReloadZoom.floatValue/self.xoomScale animated:YES];
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n");
	NSLog(@"xAR\t- xs=%g, pRZ=%@\n\n", self.xoomScale, preReloadZoom);
#endif
	NSTimeInterval postXoomDelay
	  = self.isReloading | self.isRotatingAnchor ? 0.333*self.xoomScale : 0.02;
	[self performSelector:@selector(xoomFinal) withObject:nil afterDelay:postXoomDelay];
}

- (void)xoomFinal {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n");
	XOLAWARE_DEBUG_WEBVIEW_DATA("xF<");
#endif
	__weak UIScrollView* scrollView = self.webView.scrollView;
	if (self.isRotatingAnchor)
	{
		[self setAnchor:YES];
		[self.webView loadRequest:[NSURLRequest requestWithURL:_rotatingAnchor]];
		[self setRotatingAnchor:nil];
	}
	else
	{
		self.removingAnchor = NO;
		if (self.isReloading)
		{
			self.reloading = NO;
			if (UIDevice.currentDevice.systemVersion.floatValue < 6.0)
			{
				float currentXoom = self.xoomScale * scrollView.zoomScale;
				// last bit is a fudge factor because some text @ lower %ages was going off right
				float cssMaxWidth = self.contentScale / currentXoom - currentXoom/2;
				XOLAWARE_DEBUG_WEBVIEW_DATA("xF{p}>");
#if XOLAWARE_DEBUG_WEBVIEW
				NSLog(@"xF{p}\t- cx=%g, cs=%g", currentXoom, self.contentScale);
#endif
				[self scrollView:scrollView bodyContentMaxWidth:cssMaxWidth];
				XOLAWARE_DEBUG_WEBVIEW_DATA("xF{p}>");
			}
		}
		[self resetStandardXoomOffsetInScrollView:scrollView];
#if XOLAWARE_DEBUG_WEBVIEW
		NSLog(@"xF\t- re-animating alpha to 1, then turnOnAutoScale");
#endif

		[UIView animateWithDuration:0.22 animations:^{ self.webView.alpha = 1; }];
	}

	XOLAWARE_DEBUG_WEBVIEW_DATA("xF[1]");

	[self turnOnAutoScale];
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n");
#endif
}


#pragma mark - public method implementations

- (void)willRotate {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n____________ willRotate < ____________");
#endif
	if ([self isBlankOrEmptyURL:self.currentURL])
		return;

	XOLAWARE_DEBUG_WEBVIEW_DATA("wr<>");

	self.rotating = YES;
	self.webView.alpha = 0.4 / self.xoomScale;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"____ willRotate > ____\n\n");
#endif
}

- (void)didRotate {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n___________ didRotate < ____________");
#endif
	XOLAWARE_DEBUG_WEBVIEW_DATA("dR<");
	if ([self isBlankOrEmptyURL:self.currentURL] || self.isRotatingAnchor)
		return;

	NSTimeInterval rotateWait;
	CGFloat newXoomScale = self.xoomScale;
	__weak UIScrollView* scrollView = self.webView.scrollView;
	__weak UIDevice* device = UIDevice.currentDevice;
	if (device.systemVersion.floatValue < 6.0)
	{
		if (device.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		{
			if (UIInterfaceOrientationIsPortrait(device.orientation))
				newXoomScale *= self.defaultXoomScale;
			else
				newXoomScale /= self.defaultXoomScale;
			XOLAWARE_DEBUG_WEBVIEW_DATA("dR{p}[1]");
			self.defaultXoomScale = 0;	// forces next call to lazy-init/reset default
			XOLAWARE_DEBUG_WEBVIEW_DATA("dR{p}[2]");
		}
		rotateWait = 0.333;
		XOLAWARE_DEBUG_WEBVIEW_DATA("dR{p}[3]");
		self.reloading = YES;
		[self.webView reload];
		XOLAWARE_DEBUG_WEBVIEW_DATA("dR{p}[4]");
		self.xoomScale = self.scrollViewInitialContentSize.width / scrollView.frame.size.width;
	}
	else
	{
		rotateWait = 0.01;
		XOLAWARE_DEBUG_WEBVIEW_DATA("dR{6}[1]");
		scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
		scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;
	}

	// done as delayed perform because rotation is still part of caller animation
	NSNumber* newXoom = [NSNumber numberWithFloat:newXoomScale];
	XOLAWARE_DEBUG_WEBVIEW_DATA("dR[1]");
	[self performSelector:@selector(xoomAfterReload:) withObject:newXoom afterDelay:rotateWait];
	XOLAWARE_DEBUG_WEBVIEW_DATA("dR>");
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"____ didRotate > ____\n\n");
#endif
}

- (void)removeOrRotateAnchorBaseURL:(NSURL *)urlWithoutAnchor {
	XOLAWARE_DEBUG_WEBVIEW_DATA("rORABURL<");
	if (self.hasAnchor)
	{
		_anchor = NO;
		_removingAnchor = YES;
		if (self.isRotating)
			_rotatingAnchor = _currentURL;
		[self.webView loadRequest:[NSURLRequest requestWithURL:urlWithoutAnchor]];
	}
	XOLAWARE_DEBUG_WEBVIEW_DATA("rORABURL>");
}


#pragma mark - UIScrollViewDelegate implementation
#pragma mark @optional

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	assert(scrollView == self.webView.scrollView);
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:<");
	[self calculateContentVerticalOffsetPct];
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:>");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	assert(scrollView == self.webView.scrollView);
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:wD:<");
	if (!decelerate)
		[self calculateContentVerticalOffsetPct];
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:wD:>");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	assert(scrollView == self.webView.scrollView);
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:<");

	if (scrollView.isDecelerating || scrollView.isDragging || scrollView.isZooming)
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{ddz}<");
		scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);	// align on left
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{ddz}>");
	}
	else if (self.fixingScalesPageToFit)
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{fSPTF}<");
		[self resetStandardXoomOffsetInScrollView:scrollView];
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{fSPTF}>");
	}
	else if (self.hasAnchor && !self.isRotating && !self.isReloading)
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{hA}<");
		[self calculateContentVerticalOffsetPct];
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{hA}[1]");
		if (scrollView.contentOffset.y > self.browserVerticalOffsetMax)
			scrollView.contentOffset = CGPointMake(0, self.browserVerticalOffsetMax);
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{hA}>");
		if (self.webView.alpha != 1)
			[UIView animateWithDuration:0.1 animations:^{ self.webView.alpha = 1; }];
	}
	else if (!scrollView.isZoomBouncing && !self.isScrollingToTop)
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{else}<");
		[self resetStandardXoomOffsetInScrollView:scrollView];
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{else}>");
	}
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:>");
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	self.scrollingToTop = NO;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	return self.scrollingToTop = YES;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	assert(scrollView == self.webView.scrollView);

	// save for later use
	self.browserView = view;

	XOLAWARE_DEBUG_WEBVIEW_DATA("sVWBZ:wV:<");
	scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
	scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVWBZ:wV:[1]");
	[self turnOffAutoScale];	// this cause auto-scale to turn off while zooming
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVWBZ:wV:>");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
					   withView:(UIView *)view
						atScale:(float)scale
{
	assert(scrollView == self.webView.scrollView && view == self.browserView);

	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDEZ:wV:<");
	self.xoomScale *= scale;
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDEZ:wV:[1]");
	if (!self.isReloading)
		[self resetStandardXoomOffsetInScrollView:scrollView];

	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDEZ:wV:[2]");
	[self turnOnAutoScale];	// now that done with zooming, turn auto-scale back on
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDEZ:wV:>");
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDZ:wV:<");
	if (!self.webView.scalesPageToFit)
	{
		if (scrollView.zoomScale > scrollView.maximumZoomScale * 1.1)		// allow 10% bounce
			scrollView.zoomScale = scrollView.maximumZoomScale * 1.1;

		else if (scrollView.zoomScale < scrollView.minimumZoomScale * 0.9)	// allow 10% bounce
			scrollView.zoomScale = scrollView.minimumZoomScale * 0.9;

		else	// 'zoomScale = ' cause recursive calls back into this function, so the scales
		{		// changed above will end up here in the recursive call

			float currentXoom = self.xoomScale * scrollView.zoomScale;
			
			// last bit is a fudge factor because some text @ lower %ages was going off right
			float cssMaxWidth = self.contentScale / currentXoom - currentXoom/2;
#if XOLAWARE_DEBUG_WEBVIEW
			NSLog(@"sVDZ:\t- xs=%g, zs=%g, cx=%g, cs=%g",
				  self.xoomScale, scrollView.zoomScale, currentXoom, self.contentScale);
#endif
			XOLAWARE_DEBUG_WEBVIEW_DATA("sVDZ:wV:[1]");
			[self scrollView:scrollView bodyContentMaxWidth:cssMaxWidth];
			XOLAWARE_DEBUG_WEBVIEW_DATA("sVDZ:wV:[2]");
		}
	}
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDZ:wV:>");
}

#pragma mark - UIWebViewDelegate implementation
#pragma mark @optional

- (BOOL)			   webView:(UIWebView *)webView
	shouldStartLoadWithRequest:(NSURLRequest *)request
				navigationType:(UIWebViewNavigationType)navigationType
{
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n___________ shouldStartLoading < ____________\nold={%@}\nreq={%@}",
		  self.currentURL, request.URL);
#endif
	XOLAWARE_DEBUG_WEBVIEW_DATA("wV:sSLWR:nT:<");
	if (self.isRotatingAnchor)
	{
		self.currentURL = request.URL;
		return YES;
	}

	if (!self.isReloading && self.hasAnchor && self.currentURL && request.URL)
	{
		NSString* currentURL = self.currentURL.absoluteString;
		NSString* requestURL = request.URL.absoluteString;
		if ([currentURL isEqualToString:requestURL])
		{
			XOLAWARE_DEBUG_WEBVIEW_DATA("wV:sSLWR:nT:{NO}<");
			if (self.isRotating)
				[self resetStandardXoomOffsetInScrollView:webView.scrollView];
			if (NSNotFound == [currentURL rangeOfString:@"#"].location)
				self.anchor = NO;
			self.rotating = NO;

			XOLAWARE_DEBUG_WEBVIEW_DATA("wV:sSLWR:nT:{NO}>");
			return NO;
		}
	}
	self.rotating = NO;
	self.currentURL = request.URL;

#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"___________ shouldStartLoading > ____________\n\n");
#endif
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	assert(webView == self.webView);
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n___________ webViewDidStartLoad < ____________");
#endif
	XOLAWARE_DEBUG_WEBVIEW_DATA("wVDSL:<");
	if (self.isRotatingAnchor)
	{
		self.webView.scrollView.contentSize = CGSizeZero;
//		if (UIDevice.currentDevice.systemVersion.floatValue < 6.0)
//			webView.scrollView.zoomScale = self.defaultXoomScale/self.xoomScale*0.9875;
//		else
//			webView.scrollView.zoomScale *= 0.975;
//		XOLAWARE_DEBUG_WEBVIEW_DATA("wVDSL:{iRA}");
	}
	if (!self.isRotating)
		[UIView animateWithDuration:0.05 animations:^{ webView.alpha = 0; }];
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"___________ webViewDidStartLoad > ____________\n\n");
#endif
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n___________ webViewDidFinishLoad < ____________");
#endif
	assert(webView == self.webView);
	XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:<");

	// the beginning of the bracket can't occur in webViewDidStartLoad: ,
	// because when the following line is placed there, scrolling fails completely!!!
	[self turnOffAutoScale];	// bracket: turns off auto-scaling while zooming
	
	NSString* jsResult
	  = [webView stringByEvaluatingJavaScriptFromString:JS_GET_BODY_MAX_WIDTH];
	if (![jsResult isNonEmpty])
		self.contentScale = 100;
	else
		self.contentScale = jsResult.floatValue;

	__weak UIScrollView* scrollView = webView.scrollView;
	self.scrollViewInitialContentSize = scrollView.contentSize;
	if (self.isRemovingAnchor || self.isRotatingAnchor || self.isRotating)
	{
//		if (UIDevice.currentDevice.systemVersion.floatValue < 6.0)
//		{
//			self.xoomScale = self.scrollViewInitialContentSize.width/scrollView.frame.size.width;
//			[scrollView setZoomScale:self.defaultXoomScale/self.xoomScale/0.9875 animated:YES];
//			[self performSelector:@selector(xoomFinal) withObject:nil afterDelay:0.1];
//		}
//		else
		{
			XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{iRA}[1]");
			float previousXoomScale = self.xoomScale;
			self.xoomScale = 1;
			XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{iRA}[2]");
			NSNumber* pXoom = [NSNumber numberWithFloat:previousXoomScale];
			[self performSelector:@selector(xoomAfterReload:) withObject:pXoom afterDelay:0.2];
			XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{iRA}[3]");
		}
	}
	else if (!self.isReloading)
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{iRe}[1]");
		self.xoomScale = self.scrollViewInitialContentSize.width / scrollView.frame.size.width;
		XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{iRe}[2]");
		[scrollView setZoomScale:self.defaultXoomScale/self.xoomScale animated:YES];
		scrollView.contentOffset = CGPointZero;
		self.contentVerticalOffsetPct = 0;
		XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{iRe}[3]");

		NSTimeInterval duration = self.isReloading ? 0.8 : 0.2;
		[UIView animateWithDuration:duration delay:0.1 options:UIViewAnimationOptionCurveEaseIn
						 animations:^{ webView.alpha = 1; }
						 completion:nil];
	}

	// needs to be turned back on, or scrolling will fail in the next load to this webView
	[self turnOnAutoScale];	// bracket: turn back on auto-scaling after zooming
	XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:>");
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"___________ webViewDidFinishLoad > ____________\n\n");
#endif
}

@end
