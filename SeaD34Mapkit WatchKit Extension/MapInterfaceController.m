//
//  MapInterfaceController.m
//  SeaD34Mapkit
//
//  Created by User on 5/4/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

#import "MapInterfaceController.h"

@interface MapInterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *mapInterface;

@end

@implementation MapInterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  CLCircularRegion *region = (CLCircularRegion *)context;
  self.titleLabel.text = region.identifier;
  MKCoordinateRegion mkRegion = MKCoordinateRegionMakeWithDistance(region.center, 2*region.radius, 2*region.radius);
  [self.mapInterface setRegion:mkRegion];
}



@end



