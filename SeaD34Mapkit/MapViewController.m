//
//  MapViewController.m
//  SeaD34Mapkit
//
//  Created by User on 4/27/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) UIImageView *largeImageView;

@end


@implementation MapViewController

int thumbnailDimension = 40;
int largeImageDimension = 640;
int maxGoogleStreetViewImageDimension = 640;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  largeImageDimension = MIN(self.view.frame.size.width, self.view.frame.size.height);
  largeImageDimension = MIN(largeImageDimension, maxGoogleStreetViewImageDimension);
  
  self.mapView.delegate = self;
  self.mapView.mapType = MKMapTypeHybrid;
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
  [self.mapView addGestureRecognizer:longPress];
  
  [self initializeLocationManager];
  
}

- (void)initializeLocationManager {
  self.locationManager = [[CLLocationManager alloc] init];
  [self.locationManager requestAlwaysAuthorization];
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  self.locationManager.pausesLocationUpdatesAutomatically = true;
  if([CLLocationManager locationServicesEnabled]) {
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.mapView.showsUserLocation = true;
  }
}

//MARK: MKMap Delegation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

  if (![annotation isKindOfClass:[MKUserLocation class]]) {
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PinAnnotation"];
    if (!pinView) {
      pinView.tag++;
      NSInteger tag = pinView.tag;
      pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinAnnotation"];
      pinView.draggable = true;
      pinView.animatesDrop = true;
      pinView.pinColor = MKPinAnnotationColorGreen;
      pinView.canShowCallout = true;
      UIImageView *streetView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailDimension, thumbnailDimension)];

      [GoogleMapsService fetchImageAtCoordinates:[pinView.annotation coordinate] ofSize:CGSizeMake(thumbnailDimension, thumbnailDimension) completionHandler:^(UIImage *image, NSString *error) {
        if(error) {
          NSLog(@"%@", error);
        } else if(tag == pinView.tag) {
          streetView.image = image;
        }
      }];

      pinView.leftCalloutAccessoryView = streetView;
      
    } else {
      pinView.annotation = annotation;
    }
    return pinView;
  }
  return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  
  __weak MapViewController *weakSelf = self;
  
  [GoogleMapsService fetchImageAtCoordinates:[view.annotation coordinate] ofSize:CGSizeMake(largeImageDimension, largeImageDimension) completionHandler:^(UIImage *image, NSString *error) {
    if(error) {
      NSLog(@"%@", error);
    } else if(image) {
      UIImageView *largeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, largeImageDimension, largeImageDimension)];
      weakSelf.largeImageView = largeImageView;
      weakSelf.largeImageView.image = image;
      [weakSelf.view addSubview:weakSelf.largeImageView];
    }
  }];
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {

}

//MARK: Gesture Actions

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
  if(gesture.state == UIGestureRecognizerStateBegan) {
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    CGPoint locationInView = [gesture locationInView:self.mapView];
    CLLocationCoordinate2D coords = [self.mapView convertPoint:locationInView toCoordinateFromView:self.mapView];
    annotation.coordinate = coords;
    annotation.title = @"something";
    [self.mapView addAnnotation:annotation];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.largeImageView.frame = CGRectMake(0, -largeImageDimension, largeImageDimension, largeImageDimension);
}

//MARK: ToolBar actions

- (IBAction)changeDisplay:(UIBarButtonItem *)sender {
  if (self.mapView.mapType == MKMapTypeStandard) {
    [self.mapView setMapType:MKMapTypeSatellite];
  } else if (self.mapView.mapType == MKMapTypeSatellite) {
    [self.mapView setMapType:MKMapTypeHybrid];
  } else {
    [self.mapView setMapType:MKMapTypeStandard];
  }
}

- (IBAction)location1Pressed:(UIBarButtonItem *)sender {
  MKCoordinateRegion labyrinthRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(46.164564, 7.028782), MKCoordinateSpanMake(0.0002, 0.0002));
  [self.mapView setRegion:labyrinthRegion animated:true];
}

- (IBAction)location2Pressed:(UIBarButtonItem *)sender {
  MKCoordinateRegion heartRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(-20.937542, 164.658825), MKCoordinateSpanMake(0.001, 0.001));
  [self.mapView setRegion:heartRegion animated:true];
}

- (IBAction)location3Pressed:(UIBarButtonItem *)sender {
  MKCoordinateRegion tortugaRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(-1.014052, -90.873267), MKCoordinateSpanMake(0.03, 0.03));
  [self.mapView setRegion:tortugaRegion animated:true];
}



@end
