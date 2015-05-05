//
//  InterfaceController.m
//  SeaD34Mapkit WatchKit Extension
//
//  Created by User on 5/1/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

#import "InterfaceController.h"
#import "RegionRowController.h"
#import <CoreLocation/CoreLocation.h>

@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (strong,nonatomic) NSArray *names;
@property (strong,nonatomic) NSArray *regions;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  CLLocationManager *manager = [[CLLocationManager alloc] init];
  self.regions = manager.monitoredRegions.allObjects;
  [self.table setNumberOfRows:self.regions.count withRowType:@"RegionRow"];
  
  for (CLCircularRegion *region in self.regions) {
    NSInteger i = [self.regions indexOfObject:region];
    RegionRowController *regionController = [self.table rowControllerAtIndex:i];
    regionController.regionLabel.text = region.identifier;
  }
  [WKInterfaceController openParentApplication:nil reply:^(NSDictionary *replyInfo, NSError *error) {
  }];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  [self pushControllerWithName:@"Map Interface" context:self.regions[rowIndex]];
}

@end



