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
	self.webView.delegate = self;		// to enable fwd button in webViewDidFinishLoad:

	// allow a little zooming, since the pages come up really small on iPhone
	self.webView.scrollView.minimumZoomScale = 0.8;
	self.webView.scrollView.maximumZoomScale = 2.0;

	if (self.originatingURL)
		[self.webView loadRequest:[NSURLRequest requestWithURL:self.originatingURL]];
	else
	{
		NSString* resPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:resPath]]];
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

