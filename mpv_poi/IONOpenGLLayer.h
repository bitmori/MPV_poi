//
//  IONOpenGLLayer.h
//  mpv_poi
//
//  Created by Kirk Young on 1/21/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

// not in use right now
#import <Cocoa/Cocoa.h>
#include "includes/opengl_cb.h"

@interface IONOpenGLLayer : NSOpenGLLayer

@property (assign) mpv_opengl_cb_context * mpvOpenGLContext;

- (void)fillBlack;

@end
