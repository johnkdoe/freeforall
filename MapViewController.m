//
//  MapViewControllerViewController.m
//  xolawareUI
//
//  Created by me on 2012.04.11.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;

@end

#pragma mark -

@implementation MapViewController

#pragma mark @synthesize
@synthesize delegate = _delegate;
@synthesize mapView = _mapView;
@synthesize mapTypeSegmentedControl = _mapTypeSegmentedControl;

- (void)setMapView:(MKMapView*)mapView
{
	_mapView = mapView;
	[self updateMapView];	// keep model and view in sync
}

@synthesize annotations = _annotations;
- (void)setAnnotations:(NSArray *)annotations
{
	_annotations = annotations;
	[self updateMapView];	// keep model and view in sync
}

#pragma mark // MapViewController private implementation

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
		{
			e = 180.0, w = -180.0;
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
			return MKCoordinateRegionMake(c, MKCoordinateSpanMake((n-s)*1.05, width*1.05));
		}
	}
	CLLocationCoordinate2D c = { (n+s)/2, (e+w)/2 };
	CLLocationDegrees deltaNorthSouth = MAX(0.09, (n-s)*1.05);
	CLLocationDegrees deltaEastWest   = MAX(0.09, (e-w)*1.05);
	return MKCoordinateRegionMake(c, MKCoordinateSpanMake(deltaNorthSouth, deltaEastWest));
}

- (void)updateMapView
{
	if (self.mapView.annotations)
		[self.mapView removeOverlays:self.mapView.annotations];
	if (self.annotations)
	{
		[self.mapView addAnnotations:self.annotations];
		if (self.annotations.count == 1)
		{
			id<MKAnnotation> annotation = self.annotations.lastObject;
			self.navigationItem.title = annotation.title;
			self.mapView.region
			  = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.2, 0.2));
		}
		else
			[self.mapView setRegion:[self coordinateRegionUsingAnnotations] animated:YES];
	}
}

- (IBAction)mapType:(UISegmentedControl*)segmentedControl {
	[self.mapView setMapType:(MKMapType)segmentedControl.selectedSegmentIndex];
}

#pragma mark - UIViewController life cycle // overrides

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.mapTypeSegmentedControl addTarget:self
									 action:@selector(mapType:)
						   forControlEvents:UIControlEventValueChanged];
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
		[self.delegate acceptSegueFromAnnotation:sender
					forDestinationViewController:segue.destinationViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
	[(UIButton*)view.leftCalloutAccessoryView setImage:image forState:UIControlStateNormal];
	UIControlState controlStatesMask = UIControlStateHighlighted | UIControlStateSelected;
	[(UIButton*)view.leftCalloutAccessoryView setImage:image forState:controlStatesMask];
}

- (void)				  mapView:(MKMapView*)mapView 
				   annotationView:(MKAnnotationView*)view
	calloutAccessoryControlTapped:(UIControl*)control
{
	if ([self.delegate.mapPopover isKindOfClass:[UIPopoverController class]])
		[self.delegate acceptSegueFromAnnotation:view.annotation
					forDestinationViewController:nil];	// delegate will figure it out
	else
		[self performSegueWithIdentifier:@"iPhoneAnnotationLeftAccessory"
								  sender:view.annotation];
}

@end
