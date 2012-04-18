//
//  MapViewControllerViewController.h
//  ShutterBugDemo
//
//  Created by me on 2012.04.11.
//  Copyright (c) 2012 xolaware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate<NSObject>

@optional

- (UIImage*)mapViewController:(MapViewController*)sender
		   imageForAnnotation:(id<MKAnnotation>)annotation;

- (void)mapViewController:(MapViewController*)sender
	   selectedAnnotation:(id<MKAnnotation>)annotation;

@end
   
@interface MapViewController : UIViewController

@property (strong, nonatomic) NSArray* annotations;	// of id<MKAnnotation>

@property (weak, nonatomic) id<MapViewControllerDelegate> delegate;

@end
