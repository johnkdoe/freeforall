//
//  MapViewControllerViewController.m
//  xolawareUI
//
//  Created by me on 2012.04.11.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "MapViewController.h"
#import "UINavigationController+NestedNavigationController.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;

@end

#pragma mark -

@implementation MapViewBasicAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (MapViewBasicAnnotation*)	initWithCoordinate:(CLLocationCoordinate2D)coordinate2D
										 title:(NSString*)title 
									  subtitle:(NSString*)subtitle
{
	self = [super init];
	if (self)
		_coordinate = coordinate2D, _title = title, _subtitle = subtitle;
	return self;
}

+ (MapViewBasicAnnotation*)basicAnnotation:(CLLocationCoordinate2D)coord2D
									 title:(NSString*)title
								  subtitle:(NSString*)sub 
{
	return [[MapViewBasicAnnotation alloc] initWithCoordinate:coord2D title:title subtitle:sub];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	_coordinate = newCoordinate;
}
@end

@implementation MapViewController

#pragma mark @synthesize
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize initialLocation = _initialLocation;
@synthesize mapView = _mapView;
@synthesize mapTypeSegmentedControl = _mapTypeSegmentedControl;
@synthesize nestedNavControllerHandler = _nestedNavControllerHandler;

#pragma mark - synthesize overrides

- (void)setAnnotations:(NSArray *)annotations {
	_annotations = annotations;
	[self updateMapView];	// keep model and view in sync
}

- (void)setInitialLocation:(id<MKAnnotation>)initialLocation {
	_initialLocation = initialLocation;
	[self updateMapView];
}

- (void)setMapView:(MKMapView*)mapView {
	_mapView = mapView;
	[self updateMapView];
}

#pragma mark // MapViewController private implementation

#pragma mark 

- (NSString*)localizedMapLabel {
	return NSLocalizedStringFromTable([self.mapTypeSegmentedControl titleForSegmentAtIndex:0],
									  @"MapViewController", nil);
}

- (NSString*)localizedSatelliteLabel {
	return NSLocalizedStringFromTable([self.mapTypeSegmentedControl titleForSegmentAtIndex:1],
									  @"MapViewController", nil);;
}

- (NSString*)localizedHybridLabel {
	return NSLocalizedStringFromTable([self.mapTypeSegmentedControl titleForSegmentAtIndex:2],
									  @"MapViewController", nil);;
}

- (MKCoordinateRegion)coordinateRegionCrossingInternationalDateLine
{
	CLLocationDegrees n = -90.0, s = 90.0, e = 180.0, w = -180.0;
	for (id<MKAnnotation> a in self.annotations)
	{
		if (a.coordinate.latitude > n)	n = a.coordinate.latitude;
		if (a.coordinate.latitude < s)	s = a.coordinate.latitude;
		if (a.coordinate.longitude < e)	e = a.coordinate.longitude;
		if (a.coordinate.longitude > w)	w = a.coordinate.longitude;
	}
	double width = (180.0-e) - (-180.0-w);
	CLLocationDegrees longitude = (((e > abs(w)) ? -180 : 180) - width/2);
	CLLocationCoordinate2D c = { (n+s)/2, longitude };
	CLLocationDegrees deltaNorthSouth = MAX(0.0666666, (n-s)*1.1);
	CLLocationDegrees widthSpan = MAX(0.0666666, width*1.1);
	return MKCoordinateRegionMake(c, MKCoordinateSpanMake(deltaNorthSouth, widthSpan));	
}

- (MKCoordinateRegion)coordinateRegionUsingAnnotations
{
	CLLocationDegrees n = -90.0, s = 90.0, e = -180.0, w = 180.0;
	for (id<MKAnnotation> a in self.annotations)
	{
		if (a.coordinate.latitude > n)	n = a.coordinate.latitude;
		if (a.coordinate.latitude < s)	s = a.coordinate.latitude;
		if (a.coordinate.longitude > e)	e = a.coordinate.longitude;
		if (a.coordinate.longitude < w)	w = a.coordinate.longitude;
		if ((e-w) > 300)	// likely crossing int'l date line
			return self.coordinateRegionCrossingInternationalDateLine;
	}
	CLLocationCoordinate2D c = { (n+s)/2, (e+w)/2 };
	CLLocationDegrees deltaNorthSouth = MAX(0.0666666, (n-s)*1.1);
	CLLocationDegrees deltaEastWest   = MAX(0.0666666, (e-w)*1.1);
	return MKCoordinateRegionMake(c, MKCoordinateSpanMake(deltaNorthSouth, deltaEastWest));
}

- (MKCoordinateSpan)defaultSpan { return MKCoordinateSpanMake(0.2, 0.2); }

- (IBAction)mapType:(UISegmentedControl*)segmentedControl {
	[self.mapView setMapType:(MKMapType)segmentedControl.selectedSegmentIndex];
}

- (void)updateMapView
{
	if (!self.mapView)
		return;
	if (self.annotations.count)
	{
		[self.mapView addAnnotations:self.annotations];
		if (self.annotations.count == 1)
		{
			id<MKAnnotation> point = self.annotations.lastObject;
			self.title = point.title;
			[self.mapView setRegion:MKCoordinateRegionMake(point.coordinate, self.defaultSpan)
						   animated:YES];
		}
		else
			[self.mapView setRegion:[self coordinateRegionUsingAnnotations] animated:YES];
	} else if (self.initialLocation) {
		self.title = self.initialLocation.title;
		self.mapView.region
		  = MKCoordinateRegionMake(self.initialLocation.coordinate, self.defaultSpan);
	}
}

#pragma mark - UIViewController life cycle // overrides

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.mapTypeSegmentedControl addTarget:self
									 action:@selector(mapType:)
						   forControlEvents:UIControlEventValueChanged];
	[self.mapTypeSegmentedControl setTitle:self.localizedMapLabel		forSegmentAtIndex:0];
	[self.mapTypeSegmentedControl setTitle:self.localizedSatelliteLabel	forSegmentAtIndex:1];
	[self.mapTypeSegmentedControl setTitle:self.localizedHybridLabel	forSegmentAtIndex:2];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
													animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		[self.navigationController popToEligibleViewController:self.nestedNavControllerHandler
													  animated:NO];
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
	[self setMapView:nil];
	[self setMapTypeSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([@"iPhoneAnnotationLeftAccessory" isEqualToString:segue.identifier])
	{
		id desintationVC = segue.destinationViewController;
		if ([desintationVC respondsToSelector:@selector(setNestedNavControllerHandler:)])
			[desintationVC setNestedNavControllerHandler:self.nestedNavControllerHandler];
		[self.delegate acceptSegueFromAnnotation:sender
					forDestinationViewController:desintationVC];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark - MKMapViewDelegate implementation
#pragma mark @optional

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	MKAnnotationView* aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
	if (aView)
	{
		aView.annotation = annotation;
	}
	else
	{
		aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
												reuseIdentifier:@"MapVC"];
		aView.canShowCallout = YES;
		aView.leftCalloutAccessoryView
		  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
	}
	return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView*)view
{
	UIImage* image = [self.delegate mapViewController:self imageForAnnotation:view.annotation];
	if (!image)
		return;

	[(UIButton*)view.leftCalloutAccessoryView setImage:image forState:UIControlStateNormal];
	UIControlState controlStatesMask = UIControlStateHighlighted | UIControlStateSelected;
	[(UIButton*)view.leftCalloutAccessoryView setImage:image forState:controlStatesMask];
}

- (void)				  mapView:(MKMapView*)mapView 
				   annotationView:(MKAnnotationView*)view
	calloutAccessoryControlTapped:(UIControl*)control
{
	assert(view.annotation);
	if (!view.annotation)	return;
	if ([self.delegate.mapPopover isKindOfClass:[UIPopoverController class]])
		[self.delegate acceptSegueFromAnnotation:view.annotation
					forDestinationViewController:nil];	// delegate will figure it out
	else
		[self performSegueWithIdentifier:@"iPhoneAnnotationLeftAccessory"
								  sender:view.annotation];
}

@end
