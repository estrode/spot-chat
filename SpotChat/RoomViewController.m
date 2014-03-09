//
//  RoomViewController.m
//  SpotChat
//
//  Created by ansan on 3/8/14.
//  Copyright (c) 2014 Strocca. All rights reserved.
//

#import "RoomViewController.h"
#import "ViewController.h"
#define kFirechatNS @"https://spot-chat.firebaseio.com/"

@interface RoomViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *regionArray;
@property (strong, nonatomic) IBOutlet UINavigationItem *spottNavItem;
@end

@implementation RoomViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize array that will store chat messages.
    self.rooms = [[NSMutableArray alloc] init];
    self.regionArray = [[NSMutableArray alloc] init];
    
    // Initialize the root of our Firebase namespace.
    self.firebase = [[Firebase alloc] initWithUrl:kFirechatNS];
    
    self.roomRef = [self.firebase childByAppendingPath:@"room-metadata"];
    [self initializeLocationManager];
    
    [self.roomRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.regionArray addObject:snapshot.value];
        NSLog(@"%lu elements", (unsigned long)self.regionArray.count);
        NSArray *geofences = [self buildGeofenceData];
        [self initializeRegionMonitoring:geofences];
        [self initializeLocationUpdates];
        // Reload the table view so the new room will show up.
        [self.tableView reloadData];
    }];
    
    //Change Status Bar Style to Light Content
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Remove separators from Table View
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //Putting Circo font to Nav
    //Putting Circo font to Nav
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 44)];
    titleLabel.font = [UIFont fontWithName:@"Circo" size:22.5];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"spott";
    titleLabel.textAlignment = NSTextAlignmentRight;
    [self.navigationItem setTitleView:titleLabel];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.rooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* room = [self.rooms objectAtIndex:indexPath.row];
    NSDictionary* users = room[@"users"];
    
    cell.textLabel.text = room[@"roomName"];
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%lu Active Users", (unsigned long)users.count];
    
    //Changing font of cell
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25.0f];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tbView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showChatRoom"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ViewController *destViewController = segue.destinationViewController;
        NSDictionary* room = [self.rooms objectAtIndex:indexPath.row];
        destViewController.roomId = room[@"id"];
        destViewController.roomName = room[@"roomName"];
    }
}

- (void)initializeLocationManager {
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled]) {
        [self showAlertWithMessage:@"You need to enable location services to use this app."];
        return;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside){
        NSLog(@"is in target region");
        for (NSDictionary *room in self.regionArray) {
            if ([region.identifier isEqual : room[@"id"]]) {
                if (![self.rooms containsObject:room]) {
                     [self.rooms addObject:room];
                }
                [self.tableView reloadData];
            }
        }
    }else{
        NSLog(@"is out of target region");
    }
}

- (void) initializeRegionMonitoring:(NSArray*)geofences {
    
    if (_locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
    }
    
    if(![CLLocationManager regionMonitoringAvailable]) {
        [self showAlertWithMessage:@"This app requires region monitoring features which are unavailable on this device."];
        return;
    }
    
    for(CLRegion *geofence in geofences) {
        [_locationManager requestStateForRegion:geofence];
        [_locationManager startMonitoringForRegion:geofence];
    }
    
}

- (NSArray*) buildGeofenceData {
    NSMutableArray *geofences = [NSMutableArray array];
    for(NSDictionary *regionDict in _regionArray) {
        CLRegion *region = [self mapDictionaryToRegion:regionDict];
        [geofences addObject:region];
    }
    
    return [NSArray arrayWithArray:geofences];
}

- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary {
    NSString *title = [dictionary valueForKey:@"id"];
    
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    return [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                   radius:regionRadius
                                               identifier:title];
}

#pragma mark - Location Manager - Region Task Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered Region - %@", region.identifier);
    for (NSDictionary *room in self.regionArray) {
        if ([region.identifier isEqual : room[@"id"]]) {
            if (![self.rooms containsObject:room]) {
                [self.rooms addObject:room];
            }
            [self.tableView reloadData];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited Region - %@", region.identifier);
    for (NSDictionary *room in self.rooms) {
        if ([region.identifier isEqual : room[@"id"]]) {
            [self.rooms removeObject:room];
            [self.tableView reloadData];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region", region.identifier);
}

- (void)initializeLocationUpdates {
    [_locationManager startUpdatingLocation];
}


- (void)showAlertWithMessage:(NSString*)alertText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Error"
                                                        message:alertText
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
