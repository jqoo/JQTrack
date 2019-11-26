//
//  JQTPENHelper.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "JQTPENHelper.h"
#import "UIView+JQTPrivate.h"
#import "JQTExposeTracker.h"

static BOOL _viewDebug;

typedef struct {
    const char *keyPath;
    void (*action)(JQTPENHelper *penHelper);
} _JQTPENKVOInfo;

@interface JQTPENHelper ()
{
    struct _JQTPENFlags {
        unsigned int updated:1;
        unsigned int potential:1;
        unsigned int observing:1;
        unsigned int observerInstalled:1;
        unsigned int exposed:1;
    } _penFlags;
}

@property (nonatomic, strong) NSHashTable<UIView *> *penSubViewTable;
@property (nonatomic, weak) CALayer *viewLayer;

@end

@implementation JQTPENHelper

@dynamic updated;
@dynamic potential;
@dynamic exposed;

- (void)dealloc {
    if (_penFlags.observerInstalled) {
        [self uninstallObserver];
    }
}

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        _view = view;
        self.viewLayer = view.layer;
    }
    return self;
}

- (BOOL)updated {
    return _penFlags.updated;
}

- (void)setUpdated:(BOOL)updated {
    _penFlags.updated = updated ? 1:0;
    
    JQTDebugBlockIf(_viewDebug, {
        if (updated) {
            self.view.layer.borderWidth = 1;
            self.view.layer.borderColor = [UIColor redColor].CGColor;
        }
    })
}

- (BOOL)potential {
    return _penFlags.potential;
}

- (void)setPotential:(BOOL)potential {
    _penFlags.potential = potential ? 1:0;
    
    JQTDebugBlockIf(_viewDebug, {
        if (potential) {
            self.view.layer.borderWidth = 1;
            self.view.layer.borderColor = [UIColor blueColor].CGColor;
        }
    })
}

- (BOOL)exposed {
    return _penFlags.exposed;
}

- (void)setExposed:(BOOL)exposed {
    if (_eventMeta) {
        if (!_penFlags.exposed && exposed) {
            [JQTExposeTracker enqueueExposingView:self.view];
        }
        else if (_penFlags.exposed && !exposed) {
            [JQTExposeTracker dequeueExposingView:self.view reset:NO];
        }
    }
    JQTDebugBlockIf(_viewDebug, {
        if (exposed) {
            self.view.layer.borderWidth = 1;
            self.view.layer.borderColor = [UIColor greenColor].CGColor;
        }
        else {
            self.view.layer.borderWidth = 1;
            self.view.layer.borderColor = [UIColor grayColor].CGColor;
        }
    })
    _penFlags.exposed = exposed ? 1:0;
}

- (void)setEventMeta:(JQTEventMeta *)eventMeta {
    NSString *oldId = _eventMeta.eventId;
    NSString *newId = eventMeta.eventId;
    
    _eventMeta = eventMeta;
    [self updateObserveState];
    
    if (oldId == newId || newId == nil || [oldId isEqualToString:newId]) {
        return;
    }
    // 重置
    // 如果不重置，若之前处于曝光状态，对于新的eventId，则一直认为处于曝光状态，将不会track新的eventId
    BOOL exposedBefore = self.exposed;
    self.exposed = NO;
    [JQTExposeTracker dequeueExposingView:self.view reset:YES];
    if (exposedBefore) {
        [self.view bfs_markExposePotential];
    }
}

- (BOOL)hasPENSubview:(UIView *)subview {
    return [_penSubViewTable containsObject:subview];
}

- (void)addPENSubview:(UIView *)subview {
    if (!_penSubViewTable) {
        _penSubViewTable = [NSHashTable weakObjectsHashTable];
    }
    [_penSubViewTable addObject:subview];
    
    [self updateObserveState];
}

- (void)removePENSubview:(UIView *)subview {
    [_penSubViewTable removeObject:subview];
    
    [self updateObserveState];
}

- (BOOL)hasPEN {
    return [_penSubViewTable count] > 0;
}

- (BOOL)isPEN {
    return self.eventMeta || [self hasPEN];
}

- (void)updateObserveState {
    _penFlags.observing = [self isPEN] ? 1:0;
}

static void checkVisable(JQTPENHelper *penHelper) {
    UIView *view = penHelper.view;
    BOOL visable = [view bfs_isVisable];
    if (penHelper.exposed != visable) {
        [view bfs_markExposePotential];
    }
}

static void checkLayout(JQTPENHelper *penHelper) {
    [penHelper.view bfs_markExposePotential];
}

static const _JQTPENKVOInfo g_viewKVOInfos[] = {
    {"hidden",         checkVisable},
    {"frame",           checkLayout},
    {"bounds",          checkLayout},
    {"center",          checkLayout},
    {"transform",       checkLayout},
    {NULL,NULL}
};

static const _JQTPENKVOInfo g_layerKVOInfos[] = {
    // "hidden"也会变更，但不会触发hidden的KVO
    {"hidden",   checkVisable},
    // "alpha" 也会引发其变更
    {"opacity",  checkVisable},
    // "layer.bounds",   // layer.bounds   --> frame/bounds
    // "layer.position", // layer.position --> frame
    {"frame",     checkLayout},
    {"transform", checkLayout},
    {NULL,NULL}
};

- (void)installObserver {
    if (_penFlags.observerInstalled) {
        return;
    }
    for (const _JQTPENKVOInfo *p = g_viewKVOInfos; p->keyPath; p++) {
        [_view addObserver:self forKeyPath:@(p->keyPath) options:NSKeyValueObservingOptionNew context:(void *)p];
    }
    for (const _JQTPENKVOInfo *p = g_layerKVOInfos; p->keyPath; p++) {
        [_viewLayer addObserver:self forKeyPath:@(p->keyPath) options:NSKeyValueObservingOptionNew context:(void *)p];
    }
    _penFlags.observerInstalled = 1;
}

- (void)uninstallObserver {
    if (!_penFlags.observerInstalled) {
        return;
    }
    for (const _JQTPENKVOInfo *p = g_viewKVOInfos; p->keyPath; p++) {
        [_view removeObserver:self forKeyPath:@(p->keyPath)];
    }
    for (const _JQTPENKVOInfo *p = g_layerKVOInfos; p->keyPath; p++) {
        [_viewLayer removeObserver:self forKeyPath:@(p->keyPath)];
    }
    _penFlags.observerInstalled = 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (!_penFlags.observing || !context) {
        return;
    }
    _JQTPENKVOInfo *p = context;
    if (p->action) {
        p->action(self);
    }
}

+ (void)enableViewDebug:(BOOL)enable {
    _viewDebug = enable;
}

@end
