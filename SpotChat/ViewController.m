//
//  ViewController.m
//  SpotChat
//
//  Copyright (c) 2014 Strocca.
//

#import "ViewController.h"

#define kFirechatNS @"https://spot-chat.firebaseio.com/"

@interface ViewController () <AMBubbleTableDataSource, AMBubbleTableDelegate>

@end

@implementation ViewController

#pragma mark - Setup

// Initialization.
- (void)viewDidLoad
{
    
    [self setDataSource:self]; // Weird, uh?
	[self setDelegate:self];
	
    // Initialize array that will store chat messages.
    self.chat = [[NSMutableArray alloc] init];
    
    // Initialize the root of our Firebase namespace.
    self.firebase = [[Firebase alloc] initWithUrl:kFirechatNS];
    self.messagesRef = [[Firebase alloc] init];
    Firebase* roomRef = [self.firebase childByAppendingPath:@"room-messages"];
    self.messagesRef = [roomRef childByAppendingPath:[NSString stringWithFormat:@"%@", self.roomId]];
    
    // Pick a random number between 1-1000 for our username.
    self.name = [NSString stringWithFormat:@"Guest%d", arc4random() % 1000];
    [self setTitle:self.roomName];
    
    [self setTableStyle:AMBubbleTableStyleFlat];
    [self setBubbleTableOptions:@{AMOptionsBubbleDetectionType: @(UIDataDetectorTypeAll),
								  AMOptionsBubblePressEnabled: @NO,
								  AMOptionsBubbleSwipeEnabled: @NO}];
    
    [self.messagesRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // Add the chat message to the array.
        [self.chat addObject:snapshot.value];
        // Reload the table view so the new message will show up.
        [self.tableView reloadData];
    }];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)swipedCellAtIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)frame andDirection:(UISwipeGestureRecognizerDirection)direction
{
	NSLog(@"swiped");
}


- (NSInteger)numberOfRows
{
	return [self.chat count];
}

- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* chatMessage = [self.chat objectAtIndex:indexPath.row];
    if (chatMessage[@"name"] == self.name) {
        return AMBubbleCellSent;
    } else {
        return AMBubbleCellReceived;
    }
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* chatMessage = [self.chat objectAtIndex:indexPath.row];
	return chatMessage[@"text"];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [NSDate date];
}

- (NSString*)usernameForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* chatMessage = [self.chat objectAtIndex:indexPath.row];
	return chatMessage[@"name"];
}

- (void)didSendText:(NSString*)text
{
    [[self.messagesRef childByAutoId] setValue:@{@"name" : self.name, @"text": text}];
}


@end
