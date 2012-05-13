//
//  FlipsideViewController.m
//	xolawareUI

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@end

@implementation FlipsideViewController
@synthesize tapRecognizer = _tapRecognizer;

@synthesize delegate = _delegate;

- (void)awakeFromNib
{
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);	// popover only for pad
    [super awakeFromNib];
}

- (void)viewDidUnload {
	[self setTapRecognizer:nil];
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
