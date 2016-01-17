//
//  IONPlayerControlView.h
//  mpv_poi
//
//  Created by Kirk Young on 1/16/16.
//  Copyright © 2016 Kirk Young. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IONPlayerControlView : NSView

@property (strong) NSButton *playPauseButton;
@property (strong) NSSlider *timeSlider;
@property (strong) NSTextField *timeLabel;

- (void)setPlaying:(BOOL)flag;
@end
