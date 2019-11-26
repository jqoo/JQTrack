//
//  UIAlertAction+JQTrack.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "UIAlertAction+JQTrack.h"
#import "JQTEventMeta+AutoTrack.h"

@implementation UIAlertAction (JQTrack)

JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_eventMeta, setBfs_eventMeta, RETAIN, JQTEventMeta *)

+ (void)bfs_commitSwizzle {
    [object_getClass([self class]) bfs_exchangeImplementationOfSelector:@selector(actionWithTitle:style:handler:)
                                                           withSelector:@selector(bfs_actionWithTitle:style:handler:)];
}

+ (instancetype)bfs_actionWithTitle:(nullable NSString *)title style:(UIAlertActionStyle)style handler:(void (^ __nullable)(UIAlertAction *action))handler {
    return [self bfs_actionWithTitle:title style:style handler:^(UIAlertAction *action) {
        [action.bfs_eventMeta trackForType:JQTEventType_Click sender:action];
        !handler ?: handler(action);
    }];
}

@end
