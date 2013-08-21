//  losely based on:
//  PrioritySplitViewDelegate.m
//  ColumnSplitView
//  Created by Matt Gallagher on 2009/09/01.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//  ---------------------------------------------------
//  Copyleft 2013 Leo Kuznetsov. No rights reserved.

#import "WeightSplitViewDelegate.h"

#define kSplitSubviewsSizes @"SplitSubviewsSizes"

@interface WeightSplitViewDelegate() {
    NSMutableDictionary* _minSize; // int view index -> float minimum size
    NSMutableDictionary* _p2ix;  // float priority -> int view index
    NSSize _lastSeenSize;
}
@end

@implementation WeightSplitViewDelegate

- (void) setMinimumLength: (CGFloat) minLength forViewAtIndex: (NSInteger) ix {
    if (_minSize == null) {
        _minSize = [NSMutableDictionary dictionaryWithCapacity: 16];
    }
    _minSize[@(ix)] = @(minLength);
}

- (void) setPriority: (CGFloat) priorityIndex forViewAtIndex: (NSInteger) ix {
    if (_p2ix == null) {
        _p2ix = [NSMutableDictionary dictionaryWithCapacity: 16];
    }
    _p2ix[@(ix)] = @(priorityIndex);
}


- (void) splitViewDidResizeSubviews: (NSNotification*) n {
    [self saveSplitSubviewSizes: n.object];
}

- (CGFloat) splitView: (NSSplitView*) sv constrainMinCoordinate: (CGFloat) min ofSubviewAt: (NSInteger) ix {
    NSView* v = sv.subviews[ix];
    NSRect f = v.frame;
    return (sv.isVertical ? f.origin.x : f.origin.y) + [_minSize[@(ix)] floatValue];
}

- (CGFloat) splitView: (NSSplitView*) sv constrainMaxCoordinate: (CGFloat) proposedMax ofSubviewAt:(NSInteger) ix {
    NSView* growing = sv.subviews[ix];
    NSView *shrinking = sv.subviews[ix + 1];
    NSRect gf = growing.frame;
    NSRect sf = shrinking.frame;
    CGFloat coordinate = sv.isVertical ? gf.origin.x + gf.size.width : gf.origin.y + gf.size.height;
    CGFloat size = sv.isVertical ? sf.size.width : sf.size.height;
    return coordinate + (size - [_minSize[@(ix + 1)] floatValue]);
}

- (CGFloat) minSize: (NSNumber*) ix {
    return [_minSize[ix] floatValue];
}

- (CGFloat) splitView: (NSSplitView*) sv subsize: (NSInteger) ix {
    NSView* view = sv.subviews[ix];
    NSSize size = view.frame.size;
    return sv.isVertical ? size.width : size.height;
}

- (void) saveSplitSubviewSizes: (NSSplitView*) sv {
    NSMutableArray* sss = [NSMutableArray arrayWithCapacity: sv.subviews.count];
    int k = 0;
    for (NSView* v in sv.subviews) {
        sss[k++] = @(sv.isVertical ? v.frame.size.width : v.frame.size.height);
    }
    NSString* key = [NSString stringWithFormat: @"%@.%ld", kSplitSubviewsSizes, sv.subviews.count];
    [NSUserDefaults.standardUserDefaults  setObject: sss forKey: key];
}

- (void) initialLayout: (NSSplitView*) sv  {
    // 3 split subvies sizes won't make sense for 2 split subview
    NSString* key = [NSString stringWithFormat: @"%@.%ld", kSplitSubviewsSizes, sv.subviews.count];
    NSArray* sss = [NSUserDefaults.standardUserDefaults objectForKey: key];
    // it direction of a splitter has been changed from initial .nib layout we need to relayout all views.
    CGFloat total = 0;
    int i = 0;
    CGFloat sizes[sv.subviews.count];
    for (NSView* v in sv.subviews) {
        sizes[i] = sss != null && i < sss.count ?
                  [sss[i] floatValue] :
                  (sv.isVertical ? v.frame.size.width : v.frame.size.height);
        total += sizes[i];
        i++;
    }
    CGFloat divider = [sv dividerThickness];
    CGFloat splitterSize = (sv.isVertical ? sv.bounds.size.width : sv.bounds.size.height) - divider * (sv.subviews.count - 1);
    CGFloat offset = 0;
    i = 0;
    for (NSView* v in sv.subviews) {
        CGFloat s = splitterSize * sizes[i] / total;
        v.frame = sv.isVertical? NSMakeRect(offset, 0, s, sv.bounds.size.height) :
                                 NSMakeRect(0, offset, sv.bounds.size.width, s);
        offset += s + divider;
        NSLog(@"%@", NSStringFromRect(v.frame));
        i++;
    }
    NSLog(@"%f %@", offset - divider, NSStringFromRect(sv.bounds));
}

- (void) splitView: (NSSplitView*) sv resizeSubviewsWithOldSize: (NSSize) oldSize {
    if (_lastSeenSize.width == 0 && _lastSeenSize.height == 0) {
        [self initialLayout: sv];
    }
    _lastSeenSize = oldSize;
    CGFloat delta = sv.isVertical ? sv.bounds.size.width - oldSize.width : sv.bounds.size.height - oldSize.height;
    NSLog(@"delta=%f %@ old=%@", delta, NSStringFromSize(sv.bounds.size), NSStringFromSize(oldSize));
    NSArray* sorted = [_p2ix.allKeys sortedArrayUsingComparator: ^ NSComparisonResult(id o0, id o1) {
        NSNumber* v0 = _p2ix[o0];
        NSNumber* v1 = _p2ix[o1];
        // NSLog(@"compare(%@, %@)=%ld", v0, v1, [v1 compare: v0]);
        return [v1 compare: v0];
    }];
    // NSLog(@"sorted=%@", sorted);
    BOOL force = false;
    for (;;) {
        CGFloat sum = 0;   // sum of all the view "priorities"
        while (sum == 0) {
            for (NSNumber* priority in sorted) {
                CGFloat min = [self minSize: priority];
                CGFloat s = [self splitView: sv subsize: priority.integerValue];
                sum += delta > 0 || s > min || force ? [_p2ix[priority] floatValue] : 0;
            }
            force = force || sum == 0; // sticky
            NSLog(@"sum=%f force=%d", sum, force);
        }
        NSAssert1(sum > 0, @"sum=%f", sum);
        NSAssert2(sorted.count == sv.subviews.count, @"sorted.count=%ld sv.subviews.count=%ld", sorted.count, sv.subviews.count);
        CGFloat deltas[sorted.count];
        int j = 0;
        for (NSNumber* priority in sorted) {
            CGFloat min = [self minSize: priority];
            CGFloat s = [self splitView: sv subsize: priority.integerValue];
            deltas[j++] = delta > 0 || s > min || force ? [_p2ix[priority] floatValue] / sum : 0;
            NSLog(@"deltas[%d]=%f s=%f min=%f", j - 1, deltas[j - 1], s, min);
        }
        int k = 0;
        for (NSNumber* priority in sorted) {
            NSInteger ix = priority.integerValue;
            NSView* view = sv.subviews[ix];
            NSSize size = sv.bounds.size;
            CGFloat min = [self minSize: priority];
            CGFloat d = delta * deltas[k];
            NSLog(@"[%@] %@ d=%f delta=%f", priority, _p2ix[priority], d, delta);
            CGFloat s = [self splitView: sv subsize: priority.integerValue];
            if (d > 0 || s + d >= min || force) {
                delta -= d;
                s += d;
            } else if (d < 0) {
                delta += s - min;
                s = min;
            }
            if (sv.isVertical) {
                size.width = s;
            } else {
                size.height = s;
            }
            NSLog(@"[%@] %@=%@ d=%f delta=%f", priority, _p2ix[priority], NSStringFromSize(size), d, delta);
            view.frameSize = size;
            k++;
        }
        if (fabs(delta) < 0.5) {
            break; // even if fabs(delta) > 0.5
        }
    }
    NSAssert3(fabs(delta) < 0.5, @"Split view %p resized smaller than minimum %@ of %f",
              sv, sv.isVertical ? @"width" : @"height", sv.frame.size.width - delta);
    CGFloat offset = 0;
    CGFloat divider = [sv dividerThickness];
    for (NSView* v in sv.subviews) {
        NSSize fs = v.frame.size;
        v.frame = sv.isVertical ? NSMakeRect(offset, 0, fs.width, sv.bounds.size.height) :
                                  NSMakeRect(0, offset, sv.bounds.size.width, fs.height);
        offset += sv.isVertical ? fs.width + divider : fs.height + divider;
    }
    // last view may have a rounding 0.5 error and tends to accumulate - here is the fix for it:
    NSView* v = sv.subviews[sv.subviews.count - 1];
    NSSize fs = v.frame.size;
    if (sv.isVertical) {
        fs.width = sv.bounds.size.width - v.frame.origin.x;
    } else {
        fs.height = sv.bounds.size.height - v.frame.origin.y;
    }
    v.frameSize = fs;
}


@end

