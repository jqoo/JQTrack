//
//  UICollectionView+JQTPrivate.m
//  JQTrack
//
//  Created by jqoo on 2019/7/11.
//

#import "UICollectionView+JQTPrivate.h"
#import "UIView+JQTrack.h"
#import <objc/message.h>

static NSInteger _depth;
static NSMutableSet *_overrideSet;

@implementation UICollectionView (JQTPrivate)

+ (void)bfs_commitSwizzle {
    [self bfs_exchangeImplementationOfSelector:@selector(setDelegate:)
                                  withSelector:@selector(bfs_setDelegate:)];
}

- (void)bfs_setDelegate:(id<UICollectionViewDelegate>)delegate {
    if (delegate) {
        Class clazz = [delegate class];
        if (![_overrideSet containsObject:clazz]) {
            [clazz bfs_overrideImplementationOfSelector:@selector(collectionView:didSelectItemAtIndexPath:)
                                    implementationBlock:^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                                        return ^(id selfObject, UICollectionView *collectionView, NSIndexPath *indexPath) {
                                            if ([selfObject isKindOfClass:originClass]) {
                                                if (_depth == 0) {
                                                    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                                                    [cell bfs_trackEvent:JQTEventType_Click];
                                                }
                                            }
                                            _depth++;
                                            // call super
                                            void (*originSelectorIMP)(id, SEL, id, id);
                                            originSelectorIMP = (void (*)(id, SEL, id, id))originalIMPProvider();
                                            originSelectorIMP(selfObject, originCMD, collectionView, indexPath);
                                            _depth--;
                                        };
                                    }];
            if (!_overrideSet) {
                _overrideSet = [NSMutableSet set];
            }
            [_overrideSet addObject:clazz];
        }
    }
    [self bfs_setDelegate:delegate];
}

@end
