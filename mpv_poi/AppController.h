//
//  AppController.h
//  mpv_poi
//
//  Created by Kirk Young on 1/14/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject

typedef NS_ENUM(NSInteger, tagControlMenuItem) {
    kPlayTag = 10, kPauseTag, kStopTag
};

@property (weak) IBOutlet NSWindow *appWindow;
@property (weak) IBOutlet NSView * playerView;

//@property (copy) NSString * secretMessage;

- (IBAction)revealMessage:(id)sender;

- (IBAction)controlMenuAction:(id)sender;
- (IBAction)openFile:(id)sender;

@end
