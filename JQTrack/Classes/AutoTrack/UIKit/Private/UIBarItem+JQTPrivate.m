//
//  UIBarItem+JQTPrivate.m
//  JQTrack
//
//  Created by jqoo on 2019/7/26.
//

#import "UIBarItem+JQTPrivate.h"
#import "UIBarItem+JQTrack.h"
#import "UIView+JQTrack.h"

@implementation UIBarItem (JQTPrivate)

+ (void)bfs_commitSwizzle {
    [UITabBarItem bfs_exchangeImplementationOfSelector:@selector(setView:)
                                          withSelector:@selector(bfs_setView:)];
    [UIBarButtonItem bfs_exchangeImplementationOfSelector:@selector(setView:)
                                             withSelector:@selector(bfs_setView:)];
}

- (UIView *)bfs_view {
    // UIBarItem 本身没有 view 属性，只有子类 UIBarButtonItem 和 UITabBarItem 才有
    if ([self respondsToSelector:@selector(view)]) {
        return [self valueForKey:@"view"];
    }
    return nil;
}

- (void)bfs_setView:(UIView *)view {
    // will never be called
}

- (void)bfs_updateEventMeta {
    self.bfs_view.bfs_eventMeta = self.bfs_eventMeta;
}

@end

@implementation UITabBarItem (JQTPrivate)

- (void)setBfs_eventMeta:(JQTEventMeta *)eventMeta {
    [super setBfs_eventMeta:eventMeta];
    [self bfs_updateEventMeta];
}

- (void)bfs_setView:(UIView *)view {
    [self bfs_setView:view];
    [self bfs_updateEventMeta];
}

@end

@implementation UIBarButtonItem (JQTPrivate)

- (void)setBfs_eventMeta:(JQTEventMeta *)eventMeta {
    [super setBfs_eventMeta:eventMeta];
    [self bfs_updateEventMeta];
}

- (void)bfs_setView:(UIView *)view {
    [self bfs_setView:view];
    [self bfs_updateEventMeta];
}

@end
