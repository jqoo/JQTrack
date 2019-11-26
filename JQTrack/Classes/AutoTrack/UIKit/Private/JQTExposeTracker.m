//
//  JQTExposeTracker.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "JQTExposeTracker.h"
#import "UIView+JQTPrivate.h"

static const int kFramesPerSecond = 2;

// 定时器检查的时间间隔之间，产生的expose变化
// 变化增量
static NSHashTable<UIView *> *_exposedViewSet;
// 变化减量
static NSHashTable<UIView *> *_losingExposeViewSet;

@implementation JQTExposeTracker
{
    CADisplayLink *_displayLink;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink)];
        if (@available(iOS 10.0, *)) {
            _displayLink.preferredFramesPerSecond = kFramesPerSecond;
        }
        else {
            _displayLink.frameInterval = kFramesPerSecond;
        }
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)start {
    _displayLink.paused = NO;
}

- (void)stop {
    _displayLink.paused = YES;
}

- (void)handleDisplayLink {
    NSArray<UIWindow *> *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        [self handlePENView:window inParentBounds:[UIScreen mainScreen].bounds updated:NO];
    }
    [self trackAllExposeEvent];
}

static inline CGRect computeVisibaleArea(UIView *view, CGRect bounds) {
    return CGRectIntersection(view.frame, bounds);
}

- (void)handlePENView:(UIView *)view inParentBounds:(CGRect)parentBounds updated:(BOOL)updated {
    JQTPENHelper *penHelper = view.bfs_penHelper;
    if (!updated && !penHelper.potential) {
        return;
    }
    updated = updated || penHelper.updated;
    BOOL exposed = NO;
    CGRect visibleArea = CGRectZero;
    if ([view bfs_isVisable]) {
        // 在父视图中的可见区域
        visibleArea = computeVisibaleArea(view, parentBounds);
        // 转换到本视图的坐标系内
        visibleArea = CGRectOffset(visibleArea, -view.frame.origin.x, -view.frame.origin.y);
        visibleArea = CGRectOffset(visibleArea, view.bounds.origin.x, view.bounds.origin.y);
        // visibleArea = CGRectIntersection(visibleArea, view.bounds);
        exposed = !CGRectIsNull(visibleArea) && !CGRectIsEmpty(visibleArea);
    }
    if (exposed) {
        penHelper.potential = NO;
        penHelper.updated = NO;
        penHelper.exposed = exposed;
        
        for (UIView *subview in penHelper.penSubViewTable) {
            [self handlePENView:subview inParentBounds:visibleArea updated:updated];
        }
    }
    else {
        [self loseExposeUnderView:view];
    }
}

- (void)loseExposeUnderView:(UIView *)view {
    JQTPENHelper *penHelper = view.bfs_penHelper;
    penHelper.potential = NO;
    penHelper.updated = NO;
    penHelper.exposed = NO;
    
    for (UIView *subview in penHelper.penSubViewTable) {
        [self loseExposeUnderView:subview];
    }
}

- (void)fireExposeUpdating {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        [window.bfs_penHelper setPotential:YES];
    }
}

- (void)trackAllExposeEvent {
    if (_exposedViewSet.count > 0) {
        NSMutableArray<JQTEventMeta *> *events = [NSMutableArray arrayWithCapacity:_exposedViewSet.count];
        for (UIView * _Nonnull obj in _exposedViewSet) {
            JQTEventMeta *event = obj.bfs_eventMeta;
            if (event) {
                [events addObject:event];
            }
        }
        if (events.count > 0) {
            [JQTEventMeta trackEvents:events forType:JQTEventType_Appear];
        }
        [_exposedViewSet removeAllObjects];
    }
    [_losingExposeViewSet removeAllObjects];
}

+ (void)enqueueExposingView:(UIView *)view {
    if ([_losingExposeViewSet containsObject:view]) {
        [_losingExposeViewSet removeObject:view];
    }
    else {
        if (!_exposedViewSet) {
            _exposedViewSet = [NSHashTable weakObjectsHashTable];
        }
        [_exposedViewSet addObject:view];
    }
}

+ (void)dequeueExposingView:(UIView *)view reset:(BOOL)reset {
    if ([_exposedViewSet containsObject:view]) {
        [_exposedViewSet removeObject:view];
    }
    else {
        if (reset) {
            [_losingExposeViewSet removeObject:view];
        }
        else {
            if (!_losingExposeViewSet) {
                _losingExposeViewSet = [NSHashTable weakObjectsHashTable];
            }
            [_losingExposeViewSet addObject:view];
        }
    }
}

@end
