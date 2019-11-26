//
//  JQTEventMeta.m
//  JQTrack
//
//  Created by jqoo on 2019/7/16.
//

#import "JQTEventMeta.h"

@implementation JQTEventMeta

- (instancetype)initWithEventId:(NSString * _Nonnull)eventId label:(NSString *)label {
    self = [super init];
    if (self) {
        _eventId = eventId;
        _label = label;
    }
    return self;
}

@end
