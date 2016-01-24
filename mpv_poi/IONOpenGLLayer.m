//
//  IONOpenGLLayer.m
//  mpv_poi
//
//  Created by Kirk Young on 1/21/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "IONOpenGLLayer.h"
#import <OpenGL/gl.h>

@implementation IONOpenGLLayer


- (NSOpenGLContext *)openGLContextForPixelFormat:(NSOpenGLPixelFormat *)pixelFormat {
    
    return nil;
}
/* Invoked by AppKit to ask the layer whether it can draw.  Normally one would return YES, but one can return NO to cause the current frame to be skipped.
 */
- (BOOL)canDrawInOpenGLContext:(NSOpenGLContext *)context pixelFormat:(NSOpenGLPixelFormat *)pixelFormat forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts {
    if (self.mpvOpenGLContext != nil) {
        return YES;
    }
    return NO;
}

/* Invoked by AppKit to ask the layer to draw.
 */
- (void)drawInOpenGLContext:(NSOpenGLContext *)context pixelFormat:(NSOpenGLPixelFormat *)pixelFormat forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts {
    if (self.mpvOpenGLContext) {
        mpv_opengl_cb_draw(self.mpvOpenGLContext, 0, self.bounds.size.width, -self.bounds.size.height);
    } else {
        [self fillBlack];
    }
    [context flushBuffer];
}

- (void)fillBlack
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
