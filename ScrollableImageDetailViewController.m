//
//  ScrollableImageDetailViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "ScrollableImageDetailViewController.h"

#import "UISplitViewController+MasterDetailUtilities.h"
#import "UITabBarController+HideTabBar.h"					// thank you Carlos Oliva

@interface ScrollableImageDetailViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tripleTapGesture;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) UIImageView* nestedImageView;

@property BOOL barsHidden;
@property (readonly) CGSize recommendedZoomScales;

@end

#pragma mark -

@implementation ScrollableImageDetailViewController

@synthesize singleTapGesture = _singleTapGesture;
@synthesize doubleTapGesture = _doubleTapGesture;
@synthesize tripleTapGesture = _tripleTapGesture;
@synthesize scrollView = _scrollView;
@synthesize nestedImageView = _nestedImageView;
@synthesize image = _image;

- (void)setImage:(UIImage*)uiImage
{
	_image = uiImage;
	if (self.scrollView)			// this method can be invoked before viewDidLoad on iPhone
		[self nestImageInScrollView];
}

- (BOOL)barsHidden
{
	return self.navigationController.navigationBarHidden;
}

- (void)setBarsHidden:(BOOL)hidden
{
	[self setBarsHidden:hidden animated:YES];
}

- (CGSize)recommendedZoomScales
{
	CGFloat widthScale = self.scrollView.bounds.size.width / self.image.size.width;
	CGFloat heightScale = self.scrollView.bounds.size.height / self.image.size.height;
	
	// just reset the zoom scales; leave center and everything else where possible
	self.scrollView.minimumZoomScale = MIN(1.0, MIN(widthScale, heightScale));
	self.scrollView.maximumZoomScale = 4.0;
	
	return CGSizeMake(widthScale, heightScale);
}

#pragma mark - ScrollableImageDetailViewController public implementation

- (void)resetSplitViewBarButtonTitle
{
	UITabBarController* mVC = [self.splitViewController masterTabBarController];
	if ([mVC isKindOfClass:[UITabBarController class]])
	{
		int selectedIndex = [mVC selectedIndex];
		if (selectedIndex < 0 || selectedIndex > [mVC viewControllers].count)
			selectedIndex = 0;
		UINavigationController* nc = [[mVC viewControllers] objectAtIndex:selectedIndex];
		self.navigationItem.leftBarButtonItem.title = nc.topViewController.navigationItem.title;
	}
}

- (void)setImageTitle:(NSString*)imageTitle
{
	self.navigationItem.title = imageTitle;
}

#pragma mark - ScrollableImageDetailViewController private implementation

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

- (void)nestImageInScrollView
{
//	[self debugLog:@"ni-pre"];
	if (_nestedImageView && [self.scrollView.subviews containsObject:_nestedImageView])
	{
		self.scrollView.zoomScale = 1;
		[_nestedImageView removeFromSuperview];
	}
//	[self debugLog:@"ni-cp1"];
	
	self.scrollView.contentSize = _image.size;

	[self.scrollView addSubview:[[UIImageView alloc] initWithImage:self.image]];
	_nestedImageView = self.scrollView.subviews.lastObject;

	CGSize recommendedZoom = self.recommendedZoomScales;
	self.scrollView.zoomScale = MAX(recommendedZoom.width, recommendedZoom.height);

	// must come after setZoomScale
	self.scrollView.contentOffset = CGPointZero;

	[self.doubleTapGesture requireGestureRecognizerToFail:self.tripleTapGesture];
	[self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	id parent = self.navigationController.parentViewController;
	if ([parent respondsToSelector:@selector(isTabBarHidden)]
		&& [parent respondsToSelector:@selector(setTabBarHidden:animated:)])
		[parent setTabBarHidden:![parent isTabBarHidden] animated:animated];

//	else if ([parent isKindOfClass:[UISplitViewController class]]
//			 && UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
//	{
//		UIView* masterView = self.masterViewController.view;						// 0x07954da0 UILayoutContainerView		  {  0,0; 320 748}
//
//		UIView* detailView = self.detailViewController.view;						// 0x0794a910 UIView					  {  0,0; 703 748}
//		UIView* viewControllerWrapperView = detailView.superview;					// 0x0794add0 UIViewControllerWrapperView {  0,0; 703 748}
//		UIView* navigationTransitionView = viewControllerWrapperView.superview;		// 0x079547d0 UINavigationTransitionView  {  0,0; 703 748}
//		UIView* detailViewLayout = navigationTransitionView.superview;				// 0x07978da0 UILayoutContainerView		  {321,0; 703 748}
//
//		assert(masterView.superview == detailViewLayout.superview);
//
//		CGRect masterViewFrame = masterView.frame;
//		CGRect detailLayoutFrame = detailViewLayout.frame;
//
//		CGFloat width = masterViewFrame.size.width - masterViewFrame.origin.x;
//		if (hidden)
//		{
//			masterViewFrame.origin.x = -width;
//			detailLayoutFrame.size.width += detailLayoutFrame.origin.x;
//			detailLayoutFrame.origin.x = 0;
//		}
//		else
//		{
//			detailLayoutFrame.size.width -= width;
//			masterViewFrame.origin.x = 0;
//			detailLayoutFrame.origin.x = width + 1;
//		}
//		CGRect innerFrame
//		  = CGRectMake(0, 0, detailLayoutFrame.size.width, detailLayoutFrame.size.height);
//		[UIView animateWithDuration:0.3 
//						 animations:^{
//							 self.masterViewController.view.frame = masterViewFrame;
//							 detailViewLayout.frame = detailLayoutFrame;
//							 navigationTransitionView.frame = innerFrame;
//							 viewControllerWrapperView.frame = innerFrame;
//							 self.detailViewController.view.frame = innerFrame;
//							 [self.masterViewController.view setHidden:hidden];
//						 }
//		 ];
//	}
}

#pragma mark - UIViewController life cycle overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.scrollView.delegate = self;
	if (self.image)						// in iPhone segue, image will get set before load
		[self nestImageInScrollView];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		[self resetSplitViewBarButtonTitle];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (self.barsHidden)
		[self setBarsHidden:NO animated:animated];
	
	[super viewWillDisappear:animated];
}

- (void)viewWillUnload
{
	if (self.barsHidden)
		[self setBarsHidden:NO animated:NO];
	
	[super viewWillUnload];
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

	if (zoomScale == oldMinZoom || zoomScale < self.scrollView.minimumZoomScale)
		[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
	else if (zoomScale > self.scrollView.maximumZoomScale)
		[self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - gesture recognizers

- (IBAction)singleTap:(UITapGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		// only adjust the zoom if the old picture used to fill the frame,
		// but (a) will be too small when hiding bars,
		// or  (b) was an exact match when exposing bars
		CGSize previousRecommendedZoom = self.recommendedZoomScales;
		BOOL hidden = self.barsHidden = !self.barsHidden;
		CGSize recommendedZoom = self.recommendedZoomScales;
		if (hidden)
		{
			if (self.scrollView.zoomScale >= previousRecommendedZoom.height
				&& self.scrollView.zoomScale < recommendedZoom.height)
				[self.scrollView setZoomScale:recommendedZoom.height animated:YES];
		}
		else	// bars now exposed
		{
			if (self.scrollView.zoomScale == previousRecommendedZoom.height)
				[self.scrollView setZoomScale:recommendedZoom.height animated:YES];
			
		}
	}
}

- (IBAction)doubleTap:(UITapGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		// this should cause it to bounce if it ends up greater than the max
		[self.scrollView setZoomScale:self.scrollView.zoomScale*1.25 animated:YES];
		[self.scrollView setNeedsDisplay];
	}
}

- (IBAction)tripleTap:(UIGestureRecognizer*)gesture
{
	if (self.image && gesture.state == UIGestureRecognizerStateRecognized)
	{
		[self.scrollView setZoomScale:1 animated:YES];
		[self.scrollView setNeedsDisplay];
	}	
}

#pragma mark - UIScrollViewDelegate
#pragma mark @optional

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
	return self.nestedImageView;
}

#pragma mark - UISplitViewControllerDelegate
#pragma mark @optional

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
