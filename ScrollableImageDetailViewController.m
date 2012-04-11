//
//  ScrollableImageDetailViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.07.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "ScrollableImageDetailViewController.h"
#import "UIViewController+UISplitViewControllerUtilities.h"

@interface ScrollableImageDetailViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tripleTapGesture;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) UIImageView* nestedImageView;
@end

@implementation ScrollableImageDetailViewController
@synthesize doubleTapGesture = _doubleTapGesture;
@synthesize tripleTapGesture = _tripleTapGesture;
@synthesize scrollView = _scrollView;
@synthesize nestedImageView = _nestedImageView;
@synthesize image = _image;

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

- (void)nestImageInScrollView
{
	if (_nestedImageView && [self.scrollView.subviews containsObject:_nestedImageView])
	{
		self.scrollView.zoomScale = 1;
		[_nestedImageView removeFromSuperview];
	}
	
	CGFloat widthScale = self.scrollView.bounds.size.width / self.image.size.width;
	CGFloat heightScale = self.scrollView.bounds.size.height / self.image.size.height;
	self.scrollView.minimumZoomScale = MIN(1.0, MIN(widthScale, heightScale));
	self.scrollView.maximumZoomScale = 4.0;
	self.scrollView.contentSize = _image.size;
	
	[self.scrollView addSubview:[[UIImageView alloc] initWithImage:self.image]];
	_nestedImageView = self.scrollView.subviews.lastObject;
	
	// must come after added to scrollView !!
	self.scrollView.zoomScale = MAX(widthScale, heightScale);
	self.scrollView.contentOffset = CGPointZero;
	
	[self.doubleTapGesture requireGestureRecognizerToFail:self.tripleTapGesture];
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
	return self.scrollView.subviews.lastObject;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
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
