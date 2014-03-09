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

- (UIImage*)avatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* chatMessage = [self.chat objectAtIndex:indexPath.row];
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
    CGFloat placeholderHW = 50 - 15;
    BMInitialsPlaceholderView* placeholder = [[BMInitialsPlaceholderView alloc] initWithDiameter:placeholderHW];
    placeholder.font = font;
    placeholder.initials = [self initialStringForPersonString:chatMessage[@"name"]];
    placeholder.circleColor = [self circleColorForIndexPath:indexPath];
	return placeholder.cachedVisualRepresentation;
}

- (UIColor *)circleColorForIndexPath:(NSIndexPath *)indexPath {
    return [UIColor colorWithHue:arc4random() % 256 / 256.0 saturation:0.7 brightness:0.8 alpha:1.0];
}

- (NSString *)initialStringForPersonString:(NSString *)personString {
    NSArray *comps = [personString componentsSeparatedByString:@" "];
    if ([comps count] >= 2) {
        NSString *firstName = comps[0];
        NSString *lastName = comps[1];
        return [NSString stringWithFormat:@"%@%@", [firstName substringToIndex:1], [lastName substringToIndex:1]];
    } else if ([comps count]) {
        NSString *name = comps[0];
        return [name substringToIndex:1];
    }
    return @"Unknown";
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
