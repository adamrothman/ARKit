//
//  MKMapView+ARKit.h
//  ARKit
//
//  Created by Adam Rothman on 10/24/12.
//
//  Some useful MKMapView extensions.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ARKit)

#define PADDING_MULTIPLIER  1.025
#define LATITUDE_PADDING    0.0125
#define LONGITUDE_PADDING   0.0125

// Returns map's annotations without the user's location
- (NSArray *)annotationsWithoutUserLocation;

// Zoom and center the map so that it displays the given annotation
- (void)zoomToFitAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated;

// Zoom and center the map so that it displays all of its annotations
- (void)zoomToFitAnnotationsWithUser:(BOOL)user animated:(BOOL)animated;

// Zoom and center the map so that it displays the user's location
- (void)zoomToFitUserAnimated:(BOOL)animated;

@end
