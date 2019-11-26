//
//  JQTEventMeta.h
//  JQTrack
//
//  Created by jqoo on 2019/7/16.
//

#import <Foundation/Foundation.h>

@protocol JQTEventMeta <NSObject>

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, copy) NSString *label;

@end

@interface JQTEventMeta : NSObject <JQTEventMeta>

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, copy) NSString *label;

- (instancetype)initWithEventId:(NSString * _Nonnull)eventId label:(NSString *)label;

@end
