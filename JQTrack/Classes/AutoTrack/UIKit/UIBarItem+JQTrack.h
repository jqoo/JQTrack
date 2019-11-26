//
//  UIBarItem+JQTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/7/26.
//

#import <UIKit/UIKit.h>
#import "JQTAutoTrackItemProtocol.h"

@interface UIBarItem (JQTrack) <JQTAutoTrackItemProtocol>

@property (nonatomic, strong) JQTEventMeta *bfs_eventMeta;

@end

@interface UIBarButtonItem (JQTrack)

@end
