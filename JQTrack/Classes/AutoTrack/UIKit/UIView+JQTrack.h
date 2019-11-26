//
//  UIView+JQTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <UIKit/UIKit.h>
#import "JQTEventMeta+AutoTrack.h"
#import "JQTAutoTrackItemProtocol.h"

@interface UIView (JQTrack) <JQTAutoTrackItemProtocol>

@property (nonatomic, strong) JQTEventMeta *bfs_eventMeta;

- (void)bfs_trackEvent:(JQTEventType)eventType;

// 自增1
- (void)bfs_trackEvent:(JQTEventType)eventType forIndex:(NSInteger)index;

@end
