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

#define LEFT_VIEW_INDEX 0
#define LEFT_VIEW_PRIORITY 0.2
#define LEFT_VIEW_MINIMUM_WIDTH 100.0
#define MAIN_VIEW_INDEX 1
#define MAIN_VIEW_PRIORITY 0.5
#define MAIN_VIEW_MINIMUM_WIDTH 200.0
#define RIGHT_VIEW_INDEX 2
#define RIGHT_VIEW_PRIORITY 0.3
#define RIGHT_VIEW_MINIMUM_WIDTH 50.0

@implementation AppDelegate

- (void) applicationDidFinishLaunching: (NSNotification*) n {
    NSNumber* w = [NSUserDefaults.standardUserDefaults objectForKey: kWindowWidth];
    NSNumber* h = [NSUserDefaults.standardUserDefaults objectForKey: kWindowHeight];
    if (w != null && h != null) { // because in 10.8 everything changed about Window Autosave...
        NSWindow* wn = splitView.window;
        [wn setFrame: NSMakeRect(wn.frame.origin.x, wn.frame.origin.y, w.floatValue, h.floatValue) display: true];
    }
    splitView.window.restorable = true;
    splitView.vertical = true;
    splitViewDelegate = WeightSplitViewDelegate.new;
    [splitViewDelegate setPriority: LEFT_VIEW_PRIORITY forViewAtIndex: LEFT_VIEW_INDEX];
    [splitViewDelegate setPriority: MAIN_VIEW_PRIORITY forViewAtIndex: MAIN_VIEW_INDEX];
    [splitViewDelegate setPriority: RIGHT_VIEW_PRIORITY forViewAtIndex: RIGHT_VIEW_INDEX];
    [splitViewDelegate setMinimumLength: LEFT_VIEW_MINIMUM_WIDTH forViewAtIndex: LEFT_VIEW_INDEX];
    [splitViewDelegate setMinimumLength: MAIN_VIEW_MINIMUM_WIDTH forViewAtIndex: MAIN_VIEW_INDEX];
    [splitViewDelegate setMinimumLength: RIGHT_VIEW_MINIMUM_WIDTH forViewAtIndex: RIGHT_VIEW_INDEX];
    splitView.delegate = splitViewDelegate;
    [splitView.subviews[LEFT_VIEW_INDEX] setBackgroundColor: NSColor.whiteColor];
    [splitView.subviews[MAIN_VIEW_INDEX] setBackgroundColor: NSColor.blueColor];
    [splitView.subviews[RIGHT_VIEW_INDEX] setBackgroundColor: NSColor.redColor];
    [splitView.window makeKeyAndOrderFront: self];
}

- (void) applicationWillTerminate: (NSNotification*) n {
    [NSUserDefaults.standardUserDefaults  setObject: @(splitView.window.frame.size.width) forKey: kWindowWidth];
    [NSUserDefaults.standardUserDefaults  setObject: @(splitView.window.frame.size.height) forKey: kWindowHeight];
    splitView.delegate = null;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication*) app {
    return YES;
}

@end
