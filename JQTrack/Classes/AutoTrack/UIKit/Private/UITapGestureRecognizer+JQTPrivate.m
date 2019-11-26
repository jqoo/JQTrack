//
//  UITapGestureRecognizer+JQTPrivate.m
//  JQTrack
//
//  Created by jqoo on 2019/7/10.
//

#import "UITapGestureRecognizer+JQTPrivate.h"
#import "UIView+JQTrack.h"

@implementation UITapGestureRecognizer (JQTPrivate)

+ (void)bfs_commitSwizzle {
    [self bfs_exchangeImplementationOfSelector:@selector(setState:)
                                  withSelector:@selector(bfs_setState:)];
}

- (void)bfs_setState:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateEnded) {
        [self.view bfs_trackEvent:JQTEventType_Click];
    }
    [self bfs_setState:state];
}

@end
