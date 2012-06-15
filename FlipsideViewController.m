//
//  FlipsideViewController.m
//	xolawareUI

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "FlipsideViewController.h"

@interface FlipsideViewController () <UIWebViewDelegate>

@property (nonatomic) int backCount;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3
@property (readonly, weak, nonatomic) IBOutlet UIWebView *webView;
#else
@property (readonly, unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
#endif
@end

@implementation FlipsideViewController

@synthesize flipsideViewControllerDelegate = _flipsideViewControllerDelegate;
@synthesize originatingURL = _originatingURL;

@synthesize backCount = _backCount;
@synthesize tapRecognizer = _tapRecognizer;
//@synthesize flipsideNavigationItem;
@synthesize webView;

- (UITapGestureRecognizer*)tapRecognizer {
	if (!_tapRecognizer)
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
																 action:@selector(done:)];
	return _tapRecognizer;
}

#pragma mark - UIViewController life cycle overrides
#pragma @optional

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(self.navigationItem.title, nil);

	// if this controller is modal, and style is partial-curl, the user will need a way out,
	// so recognize a tap as a way out
	if (self.modalTransitionStyle == UIModalTransitionStylePartialCurl && !self.webView)
		[self.view addGestureRecognizer:self.tapRecognizer];	// tapRecognizer auto-generated
}

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

- (void)viewDidUnload
{
	if (_tapRecognizer)
	{
		[self.view removeGestureRecognizer:_tapRecognizer];
		[self setTapRecognizer:nil];	// automatically generated
	}
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
	[self setOriginatingURL:nil];	// automatically generated
	[self setFlipsideViewControllerDelegate:nil];	// automatically generated
#endif
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
	if (self.webView.canGoBack)	// relying on false for a nil webView
	{
		[self.webView goBack];
		self.navigationItem.rightBarButtonItem.enabled = YES;
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
	self.navigationItem.rightBarButtonItem.enabled = self.webView.canGoForward;
}

@end

