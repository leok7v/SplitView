//  FlatColorView.m
//  ColumnSplitView
//  Created by Matt Gallagher on 2009/09/01.
//  Copyright 2009 Matt Gallagher. All rights reserved.

#import "FlatColorView.h"

@implementation FlatColorView

@synthesize backgroundColor;

- (void) drawRect: (NSRect) r {
    if (self.backgroundColor != null) {
        [self.backgroundColor set];
        NSRectFill(r);
    }
}

@end
