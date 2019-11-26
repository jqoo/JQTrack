//
//  NSObject+JQTrack.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "NSObject+JQTrack.h"

@implementation NSObject (JQTrack)

+ (void)bfs_commitSwizzle {
    
}

+ (void)bfs_exchangeImplementationOfSelector:(SEL)selector
                                withSelector:(SEL)swizzledSelector
                                    withImpl:(IMP)impl {
    Method newMethod = class_getInstanceMethod(self, swizzledSelector);
    if (newMethod) {
        return;
    }
    Method originalMethod = class_getInstanceMethod(self, selector);
    if (!originalMethod) {
        // 如果原本就没有实现，则添加一个空方法
        IMP originImpl = imp_implementationWithBlock(^(id selfObject){
            // do nothing
        });
        class_addMethod(self, selector, originImpl, method_getTypeEncoding(originalMethod));
        originalMethod = class_getInstanceMethod(self, selector);
    }
    if (class_addMethod(self, swizzledSelector, impl, method_getTypeEncoding(originalMethod))) {
        newMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)bfs_exchangeImplementationOfSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static inline BOOL
bfs_hasOverrideSuperclassMethod(Class targetClass, SEL targetSelector) {
    Method method = class_getInstanceMethod(targetClass, targetSelector);
    if (!method) return NO;
    
    Method methodOfSuperclass = class_getInstanceMethod(class_getSuperclass(targetClass), targetSelector);
    if (!methodOfSuperclass) return YES;
    
    return method != methodOfSuperclass;
}

static inline const char *
bfs_typeString(NSMethodSignature *sig) {
    NSString *typeString = [sig performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
    return [typeString UTF8String];
}

+ (BOOL)bfs_overrideImplementationOfSelector:(SEL)targetSelector implementationBlock:(id (^)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)))implementationBlock {
    Class targetClass = self;
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    IMP imp = method_getImplementation(originMethod);
    BOOL hasOverride = bfs_hasOverrideSuperclassMethod(targetClass, targetSelector);
    
    // 以 block 的方式达到实时获取初始方法的 IMP 的目的，从而避免先 swizzle 了 subclass 的方法，再 swizzle superclass 的方法，会发现前者的方法调用不会触发后者 swizzle 后的版本的 bug。
    IMP (^originalIMPProvider)(void) = ^IMP(void) {
        IMP result = NULL;
        // 如果原本 class 就没人实现那个方法，则返回一个空 block，空 block 虽然没有参数列表，但在业务那边被转换成 IMP 后就算传多个参数进来也不会 crash
        if (!imp) {
            result = imp_implementationWithBlock(^(id selfObject){
                // do nothing
            });
        } else {
            if (hasOverride) {
                result = imp;
            } else {
                Class superclass = class_getSuperclass(targetClass);
                result = class_getMethodImplementation(superclass, targetSelector);
            }
        }
        
        return result;
    };
    
    if (hasOverride) {
        method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)));
    } else {
        const char *typeEncoding = method_getTypeEncoding(originMethod) ?: bfs_typeString([targetClass instanceMethodSignatureForSelector:targetSelector]);
        class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding);
    }
    
    return YES;
}

@end
