//
//  JQTExposeTracker.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <Foundation/Foundation.h>

@interface JQTExposeTracker : NSObject

// 开始定时检测曝光结点
- (void)start;

// 停止定时检测曝光结点
- (void)stop;

// 强制重新计算
- (void)fireExposeUpdating;

// 为正在曝光的结点发出曝光事件
- (void)trackAllExposeEvent;

// 放入曝光队列，将在下一次trackAllExposeEvent时发出曝光事件
+ (void)enqueueExposingView:(UIView *)view;

// 移除曝光队列
// reset: YES:清除记录
+ (void)dequeueExposingView:(UIView *)view reset:(BOOL)reset;

@end
