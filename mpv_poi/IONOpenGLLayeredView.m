//
//  IONOpenGLLayeredView.m
//  mpv_poi
//
//  Created by Kirk Young on 1/22/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "IONOpenGLLayeredView.h"
#import "IONOpenGLLayer.h"

@implementation IONOpenGLLayeredView

- (instancetype)init {
    self = [super init];
    [self setWantsLayer:YES];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (CALayer *)makeBackingLayer {
    IONOpenGLLayer * layer = [[IONOpenGLLayer alloc] init];

    [layer setNeedsDisplayOnBoundsChange:YES];
    [layer setAsynchronous:YES];
    
    return layer;
}

@end
