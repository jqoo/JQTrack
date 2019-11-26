//
//  NSObject+JQTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <Foundation/Foundation.h>

@interface NSObject (JQTrack)

+ (void)bfs_commitSwizzle;

// 只会交换一次
+ (void)bfs_exchangeImplementationOfSelector:(SEL)selector
                                withSelector:(SEL)swizzledSelector
                                    withImpl:(IMP)impl;

// 可反复交换
+ (void)bfs_exchangeImplementationOfSelector:(SEL)originalSelector
                                withSelector:(SEL)swizzledSelector;

+ (BOOL)bfs_overrideImplementationOfSelector:(SEL)targetSelector
                         implementationBlock:(id (^)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)))implementationBlock;

@end
