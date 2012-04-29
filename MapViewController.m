//
//  MapViewControllerViewController.m
//  xolawareUI
//
//  Created by me on 2012.04.11.

#include "xolawareOpenSourceCopyright.h"	//  Copyright (c) 2012 xolaware.

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

#pragma mark -

@implementation MapViewController

#pragma mark @synthesize
@synthesize delegate = _delegate;
@synthesize mapView = _mapView;

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

#pragma mark - UIViewController life cycle // overrides

- (void)viewDidUnload
{
	[self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([@"iPhoneAnnotationLeftAccessory" isEqualToString:segue.identifier])
	{
		[self.delegate mapViewController:self leftAccessorySegue:segue forAnnotation:sender];
	}
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
		UIButton* annotationImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
		aView.leftCalloutAccessoryView = annotationImage;
	}
//	[(UIImageView*)aView.leftCalloutAccessoryView setImage:nil];
	return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView*)view
{
	UIImage* image = [self.delegate mapViewController:self imageForAnnotation:view.annotation];
	[(UIButton*)view.leftCalloutAccessoryView setImage:image forState:UIControlStateNormal];
	UIControlState allControlStates = UIControlStateHighlighted | UIControlStateSelected;
	[(UIButton*)view.leftCalloutAccessoryView setImage:image forState:allControlStates];
}

- (void)				  mapView:(MKMapView*)mapView 
				   annotationView:(MKAnnotationView*)view
	calloutAccessoryControlTapped:(UIControl*)control
{
	NSLog(@"%@", control);
	if (self.navigationController.splitViewController)
		;
	else
		[self performSegueWithIdentifier:@"iPhoneAnnotationLeftAccessory"
								  sender:view.annotation];
}

@end
