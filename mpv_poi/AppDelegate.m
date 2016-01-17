//
//  AppDelegate.m
//  mpv_poi
//
//  Created by Kirk Young on 1/11/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "AppDelegate.h"
#import "IONOpenGLWindow.h"

@interface AppDelegate ()

@property (weak) IBOutlet IONOpenGLWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

// quit when the window is closed.
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSLog(@"Terminating.");
//    const char *args[] = {"quit", NULL};
//    mpv_command(mpv, args);
    [self.window.glView clearGLContext];
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
