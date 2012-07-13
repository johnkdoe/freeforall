//
//  FlipsideViewController.m
//	xolawareUI

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "FlipsideViewController.h"
#import "NSString+Utilities.h"

@interface FlipsideViewController () <UIWebViewDelegate>
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_4_3
{
	UIInterfaceOrientation originalOrientation;
}
#endif

@property (nonatomic) int backCount;
@property (nonatomic) BOOL delegateScrollsToTop;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3
@property (readonly, weak, nonatomic) IBOutlet UINavigationItem *flipsideNavigationItem;
@property (readonly, weak, nonatomic) IBOutlet UIWebView *webView;
#else
@property (readonly, unsafe_unretained, nonatomic) IBOutlet UINavigationItem *flipsideNavigationItem;
@property (readonly, unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
#endif
@end

@implementation FlipsideViewController

@synthesize flipsideViewControllerDelegate = _flipsideViewControllerDelegate;
@synthesize originatingURL = _originatingURL;

@synthesize backCount = _backCount;
@synthesize delegateScrollsToTop = _delegateScrollsToTop;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize flipsideNavigationItem;
@synthesize webView;

#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_4_3
- (UITapGestureRecognizer*)tapRecognizer {
	if (!_tapRecognizer)
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
																 action:@selector(done:)];
	return _tapRecognizer;
}
#endif

#pragma mark - UIViewController life cycle overrides
#pragma @optional

- (void)viewDidLoad
{
	[super viewDidLoad];

	// cover both bases in case the flipside segue is normal navigation
	// or modal with its own navigationItem
	if (self.flipsideNavigationItem)
		self.title = NSLocalizedString(self.flipsideNavigationItem.title, nil);
	else
		self.title = NSLocalizedString(self.title, nil);
	self.flipsideNavigationItem.title = self.title;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
			 
	// could have lived with self.webView being nil in all message passing below,
	// but why go through the trouble of looking up the URL, etc, if no webView exists
	if (self.webView)
	{
		self.webView.delegate = self;		// to enable fwd button in webViewDidFinishLoad:

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3
		UIScrollView* webScrollView = self.webView.scrollView;
#else
		originalOrientation = [[UIDevice currentDevice] orientation];
		BOOL iOS5plus = [self.webView respondsToSelector:@selector(scrollView)];
		UIScrollView* webScrollView
		  = iOS5plus ? self.webView.scrollView : (id)[self.webView.subviews objectAtIndex:0];
		assert([webScrollView isKindOfClass:[UIScrollView class]]);
		if (!iOS5plus)
			self.webView.backgroundColor = self.view.backgroundColor;	// glitch in iOS 4.x
#endif
		// allow a little zooming, since the pages come up really small on iPhone
		webScrollView.minimumZoomScale = 0.25;
		webScrollView.maximumZoomScale = 1.75;
		if ([self.flipsideViewControllerDelegate respondsToSelector:@selector(setScrollsToTop:)]
			&& [self.flipsideViewControllerDelegate respondsToSelector:@selector(scrollsToTop)]
			&& (_delegateScrollsToTop = self.flipsideViewControllerDelegate.scrollsToTop))
		{
			self.flipsideViewControllerDelegate.scrollsToTop = NO;
			webScrollView.scrollsToTop = YES;			
		}

		NSURL* url = self.originatingURL;
		if (!url)
			url = @"index".urlForMainBundleResourceHTML;

		[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
	}
	if (animated && UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom])
	{
		self.view.alpha = 0;
		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut
						 animations:^{ self.view.alpha = 1; } completion:nil];
	}
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_4_3
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom])
	{
		// if building for __IPHONE_5_0+, the gesture-recognizer will be in the storyboard 
		// and thus added when loaded, done.
		// for iPad, we're undoubtedly in a popover, so skip this, done.
		if (!(self.webView && self.webView.userInteractionEnabled))
			[self.view addGestureRecognizer:self.tapRecognizer]; // tapRecognizer lazy-generated
	}
}
#endif	

- (void)viewWillDisappear:(BOOL)animated
{
	// necessary to do this here, because done may be skipped if the user taps on
	// the partial curl part to pop the modal view controller away
	if ([self.flipsideViewControllerDelegate respondsToSelector:@selector(setScrollsToTop:)]
		&& _delegateScrollsToTop)
	{
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3
		UIScrollView* webScrollView = self.webView.scrollView;
#else
		BOOL iOS5plus = [self.webView respondsToSelector:@selector(scrollView)];
		UIScrollView* webScrollView
		  = iOS5plus ? self.webView.scrollView : (id)[self.webView.subviews objectAtIndex:0];
		assert([webScrollView isKindOfClass:[UIScrollView class]]);
#endif
		webScrollView.scrollsToTop = NO;
		self.flipsideViewControllerDelegate.scrollsToTop = YES;
		_delegateScrollsToTop = NO;
	}
	SEL flipsideViewControllerWillPop = @selector(flipsideViewControllerWillPop:);
	if ([self.flipsideViewControllerDelegate respondsToSelector:flipsideViewControllerWillPop])
		[self.flipsideViewControllerDelegate flipsideViewControllerWillPop:self];

	// ??? … not entirely certain the following is necessary …
	if (_tapRecognizer)
	{
		[self.view removeGestureRecognizer:_tapRecognizer];
		[self setTapRecognizer:nil];	// automatically generated
	}
	if (animated && UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom])
		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseIn
						 animations:^{ self.view.alpha = 0; } completion:nil];
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_4_3
	[self setOriginatingURL:nil];	// automatically generated
	[self setFlipsideViewControllerDelegate:nil];	// automatically generated
#endif
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= __IPHONE_4_3
	// it would seem there's a bug in iOS 4.x and before whereby the old webView internal
	// scrollView will rotate its contents, even in a modal view.  to prevent that (and thus
	// to allow our help HTML to be displayed "full-screen" as desired), simply disallow the
	// view from being rotated from anything but the orientation at startup
	if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom]
		&& ![self.webView respondsToSelector:@selector(scrollView)])
		return originalOrientation ? originalOrientation == interfaceOrientation : YES;
#endif
	return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
	if (self.webView.canGoBack)	// relying on false for a nil webView
	{
		[self.webView goBack];
		self.flipsideNavigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		[self.flipsideViewControllerDelegate flipsideViewControllerDidFinish:self];
	}
}

- (IBAction)forward:(UIBarButtonItem*)forwardButton
{
	if (self.webView.canGoForward)
		[self.webView goForward];
	else
		forwardButton.enabled = NO;
}

#pragma mark - UIWebViewDelegate implementation
#pragma mark @optional

- (void)webViewDidFinishLoad:(UIWebView*)webView {
	self.flipsideNavigationItem.rightBarButtonItem.enabled = self.webView.canGoForward;
}

@end

