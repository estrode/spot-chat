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
    
    // Initialize the root of our Firebase namespace.
    self.firebase = [[Firebase alloc] initWithUrl:kFirechatNS];
    
    Firebase* roomRef = [self.firebase childByAppendingPath:@"room-metadata"];
    
    [roomRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // Add the rooms to the array.
        [self.rooms addObject:snapshot.value];
        // Reload the table view so the new message will show up.
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
