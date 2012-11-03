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
@property (nonatomic)		BOOL	useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0;

@property (nonatomic, getter = isReloading)			BOOL	reloading;
@property (nonatomic, getter = isRemovingAnchor)	BOOL	removingAnchor;
@property (nonatomic, getter = isRotating)			BOOL	rotating;
@property (nonatomic, getter = isScrollingToTop)	BOOL	scrollingToTop;


@property (readonly)	float minimumXoomScale;
@property (readonly)	float maximumXoomScale;
@property (readonly)	UIInterfaceOrientation interfaceOrientation;
@property (readonly)	NSTimeInterval postXoomDelay;

@property (readonly, getter = isRuntimePre_6_0)		BOOL	runtimePre_6_0;

@end

#define JS_GET_BODY_MAX_WIDTH			@"document.body.style.maxWidth"
#define JS_SET_BODY_MAX_WIDTH_FORMAT	@"document.body.style.maxWidth=\"%@\""

#define XOLAWARE_PRE_IOS_6_0_DEFAULT_XOOM	1.8

#define XOLAWARE_DEBUG_WEBVIEW			0

#if XOLAWARE_DEBUG_WEBVIEW
	#define XOLAWARE_DEBUG_WEBVIEW_DATA(mf) \
		NSLog(@"%s\t- anchor=%s reload=%s remvAnchr=%s rotate=%s, rotateAnchr=%s dxs=%g\n........................................... %s\t- xs=%g zs=%g sv.cs={%g,%g} sv.co.y=%g cVOP=%g minz=%g maxz=%g",\
			  mf, self.hasAnchor ? "Y":"N", _reloading ? "Y":"N", _removingAnchor ? "Y":"N", \
			  _rotating ? "Y":"N", _rotatingAnchor ? "Y":"N", _defaultXoomScale, mf,\
			  _xoomScale, _webView.scrollView.zoomScale, _webView.scrollView.contentSize.width,\
			  _webView.scrollView.contentSize.height, _webView.scrollView.contentOffset.y,\
			  _contentVerticalOffsetPct,\
			  _webView.scrollView.minimumZoomScale, _webView.scrollView.maximumZoomScale);
#else
#define XOLAWARE_DEBUG_WEBVIEW_DATA(mf)
#endif

@implementation xolawareWebViewXoom

#pragma mark - @property overrides

- (float)defaultXoomScale {
	if (0 == _defaultXoomScale)			// account for startup condition
		[self resetDefaultXoomScale];
	return _defaultXoomScale;
}

- (BOOL)isRotatingAnchor {
	return nil != _rotatingAnchor;
}

- (BOOL)isRuntimePre_6_0 {
	return UIDevice.currentDevice.systemVersion.floatValue < 6.0;
}

#pragma mark - default initializer

- (id)initWithWebView:(UIWebView*)webView {
	self = [super init];
	if (self) {
		self.webView = webView;
		self.webView.scrollView.showsHorizontalScrollIndicator = NO;

		[self resetDefaultXoomScale];
		[self setXoomScale:1.0];
	}
	return self;
}

#pragma mark - private method implemetnations

- (void)bodyContentMaxWidthInScrollView:(UIScrollView*)scrollView
{
	float cssMaxWidth = [self cssMaxWidthForScrollView:scrollView];

	NSString* javaScript;
	NSString* maxWidth;

	maxWidth = cssMaxWidth > 100 ? @"none" : [NSString stringWithFormat:@"%g%%", cssMaxWidth];
	javaScript = [NSString stringWithFormat:JS_SET_BODY_MAX_WIDTH_FORMAT, maxWidth];
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"bCMWISV:\t- cssMax=%g, maxW=%@, js=%@", cssMaxWidth, maxWidth, javaScript);
#endif
	[self.webView stringByEvaluatingJavaScriptFromString:javaScript];
	CGFloat yOffset = self.browserVerticalOffsetMax * self.contentVerticalOffsetPct;
	scrollView.contentOffset = CGPointMake(0, yOffset);
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"bCMWISV:\t- sv.cs={%g,%g} sv.co.y=%g cVOP=%g",
		  scrollView.contentSize.width, scrollView.contentSize.height,
		  scrollView.contentOffset.y, self.contentVerticalOffsetPct);
#endif
}

/**
 *	returns a maximum offset in the content view by factoring in the
 *	size of the scroll view so the top corner is always treated as maximum
 */

- (float)browserVerticalOffsetMax {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"bVOM\t- wv.sv.cs={%g,%g} sv.f.s={%g,%g} offsetMax=%g",
		  self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height,
		  self.webView.scrollView.frame.size.width, self.webView.scrollView.frame.size.height,
		  self.webView.scrollView.contentSize.height-self.webView.scrollView.frame.size.height);
#endif
	return self.webView.scrollView.contentSize.height-self.webView.scrollView.frame.size.height;
}

/**
 *	establishes the percentage to be used when resetting the content offset after zoom,
 *	scroll, reload or rotation
 */

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

- (float)cssMaxWidthForScrollView:(UIScrollView*)scrollView {
	float currentXoom = self.xoomScale * scrollView.zoomScale;

	// this fudge factor partially accounts for the scroll bar, partly for text off the right.
	// pre iOS 6.0 is a pretty uniform problem at all zoom scales.
	// in iOS 6.0, the problem seems worse at smaller zoom scales

	float fudgeFactor;
	if (self.isRuntimePre_6_0)
		fudgeFactor = self.defaultXoomScale * (self.maximumXoomScale / currentXoom);
	else
		fudgeFactor = (currentXoom - 0.5) + 1 / currentXoom;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"cssMWFSV:\t- xs=%g, zs=%g, cx=%g, cs=%g",
		  self.xoomScale, scrollView.zoomScale, currentXoom, self.contentScale);
#endif
	return self.contentScale / currentXoom - fudgeFactor;
}

- (BOOL)isBlankOrEmptyURL:(NSURL*)URL {
	return !URL || [URL.absoluteString isEqualToString:@"about:blank"];
}

- (float)maximumXoomScale {
	return self.defaultXoomScale * 1.75;
}

- (float)minimumXoomScale {
	return self.defaultXoomScale;
}

- (UIInterfaceOrientation)interfaceOrientation {
	return UIApplication.sharedApplication.statusBarOrientation;
}

/**
 *	this function returns slightly different delays based upon internal
 *	properties established based on the length of execution time they take
 */

- (NSTimeInterval)postXoomDelay {
	return self.isRemovingAnchor ? 0.42 : self.isReloading ? 0.3 : 0.01;
}

/**
 *	establishes a scale allowing for readable fonts that are too small by
 *	default as established by the UIWebView autoScalesPageToFit property.
 *
 *	as of iOS 6.0, the default scale of 1.0 is pretty readable.
 */

- (void)resetDefaultXoomScale {
	BOOL useBiggerDefault
	  = self.isRuntimePre_6_0
		&& (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
			|| UIInterfaceOrientationIsPortrait(self.interfaceOrientation));
	_defaultXoomScale = useBiggerDefault ? XOLAWARE_PRE_IOS_6_0_DEFAULT_XOOM : 1.0;
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"dXS\t- resetting defaultXoomScale=%g", _defaultXoomScale);
#endif
}

/**
 *	part of the solution to correct a problem with content of a UIWebView
 *	getting cut off after rotation or reload running in a pre-iOS 6.0 runtime
 */

- (void)resetUseAutoScaleAfterXoom {
	if (self.isRuntimePre_6_0)	_useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0 = YES;
}

/**
 *	re-establishes a previously valid content-offset based on percentage.
 */

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

/**
 *	since the "readability" of fonts differs for font-sizes that pre-iOS 6.0
 *	determines are the same size for different orientations, xolawareWebViewXoom
 *	establishes a different defaultXoomScale.  when a rotation occurs, the
 *	default value will be returned differently … but the xoomScale itself must be
 *	adjusted, since a user may have zoomed, causing it to change.  this function
 *	keeps it in relation to the defaultXoomScale.
 */

- (void)rotateXoomScale {
	__weak UIDevice* currentDevice = UIDevice.currentDevice;
	if (self.isRuntimePre_6_0 && currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
			self.xoomScale *= XOLAWARE_PRE_IOS_6_0_DEFAULT_XOOM;
		else
			self.xoomScale /= XOLAWARE_PRE_IOS_6_0_DEFAULT_XOOM;
	}
}

/**
 *	the "transaction" bracket to turn off scalesPageToFit so that we can xoom the page
 */

- (void)turnOffAutoScale {
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
}

/**
 *	the "transaction" bracket to turn on scalesPageToFit so that we can xoom the page
 */

- (void)turnOnAutoScale {
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
}

/**
 *	common code that is called after a load, reload, or rotation.
 *	it is often invoked after a delay, allowing the load, reload or rotation to go through
 *	some view life cycle code that finalizes some values.
 */

- (void)xoomAfterReload:(NSNumber*)preReloadZoom {
	float thisZoom = preReloadZoom.floatValue/self.xoomScale;

	// testing this intractable problem resulted in noticing that a manual zoom would fix the
	// problem of text cut off on the first try after a reload or rotation; so this part of the
	// fix is the part that mimics that late manual zoom.  this first part zooms just a little
	// too big (and allows a zoom that's a little too big by slightly increasing the max scale),
	// and then relying on auto-scale to fix it after the second zoom to the actually desired
	// amount.  see where _useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0 is set to learn
	// the circumstances in which this must occur.
	if (_useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0)
	{
		BOOL isPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
		thisZoom *= isPad ? 1.01 : 1.025;
		self.webView.scrollView.maximumZoomScale = _defaultXoomScale * (isPad ? 2.424 : 2.46);
	}
	else
		[self turnOffAutoScale];

	[self.webView.scrollView setZoomScale:thisZoom animated:YES];
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n");
	NSLog(@"xAR\t- xs=%g, pRZ=%@\n\n", self.xoomScale, preReloadZoom);
#endif

	// the animated zoom on the previous line takes takes varying time, but always longer than 0
	[self performSelector:@selector(xoomFinal:) withObject:preReloadZoom
			   afterDelay:self.postXoomDelay];
}

/**
 *	for the normal case, there's minor cleanup:
 *	- when removing an anchor, make the transparency strong so the reset of the offset is dim
 *	- when rotating an anchor, set the anchor flag and start the anchor load
 *	- when reloading, re-establish the content offset at the desired location
 *
 *	for the workaround case involving the use of the runtime auto-scale,
 *	- turn the flag off as the exit condition for the recursive call herein later
 *
 *  when done and not reloading anything, animate the alpha back to 1
 */

- (void)xoomFinal:(NSNumber*)preReloadZoom {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n");
	XOLAWARE_DEBUG_WEBVIEW_DATA("xF<");
#endif
	if (self.isRemovingAnchor)
	{
		self.webView.alpha = 0.2;
		[self setRemovingAnchor:NO];
	}

	__weak UIScrollView* scrollView = self.webView.scrollView;
	if (self.isRotatingAnchor)
	{
		[self setAnchor:YES];
		[self.webView loadRequest:[NSURLRequest requestWithURL:_rotatingAnchor]];
		[self setRotatingAnchor:nil];
	}
	else
	{
		[self setReloading:NO];
		[self resetStandardXoomOffsetInScrollView:scrollView];
#if XOLAWARE_DEBUG_WEBVIEW
		NSLog(@"xF\t- re-animating alpha to 1, then turnOnAutoScale");
#endif
		if (!_useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0)
			[UIView animateWithDuration:0.05 animations:^{ self.webView.alpha = 1; }];
	}

	XOLAWARE_DEBUG_WEBVIEW_DATA("xF[1]");

	if (_useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0)
	{
		_useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0 = NO;
		[self performSelector:@selector(xoomAfterReload:) withObject:preReloadZoom
				   afterDelay:0.24];
	}
	else
		[self turnOnAutoScale];

	XOLAWARE_DEBUG_WEBVIEW_DATA("xF[3]");

#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n");
#endif
}

#pragma mark - public method implementations

/**
 *	preparation for rotation; in this case, it's just mostly visibly dimming the content,
 *	and setting a state-flag for other life-cycle calls into this code.
 */

- (void)willRotate {
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"\n\n____________ willRotate < ____________");
#endif
	if ([self isBlankOrEmptyURL:_currentURL])
		return;

	XOLAWARE_DEBUG_WEBVIEW_DATA("wr<>");

	[self setRotating:YES];
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

	// re-xooming isn't necessary if the content is blank,
	if ([self isBlankOrEmptyURL:_currentURL])
		return;

	// because the pre-iOS 6.0 default-scale is different for portrait vs landscape,
	// both the default scale and the xoom scale must be adjusted
	if (self.isRuntimePre_6_0)
	{
		[self resetDefaultXoomScale];
		[self rotateXoomScale];
		XOLAWARE_DEBUG_WEBVIEW_DATA("dR{p}[1]");
	}

	// rotating an anchor means there will be a later re-load that will xoom properly
	if (self.isRotatingAnchor)
		return;

	__weak UIScrollView* scrollView = self.webView.scrollView;
	if (self.isRuntimePre_6_0)
	{
		// in iOS 5.x, the only reliable way to have the webView properly
		// sized after rotate is to reload it.  so adjust the zoom scale
		// back to default, and then reload.

		scrollView.zoomScale = self.minimumXoomScale/self.xoomScale;
		[self setReloading:YES];
		[self.webView reload];

		XOLAWARE_DEBUG_WEBVIEW_DATA("dR{p}[2]");
	}
	else
	{
		// in iOS 6.x, UIWebView does a much better job with resizing, and the
		// turning off and on of the auto-scale feature is much cleaner, and the
		// setting of the contentView frame and the contentSize is more accurate,
		// so just reset the min/max bounds for zooming, and then start it after
		// a short delay to allow this rotate to cycle back through the caller.

		scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
		scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;
		// done as delayed perform because rotation is still part of caller animation
		NSNumber* newXoom = [NSNumber numberWithFloat:self.xoomScale];
		XOLAWARE_DEBUG_WEBVIEW_DATA("dR[1]");
		[self performSelector:@selector(xoomAfterReload:) withObject:newXoom afterDelay:0.01];
		[self setRotating:NO];
	}

	XOLAWARE_DEBUG_WEBVIEW_DATA("dR>");
#if XOLAWARE_DEBUG_WEBVIEW
	NSLog(@"____ didRotate > ____\n\n");
#endif
}

/**
 *	the ViewController using this companion is expected to invoke this whenever removing
 *	or rotating a URL containing an anchor.
 */

- (void)removeOrRotateAnchorBaseURL:(NSURL *)urlWithoutAnchor {
	XOLAWARE_DEBUG_WEBVIEW_DATA("rORABURL<");
	if (self.hasAnchor)
	{
		[self setAnchor:NO];
		[self setRemovingAnchor:YES];
		if (self.isRotating)
			_rotatingAnchor = _currentURL;
		[self.webView loadRequest:[NSURLRequest requestWithURL:urlWithoutAnchor]];
	}
	XOLAWARE_DEBUG_WEBVIEW_DATA("rORABURL>");
}

#pragma mark - UIScrollViewDelegate implementation
#pragma mark @optional

/**
 *	this gets called when the bounce or flick is done after a user scroll.
 *	so re-calculate our content offset percentage at this time.
 */

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	assert(scrollView == self.webView.scrollView);
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:<");
	[self calculateContentVerticalOffsetPct];
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:>");
}

/**
 *	called at the end of a user drag in the scrollView.
 *	so re-calculate our content offset percentage at this time.
 */

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	assert(scrollView == self.webView.scrollView);
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:wD:<");
	if (!decelerate)
		[self calculateContentVerticalOffsetPct];
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDED:wD:>");
}

/**
 *	called in many circumstances; see the subcases for how to handle each
 */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	assert(scrollView == self.webView.scrollView);
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:<");

	// this case indicates user-initiated touch-activity, so just keep scrolling, but
	// disallow any change to x.
	if (scrollView.isDecelerating || scrollView.isDragging || scrollView.isZooming)
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{ddz}");
		scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);	// align on left
	}

	// this case indicates the webView has scrolled itself to an anchor location,
	// so let it happen.
	else if (self.hasAnchor && !self.isRotating && !self.isReloading)
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{hA}[1]");
		[self calculateContentVerticalOffsetPct];
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{hA}[2]");
		if (scrollView.contentOffset.y > self.browserVerticalOffsetMax)
			scrollView.contentOffset = CGPointMake(0, self.browserVerticalOffsetMax);
		if (self.webView.alpha != 1)
			[UIView animateWithDuration:0.05 animations:^{ self.webView.alpha = 1; }];
	}

	// for all other cases not involving one of the following states,
	// this is an automatic scroll, so keep the percentage where it was
	// (typically, this means a zoom is causing a scroll, so we're trying
	// to stay anchored.)
	else if (!(scrollView.isZoomBouncing
			   || self.isReloading
			   || self.isRemovingAnchor
			   || self.isScrollingToTop))
	{
		XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:{else}");
		[self resetStandardXoomOffsetInScrollView:scrollView];
	}
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDS:>");
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	self.scrollingToTop = NO;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	return self.scrollingToTop = YES;	// helps prevent resetting to a known % offset
}


				/*
					in the iOS runtime prior to 5.1, there appears to be a bug in the autoSizing
					of the view that serves as the webView.scrollView content view (i.e. the
					view used for scrollView.contentSize).

					the result is that after loading and xooming to a given spot in the view,
					some of the contents at the bottom will be cut off.
				 
					a simple minor zoom by the user in either direction corrects this, but
					automatic attempts to resolve this fail with the random appearance of the
					problem despite long delays on the performSelector calls for xoomAfterReload
					and xoomFinal.
				 
					this HACK works by greatly increasing the size of the internal
					UIWebBrowserView and the content size of the webView.scrollView to an amount
					that should always have enough space given the xoom limits (min 1.0 max 3.6)

					the bug seems to have been resolved in the iOS runtime starting in
					version 6.0 .
				 */

				- (void)uglyPre_iOS_6_HACK_ToFixHeightOfViewFrame:(UIView*)view
									   andContentSizeOfScrollView:(UIScrollView*)scrollView
				{
					__weak UIDevice* dev = UIDevice.currentDevice;
					if (_useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0
						&& (dev.userInterfaceIdiom == UIUserInterfaceIdiomPad
							|| UIInterfaceOrientationIsPortrait(dev.orientation)))
					{
						XOLAWARE_DEBUG_WEBVIEW_DATA("uPi6HTFHOVF:acSOSV:<");
						CGRect f = view.frame;
						f.size.height /= scrollView.minimumZoomScale;
						scrollView.contentSize = (view.frame = f).size;
						XOLAWARE_DEBUG_WEBVIEW_DATA("uPi6HTFHOVF:acSOSV:>");
					}
				}

/**
 *	state to establish at the start of a user-zoom or an automated animated zoom
 */

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	assert(scrollView == self.webView.scrollView);

	self.browserView = view;	// in the debugger, this is a UIWebBrowserView; save it for now…

	// without the following call, the view is more prone to having its content cut off, having
	// the zoom not complete, or having the content-offset be incorrect at the end of the xoom.
	[self uglyPre_iOS_6_HACK_ToFixHeightOfViewFrame:view andContentSizeOfScrollView:scrollView];

	XOLAWARE_DEBUG_WEBVIEW_DATA("sVWBZ:wV:<");
	scrollView.minimumZoomScale = self.minimumXoomScale / self.xoomScale;
	scrollView.maximumZoomScale = self.maximumXoomScale / self.xoomScale;
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVWBZ:wV:[1]");

	[self turnOffAutoScale];	// this causes auto-scale to turn off while zooming
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVWBZ:wV:>");
}

/**
 *	state to establish at the completion of a user-zoom or automated animated zoom.
 */

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
					   withView:(UIView *)view
						atScale:(float)scale
{
	assert(scrollView == self.webView.scrollView && view == self.browserView);

	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDEZ:wV:<");

	self.xoomScale *= scale;

	[self turnOnAutoScale];	// now that done with zooming, turn auto-scale back on
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDEZ:wV:>");
}

/**
 *	called repeatedly throughout a user zoom
 *	called at intervals in an automated animated zoom
 *	called within a non-animated zoom
 */

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	XOLAWARE_DEBUG_WEBVIEW_DATA("sVDZ:wV:<");
	if (!self.webView.scalesPageToFit)
	{
		if (scrollView.zoomScale > scrollView.maximumZoomScale * 1.1)		// allow 10% bounce
			scrollView.zoomScale = scrollView.maximumZoomScale * 1.1;

		else if (scrollView.zoomScale < scrollView.minimumZoomScale * 0.9)	// allow 10% bounce
			scrollView.zoomScale = scrollView.minimumZoomScale * 0.9;

		else	// 'zoomScale = ' cause recursive calls back into this function, so the
		{		// scrollView.zoomScale changes just above will end up here via recursive call

			XOLAWARE_DEBUG_WEBVIEW_DATA("sVDZ:wV:[1]");

			// fit the zoomed text to the scroll view width
			[self bodyContentMaxWidthInScrollView:scrollView];

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
		  _currentURL, request.URL);
#endif
	XOLAWARE_DEBUG_WEBVIEW_DATA("wV:sSLWR:nT:<>");
	self.currentURL = request.URL;

	// why bother actually loading about:blank; just make it completely transparent and move on
	if ([request.URL.absoluteString isEqualToString:@"about:blank"])
	{
		[UIView animateWithDuration:0.1 animations:^{ webView.alpha = 0; }];
		[webView.scrollView setZoomScale:webView.scrollView.minimumZoomScale animated:YES];
		return NO;
	}

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
	if (self.isRuntimePre_6_0 && (self.isReloading || self.isRemovingAnchor))
		[self resetUseAutoScaleAfterXoom];				// else content gets cut off at bottom
	XOLAWARE_DEBUG_WEBVIEW_DATA("wVDSL:>");
	if (self.isRemovingAnchor && !self.rotatingAnchor)	// hide zooming for non-rotating reload
		webView.alpha = 0;
	else if (webView.alpha)
		[UIView animateWithDuration:0.05 animations:^{ webView.alpha = 0.125; }];
	self.rotating = NO;
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

	// get the scale in case it's set below 100 in the html
	NSString* jsResult = [webView stringByEvaluatingJavaScriptFromString:JS_GET_BODY_MAX_WIDTH];
	if (![jsResult isNonEmpty] || 0 == (self.contentScale = jsResult.floatValue))
		self.contentScale = 100;

	__weak UIScrollView* scrollView = webView.scrollView;
	float previousXoomScale = self.xoomScale;
	self.xoomScale = scrollView.contentSize.width / scrollView.frame.size.width;
	XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:[1]");
	if (self.isReloading || self.isRemovingAnchor || self.isRotatingAnchor)
	{
		if (self.isRuntimePre_6_0)
			previousXoomScale /= self.minimumXoomScale;	// trick for different pre-iOS 6 scales

		// make the delay as short as possible; iOS 6.0 seems to be more efficient at this stuff
		NSTimeInterval delay = _useAutoScaleDuringFinalXoom_when_runtimePre_iOS_6_0 ? 0.2 : 0.1;

		[self performSelector:@selector(xoomAfterReload:)
				   withObject:[NSNumber numberWithFloat:previousXoomScale]
				   afterDelay:delay];
		XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{R}");
	}
	else	// i.e. initialize or re-initialize for when re-using same webView
	{
		// make it barely visible so the zoom up visible ...
		[UIView animateWithDuration:0.05 animations:^{ webView.alpha = 0.05; }];

		[scrollView setZoomScale:self.defaultXoomScale/self.xoomScale animated:YES];
		scrollView.contentOffset = CGPointZero;
		self.contentVerticalOffsetPct = 0;
		XOLAWARE_DEBUG_WEBVIEW_DATA("wVDFL:{else}");

		// ... now, make it completely visible, factoring in the 0.2 zoomScale animated duration
		[UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseIn
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
