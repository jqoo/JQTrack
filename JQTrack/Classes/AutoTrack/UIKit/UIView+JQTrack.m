//
//  UIView+JQTrack.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "UIView+JQTrack.h"
#import "UIView+JQTPrivate.h"

@implementation UIView (JQTrack)

- (JQTEventMeta *)bfs_eventMeta {
    return self.bfs_penHelper.eventMeta;
}

- (void)setBfs_eventMeta:(JQTEventMeta *)eventMeta {
    JQTPENHelper *penHelper = self.bfs_penHelper;
    if (!penHelper) {
        if (!eventMeta) {
            return;
        }
        penHelper = [[JQTPENHelper alloc] initWithView:self];
        self.bfs_penHelper = penHelper;
    }
    UIView *superview = [self superview];
    if (superview) {
        BOOL isPENBefore = [penHelper isPEN];
        penHelper.eventMeta = eventMeta;
        BOOL isPENAfter = [penHelper isPEN];
        if (!isPENBefore && isPENAfter) {
            [superview bfs_addPENSubview:self];
        }
        else if (isPENBefore && !isPENAfter) {
            [superview bfs_removePENSubview:self];
        }
    }
    else {
        penHelper.eventMeta = eventMeta;
    }
}

- (void)bfs_trackEvent:(JQTEventType)eventType {
    [self.bfs_eventMeta trackForType:eventType sender:self];
}

- (void)bfs_trackEvent:(JQTEventType)eventType forIndex:(NSInteger)index {
    [self.bfs_eventMeta trackForType:eventType sender:self index:index];
}

@end
