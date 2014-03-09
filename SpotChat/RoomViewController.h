//
//  RoomViewController.h
//  SpotChat
//
//  Created by ansan on 3/8/14.
//  Copyright (c) 2014 Strocca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>

@interface RoomViewController : UITableViewController<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray* rooms;
@property (nonatomic, strong) Firebase* firebase;
@property (nonatomic, strong) Firebase* roomRef;

@end
