//
//  UIAlertController+JQTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/7/23.
//

#import <UIKit/UIKit.h>
#import "JQTEventMeta.h"

@interface UIAlertController (JQTrack)

- (void)bfs_addAction:(UIAlertAction *)action eventMeta:(JQTEventMeta *)eventMeta;

@end
