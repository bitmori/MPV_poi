//
//  AppController.m
//  mpv_poi
//
//  Created by Kirk Young on 1/14/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "AppController.h"
#include "includes/client.h"

static inline void check_error(int status)
{
    if (status < 0) {
        printf("mpv API error: %s\n", mpv_error_string(status));
        exit(1);
    }
}

@interface AppController()

@property (assign) mpv_handle * mpv;
@property (strong) dispatch_queue_t queue;

@end

@implementation AppController

- (void) awakeFromNib{
//    NSLog(@"%@", @"awake from nib");
    NSString * filename = @"/Users/Kirk/Movies/Wanderers.mp4";
    self.queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.queue, ^{
        
        self.mpv = mpv_create();
        if (!self.mpv) {
            printf("failed creating context\n");
            exit(1);
        }
        
        int64_t wid = (intptr_t) self.playerView;
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
    });
//    [[self.firstViewController view] removeFromSuperview];
//    [self.playerView addSubview:[self.firstViewController view]];
//    [[self.firstViewController view] setFrame:[self.playerView bounds]];
    //self.secretMessage = [NSString stringWithFormat:@"I SAY: %@", @"YOU ARE AWESOME!"];
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

static void wakeup(void *context) {
    AppController *ego = (__bridge AppController *) context;
    [ego readEvents];
}

// Ostensibly, mpv's window would be hooked up to this.
- (BOOL) windowShouldClose:(id)sender
{
    return NO;
}

- (void) mpv_exec_command:(NSString*) cmd {
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



@end
