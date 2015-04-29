//
//  GoogleMapsService.h
//  SeaD34Mapkit
//
//  Created by User on 4/28/15.
//  Copyright (c) 2015 Craig_Chaillie. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface GoogleMapsService : NSObject

+ (void) fetchImageAtCoordinates:(CLLocationCoordinate2D)location ofSize:(CGSize)imageSize completionHandler:(void (^)(UIImage*, NSString*))completionBlock;

@end
