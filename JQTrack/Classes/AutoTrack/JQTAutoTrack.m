//
//  JQTAutoTrack.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "JQTAutoTrack.h"
#import "NSObject+JQTrack.h"
#import "JQTExposeTracker.h"
#import "JQTPENHelper.h"
#import "UIView+JQTrack.h"

static JQTExposeTracker *_tracker;
static id<JQTAutoTrackDelegate> _delegate;

@implementation JQTAutoTrack

+ (void)load {
    [@[
       [UIView class],
       [UIControl class],
       [UIAlertAction class],
       [UITableView class],
       [UICollectionView class],
       [UIBarItem class],
       [UITapGestureRecognizer class],
       [UIAlertController class]
       ] enumerateObjectsUsingBlock:^(Class clazz, NSUInteger idx, BOOL * _Nonnull stop) {
        [clazz bfs_commitSwizzle];
    }];
}

+ (id<JQTAutoTrackDelegate>)delegate {
    return _delegate;
}

+ (void)setupWithDelegate:(id<JQTAutoTrackDelegate>)delegate {
    _delegate = delegate;
    if (!_tracker) {
        _tracker = [[JQTExposeTracker alloc] init];
        [_tracker start];
    }
}

+ (void)enableViewDebug:(BOOL)enable {
    [JQTPENHelper enableViewDebug:enable];
    [_tracker fireExposeUpdating];
}

@end
