//  losely based on:
//  AppDelegate.m
//  ColumnSplitView
//  Created by Matt Gallagher on 2009/09/01.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//  ---------------------------------------------------
//  Copyright 2013 Leo Kuznetsov. No rights reserved.

#import "AppDelegate.h"
#import "WeightSplitViewDelegate.h"

#define kWindowWidth  @"Window.width"
#define kWindowHeight @"Window.height"
#define kOrientation  @"SplitView.isVertical"

#define LEFT_VIEW_INDEX 0
#define LEFT_VIEW_PRIORITY 0.2
#define LEFT_VIEW_MINIMUM_WIDTH 100.0
#define MAIN_VIEW_INDEX 1
#define MAIN_VIEW_PRIORITY 0.5
#define MAIN_VIEW_MINIMUM_WIDTH 200.0
#define RIGHT_VIEW_INDEX 2
#define RIGHT_VIEW_PRIORITY 0.3
#define RIGHT_VIEW_MINIMUM_WIDTH 50.0


@interface AppDelegate () {
    WeightSplitViewDelegate* d;
    __weak NSSplitView *_sv;
}

@property (weak) IBOutlet NSSplitView *sv;
@end


@implementation AppDelegate

- (IBAction) flip: (id) sender {
    [d flip: _sv];
}

- (void) applicationDidFinishLaunching: (NSNotification*) n {
    NSNumber* o = [NSUserDefaults.standardUserDefaults objectForKey: kOrientation];
    _sv.vertical = o != null ? o.boolValue : dispatch_time(DISPATCH_TIME_NOW, 0) % 2 == 0;
    NSNumber* w = [NSUserDefaults.standardUserDefaults objectForKey: kWindowWidth];
    NSNumber* h = [NSUserDefaults.standardUserDefaults objectForKey: kWindowHeight];
    if (w != null && h != null) { // because in 10.8 everything changed about Window Autosave...
        NSWindow* wn = _sv.window;
        [wn setFrame: NSMakeRect(wn.frame.origin.x, wn.frame.origin.y, w.floatValue, h.floatValue) display: true];
    }
    d = WeightSplitViewDelegate.new;
    [d layout: _sv];
    [d setPriority: LEFT_VIEW_PRIORITY forViewAtIndex: LEFT_VIEW_INDEX];
    [d setPriority: MAIN_VIEW_PRIORITY forViewAtIndex: MAIN_VIEW_INDEX];
    [d setPriority: RIGHT_VIEW_PRIORITY forViewAtIndex: RIGHT_VIEW_INDEX];
    [d setMinimumLength: LEFT_VIEW_MINIMUM_WIDTH forViewAtIndex: LEFT_VIEW_INDEX];
    [d setMinimumLength: MAIN_VIEW_MINIMUM_WIDTH forViewAtIndex: MAIN_VIEW_INDEX];
    [d setMinimumLength: RIGHT_VIEW_MINIMUM_WIDTH forViewAtIndex: RIGHT_VIEW_INDEX];
    _sv.delegate = d;
    [_sv.subviews[LEFT_VIEW_INDEX] setBackgroundColor: NSColor.whiteColor];
    [_sv.subviews[MAIN_VIEW_INDEX] setBackgroundColor: NSColor.blueColor];
    [_sv.subviews[RIGHT_VIEW_INDEX] setBackgroundColor: NSColor.redColor];
    [_sv.window makeKeyAndOrderFront: self];
}

- (void) applicationWillTerminate: (NSNotification*) n {
    [NSUserDefaults.standardUserDefaults  setObject: @(_sv.window.frame.size.width) forKey: kWindowWidth];
    [NSUserDefaults.standardUserDefaults  setObject: @(_sv.window.frame.size.height) forKey: kWindowHeight];
    [NSUserDefaults.standardUserDefaults  setObject: @(_sv.isVertical) forKey: kOrientation];
    _sv.delegate = null;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) app {
    return YES;
}

@end
