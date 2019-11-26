//
//  UIControl+JQTPrivate.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "UIControl+JQTPrivate.h"
#import "UIView+JQTrack.h"

@implementation UIControl (JQTPrivate)

+ (void)bfs_commitSwizzle {
    [self bfs_exchangeImplementationOfSelector:@selector(sendAction:to:forEvent:)
                                  withSelector:@selector(bfs_sendAction:to:forEvent:)];
    [self bfs_exchangeImplementationOfSelector:@selector(sendActionsForControlEvents:)
                                  withSelector:@selector(bfs_sendActionsForControlEvents:)];
}

- (void)bfs_sendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event {
    static NSTimeInterval timestamp;
    static __weak UIEvent *lastEvent;
    if (event && event.type == UIEventTypeTouches) {
        UITouch *touch = [[event allTouches] anyObject];
        if (touch.phase == UITouchPhaseEnded) {
            // tabbarButton同一个event会调多次
            if (lastEvent != event || timestamp != touch.timestamp) {
                [self bfs_trackEvent:JQTEventType_Click];
                timestamp = touch.timestamp;
            }
            lastEvent = event;
        }
    }
    [self bfs_sendAction:action to:target forEvent:event];
}

- (void)bfs_sendActionsForControlEvents:(UIControlEvents)controlEvents {
    if (controlEvents == UIControlEventValueChanged) {
        if ([self isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segment = (UISegmentedControl *)self;
            [self bfs_trackEvent:JQTEventType_Click forIndex:segment.selectedSegmentIndex];
        }
        else {
            [self bfs_trackEvent:JQTEventType_Click];
        }
    }
    [self bfs_sendActionsForControlEvents:controlEvents];
}

@end
