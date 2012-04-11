//
//  MapInWebViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.08.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import "MapInWebViewController.h"

#define MAP_URL "http://maps.google.com/maps?q="

@implementation MapInWebViewController
@synthesize webView;
@synthesize locationInMap = _locationInMap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
    }
    return self;
}

- (NSURL*)googleURL
{
	NSString* googleLoc
 	  = [_locationInMap stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	return [NSURL URLWithString:[@MAP_URL stringByAppendingString:googleLoc]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[self googleURL]]];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
