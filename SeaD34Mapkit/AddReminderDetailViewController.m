//
//  AddReminderDetailViewController.m
//  SeaD34Mapkit
//
//  Created by User on 4/29/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

#import "AddReminderDetailViewController.h"

@interface AddReminderDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *minRadiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxRadiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
//@property (nonatomic) CLLocationCoordinate2D coordinates;

@end



@implementation AddReminderDetailViewController

float METERS_PER_MILE = 1609.34;

//Following Constants expressed in miles
float MINIMUM_RADIUS = 0.05;
float MAXIMUM_RADIUS = 25;
float DEFAULT_RADIUS = 2.0;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.radiusSlider.minimumValue = MINIMUM_RADIUS;
  self.radiusSlider.maximumValue = MAXIMUM_RADIUS;
  [self.radiusSlider setValue: DEFAULT_RADIUS animated:false];
  self.minRadiusLabel.text = [NSString stringWithFormat:@"%.02f", MINIMUM_RADIUS];
  self.maxRadiusLabel.text = [NSString stringWithFormat:@"%.02f", MAXIMUM_RADIUS];
  self.radiusLabel.text = [NSString stringWithFormat:@"%.02f Miles", DEFAULT_RADIUS];

}

// User Actions

- (IBAction)radiusSliderChanged:(UISlider *)sender {
  self.radiusLabel.text = [NSString stringWithFormat:@"%.02f Miles",sender.value];
}


- (IBAction)createPressed:(UIButton *)sender {
  if ([self.nameTextField.text isEqualToString:@""]) {
    [self shake:self.nameTextField];
  }
  else if ( [CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
    float radius = [self metersFromMiles:(self.radiusSlider.value)];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:self.coordinates radius:radius identifier:self.nameTextField.text];
    [self.locationManager startMonitoringForRegion:region];
    
    NSDictionary *userInfo = @{@"region" : region};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionAdded" object:self userInfo:userInfo];
    
    [self dismissViewControllerAnimated:true completion:nil];
  }
  
}

//MARK: TextField Delegation

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return true;
}

//MARK:  Misc Helper Methods

- (float)metersFromMiles:(float)miles {
  return miles * METERS_PER_MILE;
}

-(void) shake:(UIView *)viewToShake {
  [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0 initialSpringVelocity:10 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
    viewToShake.transform = CGAffineTransformMakeTranslation(5, 0);
  } completion:^(BOOL finished) {
    viewToShake.transform = CGAffineTransformMakeTranslation(0, 0);
  }];
}

@end
