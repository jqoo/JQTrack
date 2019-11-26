//
//  UIAlertAction+JQTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <UIKit/UIKit.h>
#import "JQTAutoTrackItemProtocol.h"

@interface UIAlertAction (JQTrack) <JQTAutoTrackItemProtocol>

@property (nonatomic, strong) JQTEventMeta *bfs_eventMeta;

@end
