//
//  AddReminderDetailViewController.h
//  SeaD34Mapkit
//
//  Created by User on 4/29/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddReminderDetailViewController : UIViewController

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coordinates;

@end
