//
//  MKMapView+ARKit.h
//  ARKit
//
//  Created by Adam Rothman on 10/24/12.
//
//  Some useful MKMapView extensions.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MKMapView (ARKit)

// Get map's annotations without the user's location
- (NSArray *)annotationsWithoutUserLocation;

// Zoom and center the map so that it displays the given annotation
- (void)zoomToFitAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated;

// Zoom and center the map so that it displays all of its annotations
- (void)zoomToFitAnnotationsWithUser:(BOOL)user animated:(BOOL)animated;

// Zoom and center the map so that it displays the user's location
- (void)zoomToFitUserAnimated:(BOOL)animated;

@end
