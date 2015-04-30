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
@property (nonatomic) CLLocationCoordinate2D chosenCoords;

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
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionAdded:) name:@"RegionAdded" object:nil];
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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

      UIButton *streetView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, thumbnailDimension, thumbnailDimension)];
      [GoogleMapsService fetchImageAtCoordinates:[pinView.annotation coordinate] ofSize:CGSizeMake(thumbnailDimension, thumbnailDimension) completionHandler:^(UIImage *image, NSString *error) {
        if(error) {
          NSLog(@"%@", error);
        } else if(tag == pinView.tag) {
          [streetView setBackgroundImage:image forState:UIControlStateNormal];
        }
      }];
      pinView.leftCalloutAccessoryView = streetView;
      
      // set tag to 1 to differentiate from left callout for tap/action purposes
      UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
      rightButton.tag = 1;
      pinView.rightCalloutAccessoryView = rightButton;
      
    } else {
      pinView.annotation = annotation;
    }
    return pinView;
  }
  return nil;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  
  //tag = 0 for left callout
  if(control.tag == 0) {
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
  
  // tag = 1 for right callout
  else if(control.tag == 1) {
    self.chosenCoords = [view.annotation coordinate];
    [self performSegueWithIdentifier:@"ReminderDetailSegue" sender:self];
  }
}

-(void)regionAdded:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  CLCircularRegion *region = userInfo[@"region"];
  MKCircle *circle = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
  [self.mapView addOverlay:circle];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
  circleRenderer.fillColor = [UIColor redColor];
  circleRenderer.alpha = 0.3;
  circleRenderer.strokeColor = [UIColor blackColor];
  return circleRenderer;
}

//MARK: CLLocation Delegation

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  NSLog(@"entered: %@", region.identifier);
  notification.alertBody = @"Awesome!";
  notification.alertTitle = [NSString stringWithFormat: @"You are near %@", region.identifier];
  notification.alertAction = @"region launch";
  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
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

//MARK: Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqual: @"ReminderDetailSegue"]) {
    AddReminderDetailViewController *destinationVC = segue.destinationViewController;
    destinationVC.coordinates = self.chosenCoords;
    destinationVC.locationManager = self.locationManager;
  }
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
