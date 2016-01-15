//
//  AppController.h
//  mpv_poi
//
//  Created by Kirk Young on 1/14/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FirstViewController.h"

@interface AppController : NSObject

@property (weak) IBOutlet NSView * playerView;
@property (weak) IBOutlet FirstViewController *firstViewController;

//@property (copy) NSString * secretMessage;

- (IBAction)revealMessage:(id)sender;

@end
