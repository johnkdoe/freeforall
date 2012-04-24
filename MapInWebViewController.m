//
//  MapInWebViewController.m
//  XolawareUI
//
//  Created by me on 2012.04.08.

#include "xolawareOpenSourceCopyright.h"	// Copyright (c) 2012 xolaware.

#import "MapInWebViewController.h"

// the only reason to use this over MapKit is because it has the nav bar
// and voice-activated UI from the direct connection to the web page

#define MAP_URL "http://maps.google.com/maps?q="

@implementation MapInWebViewController
@synthesize webView;
@synthesize locationInMap = _locationInMap;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
