//
//  MKMapView+ARKit.m
//  ARKit
//
//  Created by Adam Rothman on 10/24/12.
//
//  Some useful MKMapView extensions.
//

#import "MKMapView+ARKit.h"

static CLLocationDegrees paddingMultiplier = 1.025;
static CLLocationDegrees latitudePadding = 0.0125;
static CLLocationDegrees longitudePadding = 0.0125;

@implementation MKMapView (ARKit)

- (NSArray *)annotationsWithoutUserLocation {
  if (!self.userLocation) return self.annotations;
  NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.annotations];
  [annotations removeObject:self.userLocation];
  return annotations;
}

- (void)zoomToFitAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated {
  MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(latitudePadding, longitudePadding));
  [self setRegion:[self regionThatFits:region] animated:animated];
}

- (void)zoomToFitAnnotationsWithUser:(BOOL)user animated:(BOOL)animated {
  NSArray *annotations = user || !self.userLocation ? self.annotations : self.annotationsWithoutUserLocation;
  if (annotations.count) {
    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(-90, 180);
    CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(90, -180);
    for (id<MKAnnotation> annotation in annotations) {
      topLeft.latitude = fmax(topLeft.latitude, annotation.coordinate.latitude);
      topLeft.longitude = fmin(topLeft.longitude, annotation.coordinate.longitude);
      bottomRight.latitude = fmin(bottomRight.latitude, annotation.coordinate.latitude);
      bottomRight.longitude = fmax(bottomRight.longitude, annotation.coordinate.longitude);
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2, topLeft.longitude + (bottomRight.longitude - topLeft.longitude) / 2);
    MKCoordinateSpan span = MKCoordinateSpanMake(fabs(topLeft.latitude - bottomRight.latitude) * paddingMultiplier, fabs(bottomRight.longitude - topLeft.longitude) * paddingMultiplier);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self setRegion:[self regionThatFits:region] animated:animated];
  }
}

- (void)zoomToFitUserAnimated:(BOOL)animated {
  if (self.userLocation) {
    MKCoordinateRegion region = MKCoordinateRegionMake(self.userLocation.location.coordinate, MKCoordinateSpanMake(latitudePadding, longitudePadding));
    [self setRegion:[self regionThatFits:region] animated:animated];
  }
}

@end
