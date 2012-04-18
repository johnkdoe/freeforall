//
//  ScrollableImageDetailViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "ScrollableImageDetailViewController.h"
#import "UIViewController+UISplitViewControllerUtilities.h"

@interface ScrollableImageDetailViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tripleTapGesture;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) UIImageView* nestedImageView;
@end

@implementation ScrollableImageDetailViewController
@synthesize singleTapGesture = _singleTapGesture;
@synthesize doubleTapGesture = _doubleTapGesture;
@synthesize tripleTapGesture = _tripleTapGesture;
@synthesize scrollView = _scrollView;
@synthesize nestedImageView = _nestedImageView;
@synthesize image = _image;

- (void)debugLog:(NSString*)caller
{
//	NSLog(@"[%@]z=%g,svb={%g,%g,%g,%g},svf={%g,%g,%g,%g},nivb={%g,%g,%g,%g},nivf={%g,%g,%g,%g}",
//		  caller, self.scrollView.zoomScale,
//		  self.scrollView.bounds.origin.x, self.scrollView.bounds.origin.y,
//		  self.scrollView.bounds.size.width, self.scrollView.bounds.size.height,
//		  self.scrollView.frame.origin.x, self.scrollView.frame.origin.y,
//		  self.scrollView.frame.size.width, self.scrollView.frame.size.height,
//		  self.nestedImageView.bounds.origin.x, self.nestedImageView.bounds.origin.y,
//		  self.nestedImageView.bounds.size.width, self.nestedImageView.bounds.size.height,
//		  self.nestedImageView.bounds.origin.x, self.nestedImageView.bounds.origin.y,
//		  self.nestedImageView.bounds.size.width, self.nestedImageView.bounds.size.height
//		  );
}
- (IBAction)singleTap:(UITapGestureRecognizer *)sender
{
}

- (IBAction)doubleTap:(UITapGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		// this should cause it to bounce if it ends up greater than the max
		[self debugLog:@"t2-pre"];
		[self.scrollView setZoomScale:self.scrollView.zoomScale*1.25 animated:YES];
		[self.scrollView setNeedsDisplay];
		[self debugLog:@"t2-end"];
	}
}

- (IBAction)tripleTap:(UIGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		[self debugLog:@"t3-pre"];
		[self.scrollView setZoomScale:1 animated:YES];
		[self.scrollView setNeedsDisplay];
		[self debugLog:@"t3-end"];
	}	
}

- (void)nestImageInScrollView
{
	[self debugLog:@"ni-pre"];
	if (_nestedImageView && [self.scrollView.subviews containsObject:_nestedImageView])
	{
		self.scrollView.zoomScale = 1;
		[_nestedImageView removeFromSuperview];
	}
	[self debugLog:@"ni-cp1"];
	
	CGFloat widthScale = self.scrollView.bounds.size.width / self.image.size.width;
	CGFloat heightScale = self.scrollView.bounds.size.height / self.image.size.height;
	self.scrollView.contentSize = _image.size;

	[self.scrollView addSubview:[[UIImageView alloc] initWithImage:self.image]];
	_nestedImageView = self.scrollView.subviews.lastObject;
	
	[self debugLog:@"ni-cp2"];
	
	// must come after added to scrollView !!
	self.scrollView.minimumZoomScale = MIN(1.0, MIN(widthScale, heightScale));
	self.scrollView.maximumZoomScale = 4.0;
	self.scrollView.zoomScale = MAX(widthScale, heightScale);

	// must come after setZoomScale
	self.scrollView.contentOffset = CGPointZero;
	
	[self debugLog:@"ni-end"];
	
	[self.doubleTapGesture requireGestureRecognizerToFail:self.tripleTapGesture];
	[self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
}

- (void)setImage:(UIImage*)uiImage
{
	_image = uiImage;
	if (self.scrollView)			// this method can be invoked before viewDidLoad on iPhone
		[self nestImageInScrollView];
}

- (void)setImageTitle:(NSString*)imageTitle
{
	self.navigationItem.title = imageTitle;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
	return self.nestedImageView;
}

- (void)resetSplitViewBarButtonTitle
{
	self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Top", @"Top");
	UITabBarController* mVC = (UITabBarController*)[self masterViewController];
	if ([mVC isKindOfClass:[UITabBarController class]])
	{
		int selectedIndex = [mVC selectedIndex];
		if (selectedIndex < 0 || selectedIndex > [mVC viewControllers].count)
			selectedIndex = 0;
		UINavigationController* nc = [[mVC viewControllers] objectAtIndex:selectedIndex];
		self.navigationItem.leftBarButtonItem.title = nc.topViewController.navigationItem.title;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.scrollView.delegate = self;
	if (self.image)						// in iPhone segue, image will get set before load
		[self nestImageInScrollView];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		[self resetSplitViewBarButtonTitle];
}

- (void)viewDidUnload
{
	self.nestedImageView = nil;
	[self setScrollView:nil];		// automatically inserted by Xcode
	[self setDoubleTapGesture:nil];	// automatically inserted by Xcode
	[self setTripleTapGesture:nil];	// automatically inserted by Xcode
	[self setSingleTapGesture:nil];	// automatically isnerted by Xcode
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	// need all these values for zooming as done after the orientation
	float zoomScale = self.scrollView.zoomScale;
	float oldMinZoom = self.scrollView.minimumZoomScale;
	CGFloat widthScale = self.scrollView.bounds.size.width / self.image.size.width;
	CGFloat heightScale = self.scrollView.bounds.size.height / self.image.size.height;
	
	// just reset the zoom scales; leave center and everything else where possible
	self.scrollView.minimumZoomScale = MIN(1.0, MIN(widthScale, heightScale));
	self.scrollView.maximumZoomScale = 4.0;

	if (zoomScale == oldMinZoom || zoomScale < self.scrollView.minimumZoomScale)
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
	else if (zoomScale > self.scrollView.maximumZoomScale)
		[self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController*)splitController
	 willHideViewController:(UIViewController*)viewController
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem
	   forPopoverController:(UIPopoverController *)popoverController
{
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	[self resetSplitViewBarButtonTitle];
}

- (void)splitViewController:(UISplitViewController*)splitController
	 willShowViewController:(UIViewController*)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

@end
