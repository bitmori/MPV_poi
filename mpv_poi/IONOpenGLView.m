//
//  IONOpenGLView.m
//  mpv_poi
//
//  Created by Kirk Young on 1/17/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "IONOpenGLView.h"
#import <OpenGL/gl.h>

@implementation IONOpenGLView

- (instancetype)initWithFrame:(NSRect)frame
{
    // make sure the pixel format is double buffered so we can use
    // [[self openGLContext] flushBuffer].
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFADoubleBuffer,
        0
    };
    self = [super initWithFrame:frame
                    pixelFormat:[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes]];
    
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        // swap on vsyncs
        GLint swapInt = 1;
        [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
        [[self openGLContext] makeCurrentContext];
        self.mpvGL = nil;
    }
    return self;
}

- (void)fillBlack
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)drawRect
{
    if (self.mpvGL)
        mpv_opengl_cb_draw(self.mpvGL, 0, self.bounds.size.width, -self.bounds.size.height);
    else
        [self fillBlack];
    [[self openGLContext] flushBuffer];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawRect];
}


//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    
//    // Drawing code here.
//}

@end
