//
//  ZATViewController.m
//  MapsTest
//
//  Created by Zack Tanner on 3/8/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property(strong,nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) IBOutlet UIToolbar *followMe;
@property (strong, nonatomic) IBOutlet UILabel *followLabel;
@end
#define METERS_PER_MILE 1609.344
@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.mapView.delegate = self;
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;  //user must hold for 1 second
    [_mapView addGestureRecognizer:lpgr];
    //[lpgr release];
    
    _isFollowing = NO;
    [self.locationManager startUpdatingLocation];
    
    
}
- (IBAction)followMe:(id)sender {
    if(_isFollowing) {
        _isFollowing = NO;
        _followLabel.text = @"Follow Me";
    } else {
        _isFollowing = YES;
        _followLabel.text = @"Stop Following Me";
        
    }
    
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    if(_isFollowing) {
        CLLocation* loc = [locations lastObject]; // locations is guaranteed to have at least one object
        
        float latitude = loc.coordinate.latitude;
        float longitude = loc.coordinate.longitude;
        CLLocationCoordinate2D zoomLocation;
        
        zoomLocation.latitude = latitude;
        zoomLocation.longitude= longitude;
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [_mapView setRegion:viewRegion animated:YES];
    }
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  
{
    NSLog(@"Alert View dismissed with button at index %d",buttonIndex);
    
    switch (alertView.alertViewStyle)
    {
        case UIAlertViewStylePlainTextInput:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSLog(@"Plain text input: %@",textField.text);
            
            if(buttonIndex == 0 ) {
                for (id<MKOverlay> overlay in _mapView.overlays)
                {
                    [self.mapView removeOverlay:overlay];
                }
                for(id<MKAnnotation> annotation in _mapView.annotations) {
                    [self.mapView removeAnnotation:annotation];
                }
            } else {
                [self.navigationController popViewControllerAnimated:TRUE];
            }
        }
            break;
        
        default:
            break;
    }
}



- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create Chatroom"
                                                        message:@"Enter Chatroom Name"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
    

    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    
    
    //add pin where user touched down...
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    pa.title = @"Chat Room Name";
    [_mapView addAnnotation:pa];
    //[pa release];
    
    //add circle with 5km radius where user touched down...
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:touchMapCoordinate radius:100];
    [_mapView addOverlay:circle];
    
    
}




- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay;
{
    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor blackColor];
    circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
    circleView.lineWidth = 1;
    return circleView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
