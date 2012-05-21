//
//  FlipsideViewController.m
//	xolawareUI

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "FlipsideViewController.h"

@interface FlipsideViewController () <UIWebViewDelegate>

@property (nonatomic) int backCount;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (readonly, weak, nonatomic) IBOutlet UINavigationItem* flipsideNavigationItem;
@property (readonly, weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation FlipsideViewController

@synthesize flipsideViewControllerDelegate = _flipsideViewControllerDelegate;
@synthesize originatingURL = _originatingURL;

@synthesize backCount = _backCount;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize flipsideNavigationItem;
@synthesize webView;

#pragma mark - UIViewController life cycle overrides

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// could have lived with self.webView being nil in all message passing below,
	// but why go through the trouble of looking up the URL, etc, if no webView exists
	if (self.webView)
	{
		self.webView.delegate = self;		// to enable fwd button in webViewDidFinishLoad:

		// allow a little zooming, since the pages come up really small on iPhone
		self.webView.scrollView.minimumZoomScale = 0.8;
		self.webView.scrollView.maximumZoomScale = 2.0;

		NSURL* url = self.originatingURL;
		if (!url)
		{
			NSString* resPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
			if (resPath)
				url = [NSURL fileURLWithPath:resPath];
		}

		[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
	}
}

- (void)viewDidUnload {
	[self setTapRecognizer:nil];	// automatically generated
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Actions

- (IBAction)done:(UIBarButtonItem*)backButton
{
	if (self.webView.canGoBack)
	{
		[self.webView goBack];
		self.flipsideNavigationItem.rightBarButtonItem.enabled = YES;
	}
	else
		[self.flipsideViewControllerDelegate flipsideViewControllerDidFinish:self];
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

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
	self.flipsideNavigationItem.rightBarButtonItem.enabled = self.webView.canGoForward;
}

@end

