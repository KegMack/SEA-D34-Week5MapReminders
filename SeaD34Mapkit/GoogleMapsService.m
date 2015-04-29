//
//  GoogleMapsService.m
//  SeaD34Mapkit
//
//  Created by User on 4/28/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

#import "GoogleMapsService.h"

@implementation GoogleMapsService

+ (void) fetchImageAtCoordinates:(CLLocationCoordinate2D)location ofSize:(CGSize)imageSize completionHandler:(void (^)(UIImage*, NSString*))completionBlock {
  
  NSString *baseUrlString = @"https://maps.googleapis.com/maps/api/streetview?";
  NSString *coordinatesString = [NSString stringWithFormat:@"location=%f,%f&size=%dx%d", location.latitude, location.longitude, (int)imageSize.width, (int)imageSize.height];
  NSString *urlString = [baseUrlString stringByAppendingString:coordinatesString];
  NSURL *url = [[NSURL alloc] initWithString:urlString];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  
  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if(error != nil) {
      NSString *errorString = [NSString stringWithFormat:@"Error: %@",error];
      completionBlock(nil, errorString);
    }
    else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if(image != nil) {
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(image, nil);
          }];
        }
      }
      else {
        NSString *errorString = [NSString stringWithFormat: @"Status Code: %ld", httpResponse.statusCode];
        completionBlock(nil, errorString);
      }
    }
  }];
  
  [dataTask resume];
}


@end
