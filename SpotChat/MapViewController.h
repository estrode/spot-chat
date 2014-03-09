//
//  MapViewController.h
//  MapsTest
//
//  Created by Zack Tanner on 3/8/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>


@interface MapViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL *isFollowing;
@property (nonatomic, strong) Firebase* firebase;
@end
