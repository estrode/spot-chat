//
//  MapViewController.h
//  MapsTest
//
//  Created by Zack Tanner on 3/8/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, assign) BOOL *isFollowing;
@end