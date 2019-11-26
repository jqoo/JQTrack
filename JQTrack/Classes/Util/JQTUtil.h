//
//  JQTUtil.h
//  JQTrack
//
//  Created by jqoo on 2018/11/16.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface JQTUtil : NSObject

+ (NSData *)zipData:(NSData *)data;

+ (NSDate *)dateFromRFC1123String:(NSString *)string;

+ (SEL)selectorForOrigin:(SEL)originSelector withPrefix:(NSString *)prefix;

@end

/**
 Synthsize a dynamic object property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) UIColor *myColor;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
 @end
 */
#ifndef JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT
#define JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif


/**
 Synthsize a dynamic c type property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) CGPoint myPoint;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 JQT_SYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
 @end
 */
#ifndef JQT_SYNTH_DYNAMIC_PROPERTY_CTYPE
#define JQT_SYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    _type_ cValue = { 0 }; \
    NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
    [value getValue:&cValue]; \
    return cValue; \
}
#endif

// log set
extern BOOL JQTLogEnable;
extern void (^JQTLogger)(NSString *fmt, ...);

#define bfs_log(tag, fmt, ...) \
!(JQTLogEnable && JQTLogger) ?: JQTLogger(@"<JQTrack-"tag@"> " fmt, ##__VA_ARGS__)
