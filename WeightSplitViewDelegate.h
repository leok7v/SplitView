//  based on:
//  PrioritySplitViewDelegate.h
//  ColumnSplitView
//  Created by Matt Gallagher on 2009/09/01.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//  ---------------------------------------------------
//  slightly modified
//  Copyleft 2013 Leo Kuznetsov. No rights reserved.

#import <Cocoa/Cocoa.h>

@interface WeightSplitViewDelegate : NSObject<NSSplitViewDelegate>

- (void) setMinimumLength: (CGFloat) minLength forViewAtIndex: (NSInteger) viewIndex;
- (void) setPriority: (CGFloat) priorityIndex forViewAtIndex: (NSInteger) viewIndex;
- (void) layout: (NSSplitView*) sv;
- (void) flip: (NSSplitView*) sv;

@end
