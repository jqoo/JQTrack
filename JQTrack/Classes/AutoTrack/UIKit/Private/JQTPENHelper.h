//
//  JQTPENHelper.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <UIKit/UIKit.h>
#import "JQTEventMeta.h"

@interface JQTPENHelper : NSObject

@property (nonatomic, readonly) NSHashTable<UIView *> *penSubViewTable;
@property (nonatomic, readonly, unsafe_unretained) UIView *view;
@property (nonatomic, strong) JQTEventMeta *eventMeta;
@property (nonatomic, assign) BOOL updated;
@property (nonatomic, assign) BOOL potential;
@property (nonatomic, assign) BOOL exposed;

- (instancetype)initWithView:(UIView *)view;

- (BOOL)isPEN;
- (BOOL)hasPEN;

- (BOOL)hasPENSubview:(UIView *)subview;
- (void)addPENSubview:(UIView *)subview;
- (void)removePENSubview:(UIView *)subview;

- (void)installObserver;
- (void)uninstallObserver;

+ (void)enableViewDebug:(BOOL)enable;

@end
