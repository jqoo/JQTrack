//
//  UIAlertController+JQTrack.m
//  JQTrack
//
//  Created by jqoo on 2019/7/23.
//

#import "UIAlertController+JQTrack.h"
#import "UIView+JQTrack.h"
#import "UIView+JQTPrivate.h"
#import "UIAlertAction+JQTrack.h"

@implementation UIAlertController (JQTrack)

+ (void)bfs_commitSwizzle {
    [self bfs_exchangeImplementationOfSelector:@selector(viewDidAppear:)
                                  withSelector:@selector(bfs_viewDidAppear:)];
    [self bfs_exchangeImplementationOfSelector:@selector(viewDidDisappear:)
                                  withSelector:@selector(bfs_viewDidDisappear:)];
}

// alert比较特别，不会主动调用didMoveToSuperview，因此只能这样处理
- (void)bfs_viewDidAppear:(BOOL)animated {
    [self bfs_viewDidAppear:animated];
    
    [self.view bfs_handleOnMovedToSuperview:self.view.superview];
    
    __weak typeof(self) weakSelf = self;
    [self.actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.bfs_eventMeta trackForType:JQTEventType_Appear sender:weakSelf];
    }];
}

- (void)bfs_viewDidDisappear:(BOOL)animated {
    [self bfs_viewDidDisappear:animated];
    
    [self.view bfs_handleOnMovedToSuperview:nil];
}

- (void)bfs_addAction:(UIAlertAction *)action eventMeta:(JQTEventMeta *)eventMeta {
    action.bfs_eventMeta = eventMeta;
    [self addAction:action];
}

@end
