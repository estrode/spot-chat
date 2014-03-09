//
//  ViewController.h
//  SpotChat
//
//  Copyright (c) 2014 Strocca.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "AMBubbleTableViewController.h"
#import "BMInitialsPlaceholderView.h"

@interface ViewController : AMBubbleTableViewController

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableArray* chat;
@property (nonatomic, strong) Firebase* firebase;
@property (nonatomic, strong) Firebase* messagesRef;
@property (nonatomic, strong) Firebase* userRef;
@property (nonatomic, strong) NSString* roomId;
@property (nonatomic, strong) NSString* roomName;

@end
