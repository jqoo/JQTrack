//
//  JQTWeakObjectWrapper.h
//  BFBase
//
//  Created by jqoo on 2019/7/9.
//

#import <Foundation/Foundation.h>

@interface JQTWeakObjectWrapper : NSObject

@property (nonatomic, weak, readonly) id object;

+ (instancetype)wrapperWithObject:(id)object;

- (instancetype)initWithObject:(id)object;

@end
