//
//  IONOpenGLWindow.h
//  mpv_poi
//
//  Created by Kirk Young on 1/17/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IONOpenGLView.h"
#import "IONPlayerControlView.h"

@interface IONOpenGLWindow : NSWindow

@property (strong, readonly) IONOpenGLView *glView;
@property (strong, readonly) NSButton * pauseButton;

@property (strong) IONPlayerControlView * controllerView;

- (void)initOGLView;
@end
