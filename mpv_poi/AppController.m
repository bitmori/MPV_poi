//
//  AppController.m
//  mpv_poi
//
//  Created by Kirk Young on 1/14/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "AppController.h"
#import "IONPlayerControlView.h"

#include "includes/client.h"
#include "includes/opengl_cb.h"

@interface AppController()
{
    NSView * wrapper;
}

@property (assign) mpv_handle * mpv;
@property (strong) dispatch_queue_t queue;

@property (strong) IONPlayerControlView * controllerView;

@property (copy) NSURL * mediaURL;


@end

@implementation AppController

- (void) createPlayerView {
    NSString * filename = @"/Users/Kirk/Movies/Wanderers.mp4";
    self.queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.queue, ^{
        
        self.mpv = mpv_create();
        if (!self.mpv) {
            printf("failed creating context\n");
            exit(1);
        }
        
//        int64_t wid = (intptr_t) self.playerView;
        int64_t wid = (intptr_t) self->wrapper;
        
        check_error(mpv_set_option(self.mpv, "wid", MPV_FORMAT_INT64, &wid));
        
        // Maybe set some options here, like default key bindings.
        // NOTE: Interaction with the window seems to be broken for now.
        check_error(mpv_set_option_string(self.mpv, "input-default-bindings", "yes"));
        
        // for testing!
        check_error(mpv_set_option_string(self.mpv, "input-media-keys", "yes"));
        check_error(mpv_set_option_string(self.mpv, "input-cursor", "no"));
        check_error(mpv_set_option_string(self.mpv, "input-vo-keyboard", "yes"));
        
        // request important errors
        check_error(mpv_request_log_messages(self.mpv, "warn"));
        
        check_error(mpv_initialize(self.mpv));
        
        // Register to be woken up whenever mpv generates new events.
        mpv_set_wakeup_callback(self.mpv, wakeup, (__bridge void *) self);
        
        // Load the indicated file
        const char *cmd[] = {"loadfile", [filename UTF8String], NULL};
        check_error(mpv_command(self.mpv, cmd));

/*
        [[self.playerController view] removeFromSuperview];
        [self->wrapper addSubview:[self.playerController view] positioned:NSWindowAbove relativeTo:nil];
        
        CGSize wsize = [self.playerView bounds].size;
        NSRect frame2 = NSMakeRect(0, wsize.height-80, wsize.width, 80);
        [[self.playerController view] setFrame:frame2];*/

    });
}

- (void) awakeFromNib{
    NSRect frame = [[self.appWindow contentView] bounds];
    self->wrapper = [[NSView alloc] initWithFrame:frame];
    [self->wrapper setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
//    [[self.appWindow contentView] addSubview:self.playerView];
    [self.playerView addSubview:self->wrapper];
//    [self->wrapper release];
//    [self.playerView setFrame:frame];
//    [self.playerView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
//    NSLog(@"%@", @"awake from nib");
    [self createPlayerView];
    
    self.controllerView = [[IONPlayerControlView alloc] initWithFrame:NSMakeRect(0, 0, 440, 40)];

    [self.playerView addSubview:self.controllerView positioned:NSWindowAbove relativeTo:nil];
    [self.controllerView setAlphaValue:1];
    
    [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:self.controllerView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.playerView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0]];
    [self.playerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[_controllerView(==440)]-(>=29)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_controllerView)]];
    [self.playerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=40)-[_controllerView(==40)]-40-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_controllerView)]];
    
    [_controllerView.playPauseButton setTarget:self];
    [_controllerView.playPauseButton setAction:@selector(playPauseToggle:)];
    [_controllerView.playPauseButton setEnabled:NO];
    
    [_controllerView.timeSlider setTarget:self];
    [_controllerView.timeSlider setAction:@selector(scrubberChanged:)];
    [_controllerView.timeSlider setEnabled:NO];
}

- (void) handleEvent:(mpv_event *)event
{
    switch (event->event_id) {
        case MPV_EVENT_SHUTDOWN: {
            mpv_detach_destroy(self.mpv);
            self.mpv = NULL;
            printf("event: shutdown\n");
            break;
        }
            
        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            printf("[%s] %s: %s", msg->prefix, msg->level, msg->text);
        }
            
//        case MPV_EVENT_VIDEO_RECONFIG: {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSArray *subviews = [self.playerView subviews];
//                if ([subviews count] > 0) {
//                    // mpv's events view
//                    NSView *eview = [self.playerView subviews][0];
//                    [self makeFirstResponder:eview];
//                }
//            });
//        }
            
        default:
            printf("event: %s\n", mpv_event_name(event->event_id));
    }
}

- (void) readEvents
{
    dispatch_async(self.queue, ^{
        while (self.mpv) {
            mpv_event *event = mpv_wait_event(self.mpv, 0);
            if (event->event_id == MPV_EVENT_NONE)
                break;
            [self handleEvent:event];
        }
    });
}

// Ostensibly, mpv's window would be hooked up to this.
- (BOOL) windowShouldClose:(id)sender
{
    return NO;
}

- (void) ExecuteMPVCommand:(NSString*) cmd {
    if (self.mpv) {
        const char * args[] = {[cmd UTF8String], NULL};
        mpv_command(self.mpv, args);
    }
}

//
//- (void) mpv_stop
//{
//    if (mpv) {
//        const char *args[] = {"stop", NULL};
//        mpv_command(mpv, args);
//    }
//}
//
//- (void) mpv_quit
//{
//    if (mpv) {
//        const char *args[] = {"quit", NULL};
//        mpv_command(mpv, args);
//    }
//}

- (IBAction)revealMessage:(id)sender {
    NSLog(@"%@", @"YOU ARE AWESOME!");
}



- (IBAction)controlMenuAction:(id)sender {
    NSMenuItem* item = (NSMenuItem *)sender;
    switch ([item tag]) {
        case kPlayTag: {
            if(self.queue && self.mpv){
                dispatch_async(self.queue, ^{
                    if(strcmp(mpv_get_property_string(self.mpv,"pause"),"no")){
                        mpv_set_property_string(self.mpv,"pause","no");
                    }else{
                        mpv_set_property_string(self.mpv,"pause","yes");
                    }
                });
            }
            
//            if (self.mpv) {
//                const char * args[] = {"pause", "yes",  NULL};
//                mpv_command(self.mpv, args);
//            }
        }
            break;
        case kPauseTag: {
//            if (self.mpv) {
//                const char * args[] = {"pause", "yes",  NULL};
//                mpv_command(self.mpv, args);
//            }
        }
            break;
        case kStopTag: {
            [self ExecuteMPVCommand:@"stop"];
        }
            break;
        default:
            break;
    }
    [item tag];
}

- (IBAction)openFile:(id)sender {
    NSOpenPanel * op = [NSOpenPanel openPanel];
    [op runModal];
    self.mediaURL = [op URLs][0];
    // Load the indicated file
    const char *cmd[] = {"loadfile", [[self.mediaURL absoluteString] UTF8String], NULL};
    check_error(mpv_command(self.mpv, cmd));
    
}

- (void)playPauseToggle:(id)sender
{
//    if ([self.player rate] != 1.f) {
//        if (self.currentTime >= self.duration) {
//            self.currentTime = 0.0f;
//        }
//        [self.player play];
//    } else {
//        [self.player pause];
//    }
    NSLog(@"play/pause");
}


- (void)scrubberChanged:(NSSlider *)sender
{
//    if ([self.player rate] >= 1.0f) {
//        [self.player pause];
//    }
//    [self.player seekToTime:CMTimeMakeWithSeconds([sender doubleValue], NSEC_PER_SEC)];
    NSLog(@"%f", [sender doubleValue]);
}


static inline void check_error(int status) {
    if (status < 0) {
        printf("mpv API error: %s\n", mpv_error_string(status));
        exit(1);
    }
}

static void wakeup(void *context) {
    AppController *ego = (__bridge AppController *) context;
    [ego readEvents];
}


@end
