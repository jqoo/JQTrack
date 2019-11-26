//
//  UIViewController+JQTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/1/4.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JQTrack)

@property (nonatomic, copy) NSString *bfs_pageId;      // 当前页面的埋点id
@property (nonatomic, copy) NSString *bfs_url;         // 当前页url或类名
@property (nonatomic, copy) NSString *bfs_refPage;     // 前一个页面的pageid或url、类名，aps、mmc
@property (nonatomic, copy) NSString *bfs_refSpm;      // 触发源spm
@property (nonatomic, copy) NSString *bfs_scm;         // 触发源的scm值
@property (nonatomic, copy) NSDictionary *bfs_attributes;  // 页面属性

- (NSString *)bfs_refererForNextPage;

@end
