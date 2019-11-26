//
//  UIView+JQTPrivate.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "UIView+JQTPrivate.h"

@implementation UIView (JQTPrivate)

JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_originParentView, setBfs_originParentView, RETAIN, JQTWeakObjectWrapper *)
JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_penHelper, setBfs_penHelper, RETAIN, JQTPENHelper *)

- (void)bfs_addPENSubview:(UIView *)subview {
    if (!subview) {
        return;
    }
    JQTPENHelper *penHelper = self.bfs_penHelper;
    if (!penHelper) {
        penHelper = [[JQTPENHelper alloc] initWithView:self];
        self.bfs_penHelper = penHelper;
    }
    if (![penHelper hasPENSubview:subview]) {
        [penHelper addPENSubview:subview];
        [self.superview bfs_addPENSubview:self];
    }
}

- (void)bfs_removePENSubview:(UIView *)subview {
    if (!subview) {
        return;
    }
    JQTPENHelper *penHelper = self.bfs_penHelper;
    if (penHelper) {
        if ([penHelper hasPENSubview:subview]) {
            [penHelper removePENSubview:subview];
            
            if (![penHelper isPEN]) {
                [self.superview bfs_removePENSubview:self];
                // 如果不再试PEN，需要清理potential
                penHelper.potential = NO;
                penHelper.updated = NO;
            }
        }
    }
}

- (BOOL)bfs_isVisable {
    return !self.isHidden && self.alpha > 0;
}

- (void)bfs_markExposePotential {
    if (self.window == nil) {
        return;
    }
    JQTPENHelper *penHelper = self.bfs_penHelper;
    if (![penHelper isPEN]) {
        return;
    }
    penHelper.updated = YES;
    penHelper.potential = YES;

    UIView *parent = self.superview;
    while (parent) {
        JQTPENHelper *helper = parent.bfs_penHelper;
        if (!helper || helper.potential) {
            break;
        }
        helper.potential = YES;
        parent = parent.superview;
    }
}

#pragma mark - Swizzle

+ (void)bfs_commitSwizzle {
    [self bfs_exchangeImplementationOfSelector:@selector(layoutSubviews)
                                  withSelector:@selector(bfs_layoutSubviews)];
    [self bfs_exchangeImplementationOfSelector:@selector(didMoveToSuperview)
                                  withSelector:@selector(bfs_didMoveToSuperview)];
    [self bfs_exchangeImplementationOfSelector:@selector(didMoveToWindow)
                                  withSelector:@selector(bfs_didMoveToWindow)];
    [self bfs_exchangeImplementationOfSelector:NSSelectorFromString(@"dealloc")
                                  withSelector:@selector(bfs_dealloc)];
}

- (void)bfs_layoutSubviews {
    [self bfs_layoutSubviews];
    
    [self bfs_markExposePotential];
}

- (void)bfs_didMoveToSuperview {
    [self bfs_didMoveToSuperview];
    
    [self bfs_handleOnMovedToSuperview:self.superview];
}

- (void)bfs_handleOnMovedToSuperview:(UIView *)superview {
    JQTPENHelper *penHelper = self.bfs_penHelper;
    if ([penHelper isPEN]) {
        UIView *originParent = self.bfs_originParentView.object;
        [originParent bfs_removePENSubview:self];
        
        if (superview) {
            [penHelper installObserver];
            [superview bfs_addPENSubview:self];
            [self bfs_markExposePotential];
        }
        else {
            [penHelper uninstallObserver];
            [self bfs_loseExpose];
        }
    }
    self.bfs_originParentView = [JQTWeakObjectWrapper wrapperWithObject:superview];
}

- (void)bfs_loseExpose {
    JQTPENHelper *penHelper = self.bfs_penHelper;
    penHelper.potential = NO;
    penHelper.updated = NO;
    penHelper.exposed = NO;
    
    for (UIView *subview in penHelper.penSubViewTable) {
        [subview bfs_loseExpose];
    }
}

- (void)bfs_didMoveToWindow {
    [self bfs_didMoveToWindow];
    
    JQTPENHelper *penHelper = self.bfs_penHelper;
    if ([penHelper isPEN]) {
        if ([self window]) {
            [self bfs_markExposePotential];
        }
        else {
            penHelper.potential = NO;
            penHelper.updated = NO;
            penHelper.exposed = NO;
        }
    }
}

- (void)bfs_dealloc {
    [self.bfs_penHelper uninstallObserver];
    [self bfs_dealloc];
}

@end
