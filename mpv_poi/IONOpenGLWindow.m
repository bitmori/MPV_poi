//
//  IONOpenGLWindow.m
//  mpv_poi
//
//  Created by Kirk Young on 1/17/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "IONOpenGLWindow.h"


@implementation IONOpenGLWindow

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setWantsLayer:YES];
}

- (BOOL)canBecomeMainWindow { return YES; }
- (BOOL)canBecomeKeyWindow { return YES; }

- (void)initOGLView {
    NSRect bounds = [[self contentView] bounds];
    // window coordinate origin is bottom left
    NSRect glFrame = NSMakeRect(bounds.origin.x, bounds.origin.y + 20, bounds.size.width, bounds.size.height - 30);
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
    NSRect controllerBounds = NSMakeRect(bounds.origin.x, bounds.origin.y + 30, 440, 40);
    [self setupControllerView:controllerBounds];
    
}

- (void) setupControllerView:(NSRect)frame {
    self.controllerView = [[IONPlayerControlView alloc] initWithFrame:frame];
    
    [self.contentView addSubview:self.controllerView positioned:NSWindowAbove relativeTo:nil];
    [self.controllerView setAlphaValue:1];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.controllerView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.contentView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[_controllerView(==440)]-(>=29)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_controllerView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=40)-[_controllerView(==40)]-40-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_controllerView)]];
    
    [_controllerView.playPauseButton setTarget:self];
    //[_controllerView.playPauseButton setAction:@selector(playPauseToggle:)];
    [_controllerView.playPauseButton setEnabled:NO];
    
    [_controllerView.timeSlider setTarget:self];
    //[_controllerView.timeSlider setAction:@selector(scrubberChanged:)];
    [_controllerView.timeSlider setEnabled:NO];
}

- (IBAction)togglePause:(id)sender {
    NSLog(@"toggle pause");
}

@end
