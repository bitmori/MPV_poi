//
//  MPPlayerViewController.m
//  mpv_poi
//
//  Created by Kirk Young on 1/13/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import "MPPlayerViewController.h"
#include "includes/client.h"

@interface MPPlayerViewController ()

@property (assign) BOOL isCancelled, isPlaying;
@property (strong) dispatch_queue_t queue;
@property (assign) mpv_handle* mpv_ctx;
@property (strong) NSView* playerContainerView;

- (void)readEvents;
- (void)handleEvent:(mpv_event*)event;
- (void)loadVideo;

@end

static void check_mpv_error(int status);
static void wakeup(void* _self);

@implementation MPPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
//    NSRect frame = [[[[self view] window] contentView] bounds];
//    self.playerContainerView = [[NSView alloc] initWithFrame:frame];
//    [self.playerContainerView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
//    [[self->w contentView] addSubview:self->wrapper];
//    [self->wrapper release];
    
    //[self loadVideo];
}

- (void)loadVideo
{
    NSArray* args = [NSProcessInfo processInfo].arguments;
    if (args.count < 2) {
        NSLog(@"Expected filename on command line");
        exit(1);
    }
    NSString* filename = args[1];
    self.queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.queue, ^{
        self.mpv_ctx = mpv_create();
        check_mpv_error(mpv_request_log_messages(self.mpv_ctx, "warn"));

        check_mpv_error(mpv_initialize(self.mpv_ctx));

        // Register to be woken up whenever mpv generates new events.
        mpv_set_wakeup_callback(self.mpv_ctx, wakeup, (__bridge void*)self);
        //        mpv_set_wakeup_callback(mpv_ctx, @selector(), self);
        if (self.mpv_ctx == NULL) {
            printf("failed creating context\n");
            exit(1);
        }
        //        check_mpv_error(mpv_initialize(mpv_ctx));

        const char* cmd[] = { "loadfile", filename.UTF8String, NULL };
        check_mpv_error(mpv_command(self.mpv_ctx, cmd));

        //        while (1) {
        //            mpv_event *event = mpv_wait_event(mpv_ctx, 0);
        //            if (event->event_id == MPV_EVENT_SHUTDOWN)
        //                break;
        //            printf("event: %s\n", mpv_event_name(event->event_id));
        //        }

        mpv_terminate_destroy(self.mpv_ctx);
    });
}

- (void)readEvents
{
    dispatch_async(self.queue, ^{
        while (self.mpv_ctx) {
            mpv_event* event = mpv_wait_event(self.mpv_ctx, 0);
            if (!event)
                break;
            if (event->event_id == MPV_EVENT_NONE)
                break;
            if (self.isCancelled)
                break;
            [self handleEvent:event];
        }
    });
}

- (void)handleEvent:(mpv_event*)event
{
    switch (event->event_id) {
    case MPV_EVENT_SHUTDOWN: {
        mpv_detach_destroy(self.mpv_ctx);
        self.mpv_ctx = NULL;
        NSLog(@"Stopping player");
        break;
    }

    case MPV_EVENT_LOG_MESSAGE: {
        struct mpv_event_log_message* msg = (struct mpv_event_log_message*)event->data;
        NSLog(@"[%s] %s: %s", msg->prefix, msg->level, msg->text);
        break;
    }

    case MPV_EVENT_VIDEO_RECONFIG: {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [PlayerControlView setHidden:NO];
        //            });
        NSLog(@"%@", @"[PlayerControlView setHidden:NO]");
        break;
    }

    case MPV_EVENT_START_FILE: {
        NSLog(@"%@", @"MPV_EVENT_START_FILE");
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstPlayed"] length] != 3){
        //                    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"FirstPlayed"];
        //                    [self.textTip setStringValue:NSLocalizedString(@"正在创建字体缓存", nil)];
        //                    [self.subtip setStringValue:NSLocalizedString(@"首次播放需要最多 2 分钟来建立缓存\n请不要关闭窗口", nil)];
        //                }else{
        //                    [self.textTip setStringValue:NSLocalizedString(@"正在缓冲", nil)];
        //                }
        //            });
        break;
    }

    case MPV_EVENT_PLAYBACK_RESTART: {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [self.loadingImage setAnimates:NO];
        //                [LoadingView setHidden:YES];
        //            });
        NSLog(@"%@", @"[LoadingView setHidden:YES]");
        self.isPlaying = YES;
        break;
    }

    case MPV_EVENT_END_FILE: {
        self.isPlaying = NO;
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [LoadingView setHidden:NO];
        //                [self.textTip setStringValue:NSLocalizedString(@"播放完成，关闭窗口继续", nil)];
        //                [self runAutoSwitch];
        //                [self.view.window performClose:self];
        //            });
        NSLog(@"%@", @"播放完成，关闭窗口继续");
        break;
    }

    case MPV_EVENT_PAUSE: {
        break;
    }
    case MPV_EVENT_UNPAUSE: {
        self.isPlaying = YES;
        break;
    }

    default:
        NSLog(@"Player Event: %s", mpv_event_name(event->event_id));
    }
}

static void wakeup(void* ego)
{
    if (ego == NULL) {
        return;
    }

    MPPlayerViewController* this = (__bridge MPPlayerViewController*)ego;

    if (this.isCancelled) {
        return;
    }

    [this readEvents];
}


static void check_mpv_error(int status)
{
    if (status < 0) {
        printf("mpv API error: %s\n", mpv_error_string(status));
        exit(1);
    }
}

@end
