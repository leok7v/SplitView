//  AppDelegate.h
//  ColumnSplitView
//  Created by Matt Gallagher on 2009/09/01.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WeightSplitViewDelegate;

@interface AppDelegate : NSObject {
    IBOutlet NSSplitView* splitView;
    WeightSplitViewDelegate* splitViewDelegate;
//  IBOutlet NSWindow *mainWindow; // this is unnecessary because splitView.window is good enough (LK)
}

@end
