//
//  JQTWeakObjectWrapper.m
//  BFBase
//
//  Created by jqoo on 2019/7/9.
//

#import "JQTWeakObjectWrapper.h"

@implementation JQTWeakObjectWrapper

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

+ (instancetype)wrapperWithObject:(id)object {
    return [[self alloc] initWithObject:object];
}

@end
