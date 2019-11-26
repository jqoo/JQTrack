//
//  UIView+JQTPrivate.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <UIKit/UIKit.h>
#import "JQTWeakObjectWrapper.h"
#import "JQTPENHelper.h"
#import "UIView+JQTrack.h"

@interface UIView (JQTPrivate)

@property (nonatomic, strong) JQTWeakObjectWrapper *bfs_originParentView;
@property (nonatomic, strong) JQTPENHelper *bfs_penHelper;

- (void)bfs_addPENSubview:(UIView *)subview;
- (void)bfs_removePENSubview:(UIView *)subview;

- (BOOL)bfs_isVisable;

- (void)bfs_markExposePotential;
- (void)bfs_handleOnMovedToSuperview:(UIView *)superview;

@end
