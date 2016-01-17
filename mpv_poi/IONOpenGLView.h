//
//  IONOpenGLView.h
//  mpv_poi
//
//  Created by Kirk Young on 1/17/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "includes/opengl_cb.h"

@interface IONOpenGLView : NSOpenGLView

@property mpv_opengl_cb_context *mpvGL;

- (instancetype)initWithFrame:(NSRect)frame;
- (void)drawRect;
- (void)fillBlack;

@end
