//
//  JQTEventMeta+AutoTrack.m
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import "JQTEventMeta+AutoTrack.h"
#import "JQTAutoTrack.h"

@implementation JQTEventMeta (AutoTrack)

- (void)trackForType:(JQTEventType)eventType sender:(id)sender {
    [[JQTAutoTrack delegate] trackEvent:self type:eventType sender:sender position:0];
}

- (void)trackForType:(JQTEventType)eventType sender:(id)sender index:(NSInteger)index {
    [[JQTAutoTrack delegate] trackEvent:self type:eventType sender:sender position:index + 1];
}

+ (void)trackEvents:(NSArray<JQTEventMeta *> *)events forType:(JQTEventType)eventType {
    [[JQTAutoTrack delegate] trackEvents:events forType:eventType];
}

@end
