//
//  IONOpenGLWindow.m
//  mpv_poi
//
//  Created by Kirk Young on 1/17/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "IONOpenGLWindow.h"

@implementation IONOpenGLWindow

- (BOOL)canBecomeMainWindow { return YES; }
- (BOOL)canBecomeKeyWindow { return YES; }

- (void)initOGLView {
    NSRect bounds = [[self contentView] bounds];
    // window coordinate origin is bottom left
    NSRect glFrame = NSMakeRect(bounds.origin.x, bounds.origin.y + 30, bounds.size.width, bounds.size.height - 30);
    _glView = [[IONOpenGLView alloc] initWithFrame:glFrame];
    [self.contentView addSubview:_glView];
    
    NSRect buttonFrame = NSMakeRect(bounds.origin.x, bounds.origin.y, 60, 30);
    _pauseButton = [[NSButton alloc] initWithFrame:buttonFrame];
    _pauseButton.buttonType = NSToggleButton;
    // button target has to be the delegate (it holds the mpv context
    // pointer), so that's set later.
    _pauseButton.action = @selector(togglePause:);
    _pauseButton.title = @"Pause";
    _pauseButton.alternateTitle = @"Play";
    [self.contentView addSubview:_pauseButton];
}

- (IBAction)togglePause:(id)sender {
    NSLog(@"toggle pause");
}

@end
